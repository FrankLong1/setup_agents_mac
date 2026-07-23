# Maintaining the clean package baseline

The goal is not to reproduce every package that has ever touched the Mac. The
goal is to make a new Mac useful quickly, while keeping every permanent tool and
background process intentional.

Homebrew is a rolling-release package manager. A Brewfile records desired
packages, not exact versions, and Homebrew does not provide a Brewfile lock
file. This repository therefore optimizes for a small, reviewed baseline rather
than byte-for-byte reproduction.

## The two package records

- `setup/profiles/personal.Brewfile` is the lean default. An item belongs here
  only when it should be installed during nearly every clean rebuild.
- `setup/profiles/personal-full.Brewfile` is a historical receipt and discovery
  aid. It is not the recommended setup and requires an explicit `--full`.
- A timestamped Brewfile from `migration/capture-state.sh` is evidence of what
  happened to be installed on one machine. Never copy it over the lean file.

The lean file may include formulae, casks, VS Code extensions, and other package
types supported by Homebrew Bundle. Keep licensed or unreliable direct-download
software in `MANUAL_APPS.md`.

## Admission rule for the lean Brewfile

Add a package only when all of these are true:

1. It supports a recurring workflow, not a one-off experiment.
2. You would want it during the first week after every clean install.
3. A managed service or existing tool does not already cover the need.
4. Its ongoing updates, permissions, login items, and three-year maintenance
   cost are acceptable.
5. Its source is understood. Third-party taps must be narrow and explicitly
   trusted; never disable Homebrew's tap-trust checks globally.

Formula dependencies do not need separate entries merely because they appear
in `brew list`. Avoid permanent database servers, Kubernetes stacks, extra
language versions, and overlapping utilities unless a current workflow
specifically needs them.

The lean Brewfile must not start a background service. A future
`restart_service` entry requires a documented reason and an explicit review.
Prefer an on-demand command, container, Cloud Run job, or other ephemeral
runtime when practical.

## Capture and curate

Capture the current installed state without modifying the Mac:

```bash
./migration/capture-state.sh
```

The command prints the timestamped inventory directory. Compare its Brewfile
with the lean baseline:

```bash
diff -u \
  setup/profiles/personal.Brewfile \
  "$HOME/mac-setup-inventory/<TIMESTAMP>/Brewfile"
```

Classify every difference as one of:

- **baseline:** promote it to `personal.Brewfile`;
- **optional/manual:** document it in `MANUAL_APPS.md` if it remains useful;
- **historical:** retain it only in `personal-full.Brewfile`;
- **remove:** uninstall it after confirming that no active project needs it.

Edit the curated file directly, or use Homebrew Bundle's add/remove helpers:

```bash
brew bundle add --file=setup/profiles/personal.Brewfile --cask firefox
brew bundle remove --file=setup/profiles/personal.Brewfile --cask firefox
```

Keep entries grouped by type and alphabetized. Add a comment only when the
reason or source would otherwise be surprising.

## Validate a proposed change

These checks are read-only with respect to installed package state:

```bash
brew bundle list --file=setup/profiles/personal.Brewfile
brew bundle check \
  --no-upgrade \
  --verbose \
  --file=setup/profiles/personal.Brewfile
python3 -m unittest discover -s tests -v
./setup.sh --profile personal --check
```

`brew bundle check` returning nonzero can simply mean a newly declared package
is not installed yet. Read the verbose output and confirm that every missing
item is expected. A normal setup run installs missing entries without upgrading
unrelated packages:

```bash
./setup.sh --profile personal
./verify.sh --profile personal
```

Before trusting a reset change, also prove the exact committed revision from a
fresh clone. The best full test is a disposable or newly erased Mac; `--check`
cannot simulate Homebrew installers or macOS permission prompts perfectly.

## Remove accumulated packages safely

First preview what the lean file does not declare:

```bash
brew bundle cleanup --file=setup/profiles/personal.Brewfile
```

Do not add `--force` until every proposed removal has been reviewed. Cleanup is
destructive and can remove tools used by projects outside this repository. Even
after approval, remove small groups and verify active projects between groups.
Never run a global package, Docker, cache, or filesystem prune as part of this
setup.

After cleanup, inspect **System Settings > General > Login Items & Extensions**
and Activity Monitor. Homebrew can manage packages, but applications can create
their own login items, privileged helpers, and update agents.

## Update rhythm

Use this maintenance loop:

- after intentionally adopting or retiring an important tool;
- before every factory reset;
- quarterly, to challenge stale baseline entries;
- after the rebuilt Mac has been stable for a week, to remove anything that was
  not actually needed.

Upgrade packages separately from changing the declared baseline. Review
`brew outdated`, apply updates in a bounded batch, and run verification again.
Do not turn a clean rebuild into an automatic upgrade of every historical tool.

Homebrew reference:
[Homebrew Bundle and Brewfile](https://docs.brew.sh/Brew-Bundle-and-Brewfile).
