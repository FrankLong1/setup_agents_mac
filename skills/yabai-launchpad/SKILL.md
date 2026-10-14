---
name: yabai-launchpad
description: Snapshot and restore named macOS workspace presets with yabai, including displays, Spaces, applications, window titles, bounds, and assignments. Use when the user wants a Bloomberg Launchpad-style saved layout, a one-shot app/window arrangement, a reversible desktop preset, or a complete current yabai layout capture without enabling persistent tiling.
---

# Yabai Launchpad

Use the bundled `scripts/yabai-launchpad.sh` as the deterministic implementation. It treats yabai as a passive control plane: the baseline config must use `layout float`, and no automatic window rules or Space creation should be added unless the user explicitly asks for them.

## Safety rules

- Never snapshot by changing window positions, focus, Spaces, labels, or display assignments.
- Never create, destroy, reorder, or move Spaces during restore.
- Never use `--focus` during restore unless the user explicitly requests it.
- Refuse to restore when the saved display count differs from the current display count unless the user explicitly overrides the check.
- Restore only when explicitly requested; `snapshot` and `list` are read-only with respect to windows and Spaces.
- Warn that macOS Space indexes and window IDs can change. Match windows by application and title, then verify the result.
- Use `--dry-run` before a first restore on an unfamiliar machine.

## Commands

```bash
SCRIPT="<skill-directory>/scripts/yabai-launchpad.sh"

# Capture the current layout without touching it.
"$SCRIPT" snapshot trading-desk

# See saved presets.
"$SCRIPT" list

# Preview a restore.
"$SCRIPT" restore trading-desk --dry-run

# Launch missing apps and restore the saved windows/spaces/bounds.
"$SCRIPT" restore trading-desk
```

Layouts are stored under `${XDG_CONFIG_HOME:-$HOME/.config}/yabai-launchpad/layouts/` as JSON. Set `YABAI_LAUNCHPAD_HOME` to choose another location, such as a dotfiles repository. The JSON is a portable snapshot artifact that can be copied, versioned, or duplicated as another preset.

## Workflow

1. Confirm yabai and jq are installed and that `yabai -m query --displays` works.
2. Keep the yabai startup config passive (`layout float`); do not use the stock BSP example for this workflow.
3. Run `snapshot <name>` while the desktop looks correct.
4. Inspect the generated JSON or use `restore <name> --dry-run`.
5. Run `restore <name>` only when the user wants the preset applied.
6. Report unmatched windows, display-count mismatches, or Space changes instead of silently guessing.

The script launches saved application names with `open -a`, waits for windows to appear, routes matched windows to their saved Space index, and restores saved floating bounds. It does not guarantee identical native full-screen application behavior because macOS owns full-screen Spaces and may recreate window IDs.

