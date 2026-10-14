# Handoff: Yabai Launchpad-style Mac desktop automation

**Last updated:** 2026-07-27  
**Repository:** /Users/frank/Projects/setup_agents_mac  
**Goal:** reproduce named, Bloomberg Launchpad-style Mac desktop arrangements on demand, then leave the desktop fully manual.

## User intent

The user wants a one-shot desktop preset system:

- capture the current arrangement when it looks right;
- save it as a named preset;
- later run one command to return to that arrangement;
- launch missing applications;
- put windows on intended displays and Spaces;
- restore window positions and sizes;
- allow normal drag/resize/move after restore;
- eventually let an AI agent inspect, snapshot, restore, and verify layouts through deterministic commands.

This is **not** a permanently enforced tiling desktop.

## Target setup

Earlier target hardware:

- primary 32-inch 6K landscape display, approximately 3072 x 1728 virtual HiDPI points;
- secondary 27-inch 5K portrait display, approximately 1440 x 2560 virtual HiDPI points.

Named workspace intent:

| Space | Purpose | Intended arrangement |
|---|---|---|
| dev | VS Code/IDE and terminal | primary landscape, editor plus terminal split |
| research | browser and references | primary landscape, browser dominant |
| logs | iTerm/Ghostty/logs | portrait display, stacked |
| communication | Slack, Discord, Mail, calendar | portrait display, grouped/stacked |
| dashboards | TradingView/Koyfin/web dashboards | primary landscape |

These are desired labels, not permission to create or reorder Spaces automatically.

## Decisions

### Yabai is the control layer

Use Yabai for shell-driven control over windows and Spaces: query displays/Spaces/windows, route windows, apply explicit rules, float or tile, and move/resize windows.

### Yabai must be passive by default

The baseline ~/.yabairc must not globally tile or continuously enforce layout. It should use:

~~~bash
layout float
~~~

Restore may make explicit changes while running. Afterward, Yabai must not fight the user.

### Hammerspoon is optional

Add Hammerspoon only for a proven gap, such as app readiness/wait logic, native notifications, display/headphone/sleep events, clipboard/file watches, or app-specific UI actions. Do not make it the core of the first restore path.

### Do not mutate Spaces automatically

macOS Spaces are display-specific and IDs can change. The safe first version must inspect existing displays and Spaces, report incompatibility, and never silently create, destroy, reorder, move, or rename Spaces.

## Critical lesson from the previous attempt

The stock/example Yabai config enabled global BSP tiling. Starting Yabai with it rearranged existing windows across the desktop. That was unacceptable.

Never activate the example BSP config for this workflow. Before starting Yabai, inspect the config and fail closed on unexpected global tiling, broad automatic rules, or active watchers:

~~~bash
grep -nE '^(layout|yabai -m rule|yabai -m signal)' "$HOME/.yabairc"
~~~

The next implementation must include a read-only preflight.

## Existing repository artifacts

Initial prototype files:

- [skills/yabai-launchpad/SKILL.md](/Users/frank/Projects/setup_agents_mac/skills/yabai-launchpad/SKILL.md)
- [skills/yabai-launchpad/scripts/yabai-launchpad.sh](/Users/frank/Projects/setup_agents_mac/skills/yabai-launchpad/scripts/yabai-launchpad.sh)
- [skills/yabai-launchpad/agents/openai.yaml](/Users/frank/Projects/setup_agents_mac/skills/yabai-launchpad/agents/openai.yaml)

Prototype commands:

~~~bash
LP=/Users/frank/Projects/setup_agents_mac/skills/yabai-launchpad/scripts/yabai-launchpad.sh
"$LP" snapshot trading-desk
"$LP" list
"$LP" restore trading-desk --dry-run
"$LP" restore trading-desk
~~~

Snapshots are stored under ~/.config/yabai-launchpad/layouts/ unless YABAI_LAUNCHPAD_HOME is set.

The prototype is not production-validated. Audit Yabai syntax for the installed version, multiple windows from one app, Space identity mapping, float-state handling, absolute move/resize syntax, full-screen behavior, and minimized windows before relying on it.

## Desired architecture

~~~text
AI agent or shell command
          |
          v
  launchpad CLI / skill
          |
          +--> validate Yabai and passive config
          +--> query displays and Spaces
          +--> launch missing applications
          +--> wait for matching windows
          +--> match saved windows safely
          +--> move/resize explicitly
          +--> verify and report
          |
          v
        Yabai
~~~

Expose high-level deterministic operations instead of unrestricted mouse, AppleScript, or Lua:

~~~text
launchpad preflight
launchpad snapshot <name>
launchpad list
launchpad inspect <name>
launchpad restore <name> --dry-run
launchpad restore <name>
launchpad verify <name>
launchpad diff <name>
~~~

