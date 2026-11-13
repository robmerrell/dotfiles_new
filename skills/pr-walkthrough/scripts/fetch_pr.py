#!/usr/bin/env python3
"""Fetch a GitHub PR and split its diff into hunks with stable IDs.

Usage:
    fetch_pr.py <pr-number|pr-url> [--repo OWNER/NAME] [--out DIR] [--source auto|git|gh]

Diff source:
    git (default when run inside a clone of the PR's repo): fetches the PR head and
        base into refs/pr-walkthrough/<N>/{head,base} (never touches your branches,
        working tree, index, or origin/* refs) and runs `git diff base...head`, the
        same comparison GitHub's "Files changed" tab shows. No size limits, and full
        files are readable with `git show refs/pr-walkthrough/<N>/head:<path>`.
    gh (fallback outside a clone): `gh pr diff`. Hunks only, and GitHub's API refuses
        very large diffs.

Whatever the source, the result is checked against GitHub's own list of changed
files. A missing or extra file is an error (exit 2), because the point is that no
code in the PR is skipped.

Writes to DIR (default ~/.cache/pr-walkthrough/<owner>-<repo>-<N>/):
    diff.json  - PR metadata, files, and every hunk (read by the viewer and check_plan.py)
    digest.md  - the diff as text with each hunk tagged by ID (read by Claude)
"""
import argparse
import fnmatch
import hashlib
import json
import os
import re
import subprocess
import sys

HUNK_RE = re.compile(r"^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@ ?(.*)$")

# Generated-file detection. "Generated" files are collapsed in the viewer and
# truncated in the digest, so a PR must not be able to hide its own code by
# claiming it's generated:
#   - .gitattributes (linguist-generated / linguist-vendored) is read at the BASE
#     commit, never the PR head, so the PR can't mark its own files.
#   - Lockfile names count everywhere (a new lockfile is still a lockfile).
#   - Looser patterns (*.generated.*, generated/, *.min.js, ...) only count for
#     files that already existed. A file the PR adds under such a name is reviewed
#     like any other code.
LOCKFILE_PATTERN = (r"(^|/)(package-lock\.json|npm-shrinkwrap\.json|yarn\.lock|pnpm-lock\.yaml|go\.sum|"
                    r"Cargo\.lock|poetry\.lock|Gemfile\.lock|composer\.lock|uv\.lock|Pipfile\.lock|"
                    r"flake\.lock|mix\.lock|Package\.resolved|pubspec\.lock)$")
GENERATED_PATTERNS = [
    r"\.(min\.js|min\.css|js\.map|css\.map|snap|pb\.go|pb\.ts|pb\.swift|_pb2\.py|_pb2_grpc\.py)$",
    r"\.lock\.ya?ml$",
    r"(^|/)(vendor|node_modules|__generated__|generated)/",
    r"\.generated\.",
]
DIGEST_GENERATED_LIMIT = 15   # only generated-file hunks are truncated in the digest

# Invisible characters that can make code display differently than it runs
# ("Trojan Source"): bidi controls, zero-width characters, BOM, soft hyphen.
HIDDEN_CHARS = re.compile("[­​-‏‪-‮⁠-⁤⁦-⁩﻿]")


def mark_hidden(s):
    return HIDDEN_CHARS.sub(lambda m: "⟦U+%04X⟧" % ord(m.group(0)), s)


# ---------------------------------------------------------------- helpers

def run(cmd, cwd=None, check=True):
    try:
        p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True,
                           encoding="utf-8", errors="replace")
    except FileNotFoundError:
        sys.exit("error: `%s` is not installed or not on PATH" % cmd[0])
    if check and p.returncode != 0:
        sys.exit("error running `%s`:\n%s" % (" ".join(cmd), p.stderr.strip()))
    return p


def git(root, *args, check=True):
    # Pin settings a user's gitconfig could change, so parsing is predictable.
    base = ["git", "-C", root, "-c", "core.quotePath=true", "-c", "diff.noprefix=false",
            "-c", "diff.mnemonicPrefix=false", "-c", "color.ui=never"]
    return run(base + list(args), check=check)


