---
decision: needs_user
reason: >-
  The reviewed implementation is code-ready, but the handoff explicitly carries unresolved stop-escalate operational gates for backup restoration, iCloud and second-copy verification, Git preservation, identity and 2FA recovery, and clean bootstrap proof. Those gates require human or external confirmation and the authoritative runbook says the decision remains NO-GO until every box is checked and the user explicitly says go.
confidence: high
chain_id: 019f87a7-c24a-7322-b38e-e08f8f2da3c6
repair_attempt_count: 0
review_and_resolve_handoff: .agents/handoffs/review-and-resolve/20260722T031609Z-mac-reset-hardening
authoritative_artifact: FACTORY_RESET_RUNBOOK.md
fresh_context_available: true
direct_launch_available: true
direct_launch_approved: true
goal_prompt: null
repair_prompt: null
required_human_input: >-
  Complete and attest to the runbook's go/no-go record: a completed Time Machine backup with successful test restore; an independently verified second copy and iCloud state; all important dirty or unpushed Git work protected; password-manager, Apple Account, primary-email, GitHub, and other recovery-critical 2FA fire drills passed with two independent recovery methods; and a clean clone and verification of this setup repository from another device. After reviewing that evidence, explicitly say go to authorize only the next bounded audit step; erasing the Mac remains separately unauthorized.
final_review_required: true
evidence_refs:
  - .agents/handoffs/review-and-resolve/20260722T031609Z-mac-reset-hardening/review.md
  - .agents/handoffs/review-and-resolve/20260722T031609Z-mac-reset-hardening/resolution.md
  - FACTORY_RESET_RUNBOOK.md
  - "command: git status --short --branch (2026-07-22 UTC; hardened working tree still dirty and untracked)"
unresolved_risks:
  - Current Time Machine completion and a successful representative test restore are unproved.
  - The independent second copy and iCloud upload/remote-file state are unproved.
  - Thirty-five repositories were previously reported risky, and the hardened setup working tree remains unpublished and not clean-clone-proven.
  - Recovery fire drills and two independent recovery methods for recovery-critical accounts are unproved.
  - Explicit human go authorization is absent; no destructive erase is authorized.
---

## Evidence Read

The independent review accepted one P2 test-contract defect. The bounded repair changed the shell-parse test to invoke `bash -n` separately for all five entrypoints, after which seven unit tests, individual shell parses, `git diff --check`, the setup check, Ansible syntax checks, and Homebrew metadata checks passed. The live preflight correctly returned NO-GO.

The resolution and runbook both preserve external/manual gates: test-restored backup, second copy and iCloud proof, protected Git state, recovery fire drills, clean bootstrap from another device, and explicit user approval. A fresh status check also confirms that the hardened repository work remains dirty and untracked.

## Decision Rationale

This is not a repair-loop candidate: the remaining blockers are real-world proofs and approvals, not a defect that one more artifact-edit pass can resolve. It is also not eligible for direct or prompt launch because the launch maturity rubric forbids launch with an unresolved `stop-escalate` item. The safe result is `needs_user`; until the required evidence is supplied and reviewed, the Mac remains NO-GO for erase.
