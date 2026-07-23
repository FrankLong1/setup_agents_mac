#!/usr/bin/env python3
"""Deep-merge a JSON/JSONC overlay without deleting unmanaged settings."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import sys
import tempfile
from typing import Any


def parse_jsonc(text: str) -> Any:
    without_comment_lines = re.sub(r"(?m)^\s*//.*$", "", text)
    return json.loads(without_comment_lines or "{}")


def merge(current: Any, overlay: Any) -> Any:
    if isinstance(current, dict) and isinstance(overlay, dict):
        result = dict(current)
        for key, value in overlay.items():
            result[key] = merge(result[key], value) if key in result else value
        return result
    if isinstance(current, list) and isinstance(overlay, list):
        result = list(current)
        for value in overlay:
            if value not in result:
                result.append(value)
        return result
    return overlay


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("target", type=Path)
    parser.add_argument("mode", choices=("check", "apply"))
    args = parser.parse_args()

    overlay = parse_jsonc(sys.stdin.read())
    if args.target.exists():
        try:
            current = parse_jsonc(args.target.read_text())
        except (OSError, json.JSONDecodeError) as exc:
            print(f"refusing to replace unreadable JSON at {args.target}: {exc}", file=sys.stderr)
            return 2
    else:
        current = {} if isinstance(overlay, dict) else []

    desired = merge(current, overlay)
    if desired == current:
        return 0
    if args.mode == "check":
        return 3

    args.target.parent.mkdir(parents=True, exist_ok=True)
    rendered = json.dumps(desired, indent=2, sort_keys=False) + "\n"
    fd, temporary_name = tempfile.mkstemp(prefix=f".{args.target.name}.", dir=args.target.parent)
    try:
        with os.fdopen(fd, "w") as handle:
            handle.write(rendered)
        os.replace(temporary_name, args.target)
    finally:
        if os.path.exists(temporary_name):
            os.unlink(temporary_name)
    return 3


if __name__ == "__main__":
    raise SystemExit(main())