def parse_remote_url(url):
    m = re.match(r"^(?:https?://|ssh://)?(?:[^@/]+@)?github\.com[:/]([^/]+)/(.+?)(?:\.git)?/?$", url.strip())
    return (m.group(1).lower(), m.group(2).lower()) if m else None


def find_remote(root, owner, name):
    out = git(root, "remote", "-v").stdout
    for line in out.splitlines():
        parts = line.split()
        if len(parts) >= 2 and parse_remote_url(parts[1]) == (owner.lower(), name.lower()):
            return parts[0]
    return None


def strip_html_comments(text):
    text = re.sub(r"<!--.*?-->", "", text or "", flags=re.S)
    return re.sub(r"\n{3,}", "\n\n", text).strip()


# ---------------------------------------------------------------- diff parsing

def unquote_path(p):
    p = p.strip()
    if len(p) >= 2 and p[0] == '"' and p[-1] == '"':
        p = p[1:-1].encode("latin-1", "backslashreplace").decode("unicode_escape") \
                   .encode("latin-1").decode("utf-8", "replace")
    return p


def strip_prefix(p):
    p = unquote_path(p)
    if p == "/dev/null":
        return None
    return p[2:] if p[:2] in ("a/", "b/") else p


def parse_git_header_paths(rest):
    """Paths from the part of a `diff --git` line after the command.

    Git quotes paths containing special characters but NOT paths that merely contain
    spaces, so "a/READ ME b/READ ME" has to be split by symmetry. This is only a first
    guess: rename/copy and ---/+++ lines override it whenever they're present.
    """
    m = re.match(r'^("(?:[^"\\]|\\.)*"|\S+) ("(?:[^"\\]|\\.)*"|\S+)$', rest)
    if m:
        return strip_prefix(m.group(1)), strip_prefix(m.group(2))
    if rest.startswith("a/"):
        half = (len(rest) - 1) // 2
        left, right = rest[:half], rest[half + 1:]
        if rest[half] == " " and right.startswith("b/") and left[2:] == right[2:]:
            return left[2:], right[2:]
        idx = rest.find(" b/")
        if idx > 0:
            return rest[2:idx], rest[idx + 3:]
    return None, None


def parse_diff(text):
    """Parse a unified git diff into a list of file dicts, each with hunks."""
    files, cur, hunk = [], None, None
    old_ln = new_ln = 0
    for raw in text.split("\n"):
        if raw.startswith("diff --git "):
            if cur:
                files.append(cur)
            cur = {"old_path": None, "new_path": None, "status": "modified",
                   "binary": False, "meta": [], "hunks": []}
            hunk = None
            cur["old_path"], cur["new_path"] = parse_git_header_paths(raw[len("diff --git "):])
            continue
        if cur is None:
            continue
        # Inside a hunk, the header's line counts say exactly how many body lines
        # follow, so a removed line like "--- foo" can't be mistaken for a header.
        # "\ No newline at end of file" may trail the last body line.
        remaining = hunk is not None and (hunk["_old_left"] > 0 or hunk["_new_left"] > 0)
        if remaining or (hunk is not None and raw.startswith("\\")):
            kind, body = (raw[0], raw[1:]) if raw else (" ", "")
            if kind == "\\":
                hunk["lines"].append({"t": "\\", "s": body.strip()})
            elif kind == "+":
                hunk["lines"].append({"t": "+", "n": new_ln, "s": body})
                new_ln += 1
                hunk["_new_left"] -= 1
            elif kind == "-":
                hunk["lines"].append({"t": "-", "o": old_ln, "s": body})
                old_ln += 1
                hunk["_old_left"] -= 1
            else:
                hunk["lines"].append({"t": " ", "o": old_ln, "n": new_ln, "s": body})
                old_ln += 1
                new_ln += 1
                hunk["_old_left"] -= 1
                hunk["_new_left"] -= 1
            continue
        # Header territory.
        m = HUNK_RE.match(raw)
        if m:
            old_ln, new_ln = int(m.group(1)), int(m.group(3))
            oc = int(m.group(2)) if m.group(2) is not None else 1
            nc = int(m.group(4)) if m.group(4) is not None else 1
            hunk = {"old_start": old_ln, "old_count": oc, "new_start": new_ln, "new_count": nc,
                    "context": m.group(5).strip(), "lines": [], "_old_left": oc, "_new_left": nc}
            cur["hunks"].append(hunk)
        elif raw.startswith("new file mode"):
            cur["status"] = "added"
        elif raw.startswith("deleted file mode"):
            cur["status"] = "deleted"
        elif raw.startswith("rename from "):
            cur["status"], cur["old_path"] = "renamed", unquote_path(raw[12:])
        elif raw.startswith("rename to "):
            cur["status"], cur["new_path"] = "renamed", unquote_path(raw[10:])
        elif raw.startswith(("copy from ", "copy to ")):
            cur["status"] = "copied"
        elif raw.startswith(("old mode", "new mode")):
            cur["meta"].append(raw)
        elif raw.startswith(("Binary files", "GIT binary patch")):
            cur["binary"] = True
        elif raw.startswith("--- "):
            # Most reliable source of the path. Git adds a trailing tab when the path has spaces.
            p = strip_prefix(raw[4:].rstrip("\t"))
            if p is None:
                cur["status"] = "added"
            else:
                cur["old_path"] = p
        elif raw.startswith("+++ "):
            p = strip_prefix(raw[4:].rstrip("\t"))
            if p is None:
                cur["status"] = "deleted"
            else:
                cur["new_path"] = p
    if cur:
        files.append(cur)
    for f in files:
        for h in f["hunks"]:
            h.pop("_old_left", None)
            h.pop("_new_left", None)
    return files


