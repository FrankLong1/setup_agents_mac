# Manual apps and sign-ins

This catalog covers software that is intentionally not installed by Homebrew,
or needs a human sign-in after installation. It contains official landing pages
only; do not store passwords, recovery codes, license keys, or session data in
this repository.

## Direct downloads

| App | Why it is manual | Official link |
| --- | --- | --- |
| We Love Lights | Manual installer | [We Love Lights](https://welovelights.app/) |

## Interactive sign-ins

Run these after `./setup.sh --profile personal`; they deliberately require a
human at the keyboard.

| Service | Action | Official link |
| --- | --- | --- |
| GitHub CLI | Run `gh auth login` | [GitHub CLI authentication](https://cli.github.com/manual/gh_auth_login) |
| Repository cloud access | From `gv_gcp_setup`, run `scripts/auth-repo.sh login --profile standard`; it owns the reviewed Google, Workspace, GitHub, AWS, registry, Secret Manager, Codex, and CRM authentication paths | See `identity-auth/docs/repository-authentication.md` in that checkout |
| AWS outside the repository flow | Use only the approved SSO or identity-provider flow for the target account | [AWS CLI SSO configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html) |
| Cloud workstation | Start the remote environment from the project checkout | `./start-workstation.sh vscode` in `gv_gcp_setup` |
| Desktop apps | Sign into Chrome, Claude, Codex, messaging, media, and licensed apps | Use each app's own sign-in window |

Before a factory reset, complete the identity and recovery gates in
[FACTORY_RESET_RUNBOOK.md](FACTORY_RESET_RUNBOOK.md). Do not rely on a login
session that exists only on the Mac being erased.

## Adding an item

When an installed application is missing from the Brewfile, first confirm that
there is no maintained Homebrew cask. If it must remain manual, add its name,
reason, and official link here and add the same three fields to
`manual_install_apps` in the relevant profile. This keeps the end-of-setup
output and this catalog aligned.
