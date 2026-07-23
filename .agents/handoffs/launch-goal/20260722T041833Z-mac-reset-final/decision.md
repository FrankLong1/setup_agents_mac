---
decision: needs_user
reason: >-
  The reviewed repository hardening is mature and its deterministic checks pass, but the handoff explicitly carries unresolved stop-escalate gates for backup restoration, independent-copy and iCloud verification, Git preservation and publication, identity recovery, and clean-bootstrap proof. The launch rubric forbids launch while those gates remain unresolved, and the runbook keeps erase at NO-GO until every proof is green and the user explicitly says go.
confidence: high
chain_id: 019f87a7-c24a-7322-b38e-e08f8f2da3c6
repair_attempt_count: 0
review_and_resolve_handoff: .agents/handoffs/review-and-resolve/20260722T041657Z-mac-reset-final-review
authoritative_artifact: FACTORY_RESET_RUNBOOK.md
fresh_context_available: true
direct_launch_available: true
direct_launch_approved: true
goal_prompt: null
repair_prompt: null
required_human_input: >-
  Complete and attest to the runbook's go/no-go record: a completed fresh Time Machine backup with a successful representative-file restore; an independently verified second copy and clean iCloud status from another device or iCloud.com; protection of all important dirty, locally-ahead, or no-upstream Git work; successful password-manager, Apple Account, primary-email, GitHub, and other recovery-critical account fire drills with two independent recovery methods; publication of the hardened setup repository at an exact SHA recorded off-Mac and a clean-clone verification of that SHA from another device; and then an explicit go after reviewing all evidence. No erase is authorized before that audit.
final_review_required: true
evidence_refs:
  - .agents/handoffs/review-and-resolve/20260722T041657Z-mac-reset-final-review/review.md
  - .agents/handoffs/review-and-resolve/20260722T041657Z-mac-reset-final-review/resolution.md
  - FACTORY_RESET_RUNBOOK.md
  - "command: python3 -m unittest discover -s tests -v (2026-07-22 UTC; 8 tests passed)"
  - "command: git status --short --branch; git rev-parse HEAD; git ls-remote --heads origin feature/ansible-mac-setup (2026-07-22 UTC; hardened work remains dirty/untracked while local and remote feature branch both point to 5ae341928338181f52f77441337fe4aa95a64a1a)"
  - "command: tmutil status; tmutil latestbackup (2026-07-22 UTC; backup still running in PreparingSourceVolumes and latest-backup proof unavailable because the process lacks Full Disk Access)"
unresolved_risks:
  - Time Machine completion and a successful representative-file restore remain unproved; the current backup session is still running.
  - The independent second copy and iCloud upload/status and remote-file checks remain unproved.
  - Important local Git work may remain unprotected, and the hardened setup work is neither published at the recorded remote SHA nor clean-clone-proven from another device.
  - Recovery fire drills and two independent methods for recovery-critical accounts remain unproved.
  - Explicit human go authorization is absent; no destructive erase is authorized.
---

## Evidence Read

The final independent review reported no actionable findings after attacking the lean/full profile boundary, macOS CI safety, credential exclusions, preflight fail-safety, and exact-commit recovery pinning. Its handoff records eight passing unit tests, a successful setup check, clean diff validation, resolved Homebrew metadata, and a deliberately failed remote clean-clone recovery gate because the hardened work is still unpublished.

A fresh read-only check reproduced all eight passing tests. It also confirmed that the hardened working tree remains dirty and untracked while both the local and remote feature branch still point to `5ae341928338181f52f77441337fe4aa95a64a1a`; Time Machine is still running in `PreparingSourceVolumes`, and this process cannot independently read the latest completed backup without Full Disk Access.

## Decision Rationale

This is not a repair-loop candidate: the remaining blockers are external proofs and a human approval, not defects that another artifact-edit pass can resolve. Despite fresh-context and direct-goal capabilities and explicit goal-launch intent, `launch_direct` and `launch_prompt` are disallowed because the reviewed handoff names unresolved `stop-escalate` items. The safe decision is `needs_user`; the Mac remains NO-GO for erase until every required proof is supplied, independently audited, and followed by explicit human go authorization.