# ---------------------------------------------------------------- generated detection

def gitattributes_generated(root, ref, paths):
    """Paths marked linguist-generated/vendored in .gitattributes at `ref`."""
    if not root or not paths:
        return set()
    inp = "\0".join(paths) + "\0"
    for extra in (["--source", ref], []):  # --source needs git >= 2.40
        p = subprocess.run(["git", "-C", root, "check-attr", "-z", "--stdin"] + extra +
                           ["linguist-generated", "linguist-vendored"],
                           input=inp, capture_output=True, text=True,
                           encoding="utf-8", errors="replace")
        if p.returncode == 0:
            parts = p.stdout.split("\0")
            hits = set()
            for i in range(0, len(parts) - 2, 3):
                path, _attr, val = parts[i], parts[i + 1], parts[i + 2]
                if val in ("set", "true"):
                    hits.add(path)
            return hits
    return set()


def is_generated(path, status, base_attr_paths):
    if path in base_attr_paths or re.search(LOCKFILE_PATTERN, path):
        return True
    return status != "added" and any(re.search(p, path) for p in GENERATED_PATTERNS)


# ---------------------------------------------------------------- assembly

def build(pr, files_raw, generated_paths):
    files, hunks, n = [], [], 0
    for fi, f in enumerate(files_raw):
        path = f["old_path"] if f["status"] == "deleted" else (f["new_path"] or f["old_path"])
        path = path or "(unknown)"
        gen = is_generated(path, f["status"], generated_paths)
        entry = {
            "id": "f%d" % (fi + 1), "path": path,
            "old_path": f["old_path"] if f["status"] in ("renamed", "copied") else None,
            "status": f["status"], "binary": f["binary"], "generated": gen,
            "anchor": "diff-" + hashlib.sha256(path.encode()).hexdigest(),
            "hunk_ids": [], "additions": 0, "deletions": 0,
        }
        raw_hunks = f["hunks"]
        if not raw_hunks:
            # Binary file, pure rename, or mode-only change: a placeholder hunk so it
            # still has to be placed in the plan.
            if f["binary"]:
                desc = "binary file %s" % f["status"]
            elif f["status"] == "renamed":
                desc = "renamed from %s, no content change" % f["old_path"]
            elif f["meta"]:
                desc = "; ".join(f["meta"])
            else:
                desc = "%s, no textual diff" % f["status"]
            raw_hunks = [{"old_start": 0, "old_count": 0, "new_start": 0, "new_count": 0,
                          "context": "", "lines": [], "placeholder": desc}]
        for h in raw_hunks:
            n += 1
            hid = "h%d" % n
            adds = sum(1 for l in h["lines"] if l["t"] == "+")
            dels = sum(1 for l in h["lines"] if l["t"] == "-")
            entry["additions"] += adds
            entry["deletions"] += dels
            entry["hunk_ids"].append(hid)
            hidden = any(HIDDEN_CHARS.search(l["s"]) for l in h["lines"])
            hunks.append(dict(h, id=hid, file_id=entry["id"], path=path,
                              additions=adds, deletions=dels, generated=gen, hidden_chars=hidden))
        files.append(entry)
    return {"pr": pr, "files": files, "hunks": hunks}