## Snapshot contract

Snapshots should be reviewable JSON, written atomically with mode 600:

~~~json
{
  "schema": "yabai-launchpad/v1",
  "name": "trading-desk",
  "captured_at": "2026-07-27T00:00:00Z",
  "host": {},
  "displays": [],
  "spaces": [],
  "windows": []
}
~~~

Capture display identity/geometry, Space identity/label/display, app name and bundle ID, window title, saved Space/display, bounds, float/managed state, and a stable rank for multiple windows from the same app.

Do not capture passwords, tokens, cookies, Keychain data, browser profiles, private documents, screenshots, or arbitrary window contents. Do not use a process ID as the only identity.

Snapshot must not change window positions, focus, Spaces, or display assignment.

## Restore contract

Before changing anything:

1. Confirm Yabai is reachable and jq is installed.
2. Inspect and validate the passive ~/.yabairc.
3. Validate snapshot schema and display count/identity/geometry.
4. Resolve saved Spaces through verified identity; do not blindly trust stale numeric IDs.
5. Show a complete dry-run plan when requested.

During restore:

1. Launch missing applications with open -a.
2. Poll for windows until a deadline; do not rely on one arbitrary sleep.
3. Match by bundle ID/app, title, saved rank, and unused current window ID.
4. Refuse ambiguous matches or report them; never guess silently.
5. Move only the matched window to its verified destination.
6. Restore float/managed state and then bounds.
7. Avoid focus changes unless explicitly requested.
8. Re-query as needed and report restored, skipped, ambiguous, and failed windows.

After restore, no watcher, rule, timer, or launch agent may keep enforcing the layout. A second restore should not duplicate applications or windows.

## Layout strategy

Use structured tiling only when the preset asks for it. For arbitrary pixel arrangements, calculate relative rectangles from live display frames and use explicit bounds after the window reaches the correct display/Space.

Do not hard-code the example 6K/5K dimensions without checking live geometry. Full-screen apps, minimized windows, and app-internal tabs may not be restorable exactly; report those limitations.

## Permissions and SIP

The prior setup hit Accessibility and code-signature issues. Treat these as preflight checks, not reasons to mutate security settings automatically:

~~~bash
command -v yabai
yabai --version
yabai -m query --displays
yabai -m query --spaces
yabai -m query --windows
~~~

Do not automatically disable SIP, change Privacy permissions, ad-hoc sign binaries, remove/re-add Accessibility entries, install global launch agents, or kill/move windows during setup. If advanced native Space control requires SIP changes, stop and explain the tradeoff. The passive floating preset path should avoid that wherever possible.

## Testing plan

1. Static: bash -n the script and run the repository tests.
2. Read-only: query displays, Spaces, and windows before and after snapshot; prove no visible changes.
3. Disposable preset: test one or two non-critical apps.
4. Dual-monitor: test with both displays and with one absent; mismatch must fail closed.
5. Manual freedom: drag/resize after restore and prove nothing moves back.
6. Recovery: interrupt restore and rerun without duplicate windows or corrupting JSON.
7. Add fixture-backed fake-Yabai tests for malformed JSON, ambiguous matches, missing tools, and display mismatch.

## Next-session execution order

1. Read this handoff and inspect the current diff.
2. Inspect installed Yabai help and ~/.yabairc read-only.
3. Add and test preflight.
4. Fix snapshot schema and stable window matching.
5. Make dry-run output complete and human-readable.
6. Implement verified Space/display mapping.
7. Implement one-shot restore for floating windows and exact bounds.
8. Add post-restore verification and structured reporting.
9. Test before adding Hammerspoon.
10. Document installation, rollback, and known limitations.

## Definition of done

- Snapshot is read-only and reviewable.
- Dry-run makes no app, window, Space, or focus changes.
- Restore is explicit, idempotent enough, and reports partial failures.
- Displays/Spaces are validated; ambiguity fails closed.
- Yabai is passive after restore.
- Manual drag/resize remains possible.
- Dual-monitor layouts work when the expected displays are present.
- No credentials or private app data enter snapshots.
- Tests cover dangerous boundaries.

## Continuation prompt

> Continue the Yabai Launchpad project from HANDOFF_YABAI_LAUNCHPAD.md. First audit the prototype and passive Yabai config read-only. Do not launch, close, focus, move, resize, or kill any windows until a dry-run plan is shown and explicitly approved. Build a reliable one-shot snapshot/restore system for a dual-monitor Mac that saves displays, Spaces, apps, titles, bounds, and assignments; restores only on explicit command; never enforces layouts afterward; and fails closed on display or Space ambiguity.

