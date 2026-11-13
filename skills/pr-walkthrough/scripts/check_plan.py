#!/usr/bin/env python3
"""Validate a review plan against the PR's hunks.

Usage:
    check_plan.py <dir>            (expects <dir>/diff.json and <dir>/plan.json)

Plan format (plan.json):
    {
      "summary": "What the PR does and why, in 1-2 sentences.",
      "steps": [
        {"title": "Short step name", "why": "One line: what to look at here.", "hunks": ["h3", "h1"]}
      ],
      "notes": {"h3": "Neutral context worth knowing."},
      "flags": {"h1": "Something worth a closer look."}
    }

Rules:
  - every hunk ID in diff.json appears in exactly one step, with no unknown IDs
  - length limits below (they keep the plan scannable; rewrite tighter rather than cut)
  - a hunk gets at most one annotation: a note or a flag, not both

Exit code 0 = valid, 1 = errors (each one printed with the fix).
"""
import json
import os
import sys
from collections import OrderedDict

LIMITS = {"summary": 280, "title": 40, "why": 140, "note": 100}
MAX_STEPS = 10


def check(diff, plan):
    errors, warnings = [], []
    hunks = OrderedDict((h["id"], h) for h in diff["hunks"])

    if not isinstance(plan, dict):
        return ["plan.json must be an object"], warnings

    summary = plan.get("summary")
    if not isinstance(summary, str) or not summary.strip():
        errors.append("summary is missing")
    elif len(summary) > LIMITS["summary"]:
        errors.append("summary is %d chars (max %d); tighten it" % (len(summary), LIMITS["summary"]))

    steps = plan.get("steps")
    if not isinstance(steps, list) or not steps:
        errors.append("steps must be a non-empty list")
        steps = []
    if len(steps) > MAX_STEPS:
        errors.append("%d steps (max %d); merge related steps" % (len(steps), MAX_STEPS))

    seen = {}
    for i, s in enumerate(steps, 1):
        label = "step %d" % i
        if not isinstance(s, dict):
            errors.append("%s must be an object" % label)
            continue
        for key in ("title", "why"):
            v = s.get(key)
            if not isinstance(v, str) or not v.strip():
                errors.append("%s: %s is missing" % (label, key))
            elif len(v) > LIMITS[key]:
                errors.append("%s: %s is %d chars (max %d): %r" % (label, key, len(v), LIMITS[key], v))
        ids = s.get("hunks")
        if not isinstance(ids, list) or not ids:
            errors.append("%s: hunks must be a non-empty list" % label)
            continue
        for hid in ids:
            if hid not in hunks:
                errors.append("%s: unknown hunk ID %r" % (label, hid))
            elif hid in seen:
                errors.append("%s: %s is already in step %d (each hunk goes in exactly one step)"
                              % (label, hid, seen[hid]))
            else:
                seen[hid] = i

    missing = [hid for hid in hunks if hid not in seen]
    if missing:
        by_file = OrderedDict()
        for hid in missing:
            by_file.setdefault(hunks[hid]["path"], []).append(hid)
        detail = "; ".join("%s: %s" % (p, " ".join(ids)) for p, ids in by_file.items())
        errors.append("%d hunk(s) not in any step: %s" % (len(missing), detail))

    notes = plan.get("notes") or {}
    flags = plan.get("flags") or {}
    for kind, d in (("notes", notes), ("flags", flags)):
        if not isinstance(d, dict):
            errors.append("%s must be an object mapping hunk ID to text" % kind)
            continue
        for hid, text in d.items():
            if hid not in hunks:
                errors.append("%s: unknown hunk ID %r" % (kind, hid))
            if not isinstance(text, str) or not text.strip():
                errors.append("%s[%s] is empty" % (kind, hid))
            elif len(text) > LIMITS["note"]:
                errors.append("%s[%s] is %d chars (max %d): %r" % (kind, hid, len(text), LIMITS["note"], text))
    if isinstance(notes, dict) and isinstance(flags, dict):
        for hid in set(notes) & set(flags):
            errors.append("%s has both a note and a flag; keep one" % hid)

    if len(steps) == 1 and len(hunks) > 6:
        warnings.append("only one step for %d hunks; consider splitting so the order carries meaning"
                        % len(hunks))
    return errors, warnings


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    d = sys.argv[1]
    with open(os.path.join(d, "diff.json")) as fh:
        diff = json.load(fh)
    try:
        with open(os.path.join(d, "plan.json")) as fh:
            plan = json.load(fh)
    except json.JSONDecodeError as e:
        print("ERROR: plan.json is not valid JSON: %s" % e)
        sys.exit(1)
    errors, warnings = check(diff, plan)
    for w in warnings:
        print("WARNING: " + w)
    for e in errors:
        print("ERROR: " + e)
    if errors:
        sys.exit(1)
    n_flags = len(plan.get("flags") or {})
    print("OK: %d steps cover all %d hunks · %d flag(s)" % (len(plan["steps"]), len(diff["hunks"]), n_flags))


if __name__ == "__main__":
    main()