SOURCE_FILE_LIMIT = 512 * 1024       # per file; bigger files get hunk-only highlighting
SOURCE_TOTAL_LIMIT = 12 * 1024 * 1024  # across the whole PR


def full_sources(root, data):
    """Old and new contents of each changed file, so the viewer can syntax-highlight
    whole files (multi-line comments and strings come out right) and then show
    only the diff lines, the way GitHub does. Reads commits already in .git via one
    `git cat-file --batch` call."""
    pr = data["pr"]
    wanted = []  # (file_id, side, "rev:path")
    for f in data["files"]:
        if f["binary"] or f["generated"]:
            continue
        if f["status"] != "added":
            wanted.append((f["id"], "old", "%s:%s" % (pr["merge_base"], f["old_path"] or f["path"])))
        if f["status"] != "deleted":
            wanted.append((f["id"], "new", "%s:%s" % (pr["head_ref"], f["path"])))
    if not wanted:
        return {}
    p = subprocess.run(["git", "-C", root, "cat-file", "--batch"],
                       input="".join(w[2] + "\n" for w in wanted).encode(), capture_output=True)
    if p.returncode != 0:
        return {}
    buf, pos, total, out = p.stdout, 0, 0, {}
    for fid, side, _spec in wanted:
        nl = buf.index(b"\n", pos)
        header = buf[pos:nl].decode("utf-8", "replace").split()
        pos = nl + 1
        if len(header) < 3 or header[1] != "blob":
            continue  # "missing" or not a blob
        size = int(header[2])
        content = buf[pos:pos + size]
        pos += size + 1  # trailing newline after each object
        if size > SOURCE_FILE_LIMIT or total + size > SOURCE_TOTAL_LIMIT or b"\0" in content[:8000]:
            continue
        total += size
        out.setdefault(fid, {})[side] = content.decode("utf-8", "replace")
    return out


def cross_check(data, gh_files, changed_files_count):
    """Compare our file list with GitHub's. Returns (errors, warnings)."""
    errors, warnings = [], []
    gh = {f["path"]: f for f in gh_files}
    ours = {f["path"]: f for f in data["files"]}
    renamed_from = {f["old_path"] for f in data["files"] if f["old_path"]}
    if changed_files_count and len(gh_files) < changed_files_count:
        warnings.append("GitHub's file list is incomplete (%d of %d files), so the cross-check "
                        "is partial." % (len(gh_files), changed_files_count))
    for p in sorted(set(gh) - set(ours)):
        if p in renamed_from:
            continue  # GitHub shows delete+add where git detected a rename
        errors.append("GitHub lists %s but the diff does not contain it" % p)
    for p in sorted(set(ours) - set(gh)):
        if len(gh_files) >= (changed_files_count or 0):
            errors.append("the diff contains %s but GitHub does not list it" % p)
    for p in sorted(set(ours) & set(gh)):
        a, b = ours[p], gh[p]
        if (a["additions"], a["deletions"]) != (b.get("additions"), b.get("deletions")) and not a["binary"]:
            warnings.append("%s: +%d −%d locally vs +%s −%s on GitHub" %
                            (p, a["additions"], a["deletions"], b.get("additions"), b.get("deletions")))
    return errors, warnings


