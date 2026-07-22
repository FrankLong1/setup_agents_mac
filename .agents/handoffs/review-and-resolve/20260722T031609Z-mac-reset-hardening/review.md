# Independent code review

## Review Target

- Target: local dirty working tree on `feature/ansible-mac-setup`
- Scope: factory-reset runbook, read-only reset preflight, lean/full package split,
  credential-safe restore boundary, safer agent defaults, tests, and CI
- Engine: Claude (`claude-opus-4-8`, high thinking)
- Normalized run ID: `86a29086-c72b-4f70-947a-ecbacbed3a8d`
- Deterministic tests run in parallel: `python3 -m unittest discover -s tests -v`

## Verdict

Patch incorrect before repair, confidence 0.6. The functional hardening changes
were judged sound, but the new test suite contained false shell-parse coverage.

## Finding 1 — P2 — Test contract false coverage

- Location: `tests/test_repository_contract.py`, the shell-entrypoint parse test
- Category: regression-test correctness
- Confidence: moderate
- Classification from reviewer: actionable defect

The test invoked `bash -n` once with five script paths. Bash parses only the
first file as the script and treats the remaining paths as positional
parameters, so `verify.sh`, `setup/run.sh`, `migration/capture-state.sh`, and
`migration/reset-preflight.sh` were never parsed by that test.

### Failure mechanism

A syntax error in the changed setup runner or reset preflight could leave CI
green even though the README claimed all entrypoints were shell-parsed. Because
the preflight is the automated gate before an irreversible erase, this created
a concrete false-assurance path. The end-to-end preflight tests happened to
exercise that script, but the general parse contract remained false for the
other entrypoints.

## Other Reviewed Areas

The reviewer reported no actionable defect in the `--full` variable flow, the
lean/full Brewfile boundary, the Puppeteer MCP opt-in, the guarded config-only
restore role, or the fail-safe/read-only reset-preflight behavior. It also found
the preflight Bash 3.2-compatible and confirmed that the mocked pass/fail tests
are coherent for Linux CI.

## Human-needed blockers

None for repairing the code finding. Operational reset approval remains outside
this review and depends on the runbook's backup, Git, iCloud, and 2FA gates.
