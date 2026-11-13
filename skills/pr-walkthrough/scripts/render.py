#!/usr/bin/env python3
"""Render the review viewer from diff.json + plan.json.

Usage:
    render.py <dir> [--open] [--force]

Validates the plan first (same checks as check_plan.py) and refuses to render if
it's invalid, unless --force is given. Even then, the viewer puts any hunk the
plan missed into an "Unassigned" step, so nothing is ever hidden.

Writes <dir>/review.html, a static file with no server, so the Claude session stays free.

Default theme: Tokyo Night Storm, or "theme" in ~/.config/pr-walkthrough/config.json,
e.g. {"theme": "catppuccin-mocha"}. Use any Shiki theme ID, "tokyo-night-storm", or "auto".
"""
import json
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from check_plan import check  # noqa: E402

ASSETS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets")
TEMPLATE = os.path.join(ASSETS, "viewer.html")
THEMES = os.path.join(ASSETS, "themes")


DEFAULT_THEME = "tokyo-night-storm"
CONFIG = os.path.expanduser("~/.config/pr-walkthrough/config.json")


def default_theme():
    """Starting theme for every page: config.json's "theme" if set, else Tokyo Night Storm.
    A theme picked in the page's menu still wins for that browser."""
    try:
        with open(CONFIG) as fh:
            t = json.load(fh).get("theme")
        if isinstance(t, str) and t.strip():
            return t.strip()
    except (OSError, ValueError):
        pass
    return DEFAULT_THEME


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    flags = {a for a in sys.argv[1:] if a.startswith("--")}
    if len(args) != 1:
        sys.exit(__doc__)
    d = args[0]
    with open(os.path.join(d, "diff.json")) as fh:
        diff = json.load(fh)
    with open(os.path.join(d, "plan.json")) as fh:
        plan = json.load(fh)

    errors, _ = check(diff, plan)
    if errors and "--force" not in flags:
        for e in errors:
            print("ERROR: " + e)
        sys.exit("plan is invalid; fix it (or pass --force to render with an Unassigned step)")

    # Extra Shiki themes shipped with the skill (e.g. Tokyo Night Storm). Inlined because
    # a page opened from file:// can't fetch sibling files.
    themes = []
    for name in sorted(os.listdir(THEMES)):
        if name.endswith(".json"):
            with open(os.path.join(THEMES, name)) as fh:
                themes.append(json.load(fh))
    payload = dict(diff, plan=plan, custom_themes=themes, default_theme=default_theme())
    # Escape "<" so code containing "</script>" can't break out of the data block.
    blob = json.dumps(payload, ensure_ascii=False).replace("<", "\\u003c")
    with open(TEMPLATE) as fh:
        html = fh.read()
    if "__PRW_DATA__" not in html:
        sys.exit("error: viewer template is missing the __PRW_DATA__ placeholder")
    html = html.replace("__PRW_DATA__", blob, 1)

    out = os.path.join(d, "review.html")
    with open(out, "w") as fh:
        fh.write(html)
    print("wrote %s" % out)
    if "--open" in flags:
        opener = "open" if sys.platform == "darwin" else "xdg-open"
        subprocess.Popen([opener, out], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


if __name__ == "__main__":
    main()