def digest(data):
    pr = data["pr"]
    out = ["# PR #%s: %s" % (pr["number"], pr["title"]),
           "%s · %s → %s · by %s" % (pr["url"], pr["headRefName"], pr["baseRefName"], pr["author"]),
           "%d files · %d hunks · +%d −%d · diff source: %s" % (
               len(data["files"]), len(data["hunks"]), pr["additions"], pr["deletions"], pr["source"])]
    if pr["source"] == "git":
        out.append("Full files at the PR head: `git -C %s show %s:<path>`" % (pr["git_root"], pr["head_ref"]))
    out += ["", "## PR description", "", pr["body"] or "(no description)", "",
            "## Hunk index (every ID must appear in the plan exactly once)", ""]
    for f in data["files"]:
        tags = [f["status"]] + (["generated"] if f["generated"] else []) + (["binary"] if f["binary"] else [])
        out.append("- %s [%s] +%d −%d: %s" % (f["path"], ", ".join(tags), f["additions"],
                                            f["deletions"], " ".join(f["hunk_ids"])))
    out += ["", "## Diff", ""]
    by_id = {h["id"]: h for h in data["hunks"]}
    for f in data["files"]:
        title = f["path"] + (" (from %s)" % f["old_path"] if f["old_path"] else "")
        out.append("### %s [%s]" % (title, f["status"]))
        limit = DIGEST_GENERATED_LIMIT if f["generated"] else None
        for hid in f["hunk_ids"]:
            h = by_id[hid]
            if h.get("placeholder"):
                out += ["[%s] (%s)" % (hid, h["placeholder"]), ""]
                continue
            ctx = (" " + h["context"]) if h["context"] else ""
            out.append("[%s] @@ -%d,%d +%d,%d @@%s" % (hid, h["old_start"], h["old_count"],
                                                     h["new_start"], h["new_count"], ctx))
            if h.get("hidden_chars"):
                out.append("⚠ This hunk contains hidden Unicode characters, shown as ⟦U+XXXX⟧.")
            for l in h["lines"][:limit]:
                s = mark_hidden(l["s"])
                out.append(("\\ " + s) if l["t"] == "\\" else (l["t"] + s))
            if limit is not None and len(h["lines"]) > limit:
                out.append("… [%d more lines not shown here; the viewer shows all of them]"
                           % (len(h["lines"]) - limit))
            out.append("")
    return "\n".join(out)


