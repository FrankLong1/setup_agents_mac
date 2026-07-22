# Review resolution

## Scope Baseline

Harden `setup_agents_mac` for a clean Mac factory reset without performing an
erase, changing accounts, uploading data, or restoring credentials. Preserve
the historical package inventory while making the safe clean-rebuild path lean
and evidence-gated.

## Finding Evaluation

### Finding 1 — shell-parse contract false coverage

- Decision: `accepted`
- Reason: Bash treats only the first file after `-n` as the script. The test was
  green without parsing four advertised entrypoints, including the reset gate.

## Single Bounded Repair Pass

Changed `test_shell_entrypoints_parse` to iterate over the five scripts and run
one `bash -n <script>` subprocess per file under a `subTest`. No production
behavior or task scope changed during the repair.

## Authoritative Revised Artifact

The human execution contract is `FACTORY_RESET_RUNBOOK.md`. The supporting
implementation is `migration/reset-preflight.sh`, the lean default in
`setup/profiles/personal.Brewfile`, the explicit historical inventory in
`setup/profiles/personal-full.Brewfile`, and the repository contract suite in
`tests/test_repository_contract.py`.

## Verification After Repair

- `python3 -m unittest discover -s tests -v`: 7 tests passed.
- Individual `bash -n` invocation for all five shell entrypoints: passed.
- `git diff --check`: passed.
- `./setup.sh --profile personal --check`: passed with 19 tasks OK and no
  failures; expected package drift was reported without installation.
- Ansible syntax checks for `setup/site.yml`, `setup/verify.yml`, and
  `setup/restore.yml`: passed.
- Homebrew metadata lookup for every lean formula and cask: passed.
- Live reset preflight: correctly returned NO-GO while Time Machine was running
  and reported 35 risky repositories among 63 top-level repositories scanned.

## Remaining Operational Risks

- The current Time Machine backup has not yet been proved complete or test-restored.
- iCloud upload status and representative files have not been verified manually
  from Finder plus iCloud.com or a second trusted device.
- The password-manager, Apple Account, primary email, GitHub, Google, OpenAI,
  and cloud-provider recovery fire drills have not been completed.
- Thirty-five top-level Git repositories currently have uncommitted work,
  locally-ahead commits, or no upstream; nested worktree collections require
  additional scan roots if they matter.
- This hardened working tree itself is not committed, pushed, merged to the
  default branch, or clean-cloned from another device.

These are `stop-escalate` operational gates for erasing the Mac, not accepted
code findings to patch automatically.

## Next Steps

Do not erase. Let Time Machine finish, perform a test restore, prove the second
copy and iCloud state, resolve or independently protect important Git work,
complete the 2FA fire drills, and publish/clean-clone the hardened setup path.
Only then rerun the preflight and review the final go/no-go record.

## Evaluation Evidence

- Normalized review run ID: `86a29086-c72b-4f70-947a-ecbacbed3a8d`
- Review output: `/tmp/setup-agents-mac-review.txt` (ephemeral, not persisted in
  the handoff directory)
- Local test command: `python3 -m unittest discover -s tests -v`
- Local preflight report: `/tmp/mac-reset-preflight.md` (ephemeral)
- No LangSmith trace ID was produced.
