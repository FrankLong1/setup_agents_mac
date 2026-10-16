# Replacement-Mac readiness

Checked October 16, 2026. Work item: [mock_hf_v2 #432](https://github.com/FrankLong1/mock_hf_v2/issues/432).

The kit remains M1: contract and check-mode validation do not prove a clean-Mac
installation or recovery. Keep the old Mac until the replacement opens the needed
projects, private originals, and agent context.

## Software and agent setup

The baseline includes Codex desktop/CLI, Claude desktop/Code, GitHub CLI, Google
Cloud CLI, Python, Node, Bun, tmux, Terraform, and uv. Bun is needed by current
project tooling; tmux must be installed to use the managed tmux configuration.
The full Brewfile remains optional. Stats and Link CLI retain the current local
package choices. Logitech uses Homebrew's current `logi-options+` cask name.

Ansible collection detection consumes the complete listing. Early termination
with `grep -q` under `pipefail` could falsely report that the installed
`community.general` collection was absent. A large-output regression exercises
this failure. Verification now reports the missing Bundle entries.

Sign in interactively after installation. From the existing gv_gcp_setup checkout,
use its documented auth-repo workflow for cloud access. Do not copy authentication
databases or browser profiles into this repository.

Local Claude plugin marketplaces point to other project directories. Recover
those projects or review/remove the corresponding plugin entries before expecting
those plugins to work on a new Mac. This kit does not recreate all connected
plugins, global skills, MCP services, schedules, or private agent history.

## Recover source and private state separately

The October 14 recovery branch `codex/machine-preservation-2026-10-14` preserves
unfinished local setup work, including the NAS helper/runbook. Those snapshots
are distinct from main and should be reviewed before use. Preserve the original
checkout rather than resetting it to this audit branch.

Git preserves code and selected configuration. Global Codex/Claude conversations,
memories, instructions, local databases, credentials, SSH keys, and VM disks need
an independently verified private backup. Do not add them to this public repo.

The October 16 Mac check still reports no configured Time Machine destination
and cannot mount a latest backup. This does not establish whether offline backups
exist. Attach the existing destination and restore representative files before
retiring the Mac.

## Existing research and course backups

Arta: a fresh restore of the pinned October 6 GCS snapshot passed all 97 file
hashes (301,735,534 bytes). Its 91 PDFs match the current local archive exactly.
The captured documents can be recovered without rescraping. This proves recovery
of the captured corpus, not that every document now offered by Arta was captured.
The private restore procedure and receipt live with mock_hf_v2's archive tools.

Course videos: live Drive inspection found all 13 expected files: eight module
ZIPs for Modules 0–7 and five indexes/playlists. They cover the 56-segment October
10 local archive, including Containers. Visible names and rounded sizes do not
prove every remote ZIP's checksum or availability of subsequently released
course material. Keep originals until the remote integrity check is complete.

## Final rehearsal

On a disposable or replacement Mac, clone the exact reviewed commit, run the
personal profile, rerun it to check idempotence, run verification, sign in, and
open representative projects and restored files. Record the commit, macOS/CPU,
commands, results, and any manual steps before promoting this kit beyond M1.