# ---------------------------------------------------------------- main

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("pr", help="PR number or URL")
    ap.add_argument("--repo", help="OWNER/NAME (defaults to the current directory's repo)")
    ap.add_argument("--out", help="output directory")
    ap.add_argument("--source", choices=["auto", "git", "gh"], default="auto")
    args = ap.parse_args()

    repo_args = ["--repo", args.repo] if args.repo else []
    fields = ("number,title,body,url,author,baseRefName,baseRefOid,headRefName,headRefOid,"
              "additions,deletions,changedFiles,files,state,isDraft")
    meta = json.loads(run(["gh", "pr", "view", args.pr, "--json", fields] + repo_args).stdout)
    m = re.match(r"https://[^/]+/([^/]+)/([^/]+)/pull/", meta["url"])
    owner, name = m.group(1), m.group(2)
    num = meta["number"]
    gh_files = meta.pop("files") or []
    pr = {k: meta.get(k) for k in ("number", "title", "url", "baseRefName", "headRefName",
                                    "headRefOid", "additions", "deletions", "changedFiles",
                                    "state", "isDraft")}
    pr.update(repo="%s/%s" % (owner, name), author=(meta.get("author") or {}).get("login", ""),
              body=strip_html_comments(meta.get("body")))
    warnings = []

    # Decide the diff source.
    root = remote = None
    if args.source in ("auto", "git"):
        p = run(["git", "rev-parse", "--show-toplevel"], check=False)
        if p.returncode == 0:
            root = p.stdout.strip()
            remote = find_remote(root, owner, name)
        if not remote:
            why = ("not inside a git repo" if not root else
                   "no remote in %s points at github.com/%s/%s" % (root, owner, name))
            if args.source == "git":
                sys.exit("error: --source git requested but %s" % why)
            warnings.append("Using GitHub's diff (%s). Only hunks are available, not full files." % why)
            root = None

    if root:
        head_ref = "refs/pr-walkthrough/%s/head" % num
        base_ref = "refs/pr-walkthrough/%s/base" % num
        # Open PR: compare against the live base branch, as GitHub does. Merged or
        # closed PR: the base branch has moved on (and may already contain the PR),
        # so use the base commit GitHub recorded for the PR instead.
        if pr["state"] == "OPEN" or not meta.get("baseRefOid"):
            base_src = "refs/heads/%s" % pr["baseRefName"]
        else:
            base_src = meta["baseRefOid"]
        git(root, "fetch", "--quiet", "--no-tags", "--no-write-fetch-head", remote,
            "+refs/pull/%s/head:%s" % (num, head_ref), "+%s:%s" % (base_src, base_ref))
        head_sha = git(root, "rev-parse", head_ref).stdout.strip()
        base_sha = git(root, "rev-parse", base_ref).stdout.strip()
        merge_base = git(root, "merge-base", base_ref, head_ref).stdout.strip()
        if head_sha != pr["headRefOid"]:
            warnings.append("Fetched head %s but GitHub reports %s (a push may have just happened). "
                            "Re-run to pick up the latest." % (head_sha[:10], (pr["headRefOid"] or "")[:10]))
        diff_text = git(root, "diff", "--no-ext-diff", "--no-textconv", "--find-renames",
                        "--src-prefix=a/", "--dst-prefix=b/", "--unified=3",
                        "%s...%s" % (base_ref, head_ref)).stdout
        pr.update(source="git", git_root=root, remote=remote, head_ref=head_ref, base_ref=base_ref,
                  head_sha=head_sha, base_sha=base_sha, merge_base=merge_base)
    else:
        p = run(["gh", "pr", "diff", args.pr, "--color=never"] + repo_args, check=False)
        if p.returncode != 0:
            sys.exit("error: GitHub refused the diff (it may be too large for the API). "
                     "Run this from a clone of %s/%s to use git instead.\n%s" % (owner, name, p.stderr.strip()))
        diff_text = p.stdout
        pr.update(source="gh", head_sha=pr["headRefOid"])

    files_raw = parse_diff(diff_text)
    paths = [f["new_path"] or f["old_path"] for f in files_raw if (f["new_path"] or f["old_path"])]
    # Base-side attributes only, so the PR can't mark its own code as generated.
    generated = gitattributes_generated(root, pr.get("merge_base"), paths)
    data = build(pr, files_raw, generated)

    attr_changes = [f["path"] for f in data["files"] if f["path"].split("/")[-1] == ".gitattributes"]
    if attr_changes:
        warnings.append("This PR changes %s. Review it closely: .gitattributes controls how git and "
                        "GitHub treat files (e.g. hiding them as generated)." % ", ".join(attr_changes))
    hidden = [h["id"] for h in data["hunks"] if h.get("hidden_chars")]
    if hidden:
        warnings.append("Hidden Unicode characters (bidi controls or zero-width) in %s. They can make "
                        "code display differently than it runs." % " ".join(hidden))

    data["sources"] = full_sources(root, data) if root else {}

    errors, w = cross_check(data, gh_files, pr["changedFiles"])
    warnings += w
    data["checks"] = {"errors": errors, "warnings": warnings}

    out = os.path.expanduser(args.out or "~/.cache/pr-walkthrough/%s-%s-%s" % (owner, name, num))
    os.makedirs(out, exist_ok=True)
    with open(os.path.join(out, "diff.json"), "w") as fh:
        json.dump(data, fh)
    with open(os.path.join(out, "digest.md"), "w") as fh:
        fh.write(digest(data))

    print("PR #%s: %s" % (num, pr["title"]))
    print("%d files · %d hunks · +%d −%d · source: %s" % (len(data["files"]), len(data["hunks"]),
                                                         pr["additions"], pr["deletions"], pr["source"]))
    for x in warnings:
        print("WARNING: " + x)
    for x in errors:
        print("ERROR: " + x)
    print("out: %s" % out)
    if errors:
        print("The diff does not match GitHub's file list. Tell the user before planning; "
              "do not present the review as complete.")
        sys.exit(2)


if __name__ == "__main__":
    main()
