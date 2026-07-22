# Independent final code review

## Review Target

- Target: full local dirty working tree on `feature/ansible-mac-setup`
- Focus: macOS-native CI, exact published-commit recovery pinning, and regressions
  across the complete factory-reset hardening diff
- Prior handoff: `.agents/handoffs/review-and-resolve/20260722T031609Z-mac-reset-hardening`
- Engine: Claude (`claude-opus-4-8`, medium thinking)
- Normalized run ID: `756e083a-7894-4e99-988a-1f27f78452e3`
- Deterministic tests run in parallel: `python3 -m unittest discover -s tests -v`

## Verdict

Patch correct, confidence 0.7. No accepted or actionable findings were reported.

## Areas Attacked

- The `--full` option and whether `profile_brewfile` is actually consumed by
  prerequisites, Homebrew, and verification.
- Alignment between the lean Brewfile and required commands/applications.
- Safety and clean-runner behavior of the macOS GitHub Actions check-mode job.
- The opt-in Puppeteer MCP boundary after removing its package from the lean set.
- The repaired one-script-per-process shell-parse contract.
- Fail-safe and read-only behavior of both reset-preflight outcomes.
- Credential exclusion and approval gating in the legacy config-only restore role.
- Whether the exact-commit placeholder is a defect or an intentional human gate.

## Findings

None.

## Reviewer Notes

The reviewer verified the relevant files rather than relying only on the patch.
It found the macOS CI job safe in check mode, confirmed the full/lean variable
flow, and treated the unpublished dirty working tree as a real operational gate
rather than a code defect. The exact commit placeholder remains intentionally
unresolved until a reviewed commit is published and clean-clone-proven.

## Human-needed blockers

The code review itself has none. Backup completion/test restore, iCloud and
second-copy verification, recovery-method fire drills, repository publication,
and clean-clone proof still require external or human evidence before erase.
