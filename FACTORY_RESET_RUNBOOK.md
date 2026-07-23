# Safe Mac factory-reset runbook

> **Implementation status:** the current setup automation is an M1 prototype.
> Use this runbook to plan and protect a reset, but do not treat the apply
> command as proven until the M2 disposable clean-machine rehearsal in
> [ARCHITECTURE.md](ARCHITECTURE.md) has succeeded.

This runbook is a stop/go gate for erasing a personal Mac and rebuilding it
without recreating years of accidental workstation state. The setup repository
installs software and selected configuration; it does **not** back up documents,
credentials, browser sessions, application data, or uncommitted Git work.

Nothing in this repository erases the Mac. The erase remains a deliberate human
action in macOS System Settings.

## Current decision rule

Do not erase until all three proofs are green:

1. **Data proof:** a fresh versioned backup plus a second independent copy of
   critical data, with a successful test restore.
2. **Identity proof:** the password manager, Apple Account, primary email, and
   developer accounts can all be entered from another device using at least two
   independent authentication or recovery methods.
3. **Bootstrap proof:** important Git work is pushed or separately backed up,
   and this repository can be cloned and verified from another device.

Run the read-only automated portion first:

```bash
./migration/reset-preflight.sh \
  --scan-root "$HOME/Projects" \
  --max-depth 2 \
  --output "$HOME/Desktop/mac-reset-preflight.md"
```

A zero exit code means only that the automated checks found no blocker. It does
not waive the manual gates printed in the report.

The default depth covers repositories directly under `~/Projects`. Add another
`--scan-root` for any nested worktree or archive collection that contains work
you care about; do not make a giant vendor/cache tree part of the normal gate.

## Phase 1: protect the data

- [ ] Stop apps that own local databases or virtual machines before the final
  backup: Docker/Colima, database servers, Obsidian, Photos, messaging apps, and
  any local agent/task system.
- [ ] Attach an encrypted Time Machine disk and choose **Back Up Now**. Apple
  recommends a dedicated backup device with about twice the Mac's storage
  capacity.
- [ ] Wait until the Time Machine menu reports a completed backup from today.
- [ ] For a network backup, also choose **Back Up Now** and confirm that it
  reaches the data-transfer phase. A historical timestamp in System Settings is
  not proof that the NAS is reachable now. Treat `Failed to mount`, `No route
  to host`, or a backup that stops while finding the destination as a no-go.
- [ ] If a supported SMB NAS is reachable by address but its Bonjour name is
  not, follow Apple's recovery path: connect to the same Time Machine share in
  Finder with `smb://<reachable-host>/<share>`, then select that mounted network
  disk in Time Machine settings. Do not remove the old destination or create a
  new backup set until you have proved that this is the same protected dataset.
- [ ] For TrueNAS, verify that the share uses the **Time Machine Share** purpose
  and that the SMB service has the Apple SMB2/3 protocol extension enabled.

For a hostname-only repair, preserve rollback by adding and testing the
reachable URL before removing the stale one. Use `-p`; never put the NAS
password in the URL or shell history.

```bash
# Record the existing destination URL and ID.
tmutil destinationinfo

# Add the same protected share through its reachable hostname. This requires
# administrator approval, Full Disk Access, and an interactive NAS password.
sudo tmutil setdestination -a -p 'smb://USER@REACHABLE_HOST/SHARE'

# Identify the newly added destination and target it explicitly.
tmutil destinationinfo
tmutil startbackup --auto --destination NEW_DESTINATION_ID
```

Do not run `tmutil removedestination STALE_DESTINATION_ID` until the targeted
backup completes and a representative test restore succeeds. If the test
fails, remove only the newly added destination and keep the prior configuration.

- [ ] Enter Time Machine and restore one representative document to a temporary
  folder. Open it and compare it with the original.
- [ ] Keep a second independent copy of irreplaceable documents. iCloud Drive is
  useful redundancy and synchronization, but deletion or corruption can sync;
  it is not the only backup.
- [ ] In Finder, open iCloud Drive in list view, enable **iCloud Status**, and
  resolve every **Waiting to Upload**, **Out of Space**, or **Ineligible** item.
- [ ] Verify representative files on iCloud.com or another trusted device. If a
  critical folder is cloud-only, use **Keep Downloaded** before the final Time
  Machine backup.
- [ ] Decide explicitly what must survive from Desktop, Documents, Downloads,
  Projects, Photos, local mail, Messages, Obsidian vaults, browser bookmarks,
  local databases, containers/VMs, VPN profiles, fonts, and licensed apps.
- [ ] For each important dirty Git repository, commit and push intentional work,
  or capture it in the encrypted backup. Do not assume GitHub has uncommitted or
  untracked files.
- [ ] Confirm the backup does not exist only on the internal disk. Time Machine
  local snapshots disappear with the Mac's internal storage.

Apple references: [Time Machine](https://support.apple.com/en-us/104984),
[supported backup disks](https://support.apple.com/en-lamr/102423),
[network-disk setup](https://support.apple.com/en-ie/guide/mac-help/mh15139/mac),
[iCloud Drive setup](https://support.apple.com/en-us/118443), and
[iCloud status meanings](https://support.apple.com/en-ke/guide/mac-help/mchlc994344b/mac).
TrueNAS reference: [Time Machine SMB share](https://www.truenas.com/docs/scale/26/shares/smb/setupbasictimemachinesmbshare/).

## Phase 2: prevent account lockout

Never save passwords, recovery codes, TOTP seeds, private keys, or temporary
tokens in this repository or the preflight report.

- [ ] **Password manager / Apple Passwords:** prove the vault opens on a device
  that will not be erased. Confirm its master password, recovery/emergency kit,
  and a second recovery path. If using Apple Passwords, verify **Passwords &
  Keychain > Sync this device** on another trusted Apple device.
- [ ] **Apple Account:** prove the password works at account.apple.com from a
  private window. Confirm a remaining trusted device and trusted phone number
  can receive a code. Add a recovery contact if appropriate. If Security Keys
  are enabled, Apple requires at least two; store them separately.
- [ ] **Primary email / Google:** prove sign-in from another device. Verify a
  recovery email/phone plus a second strong method. Generate fresh backup codes
  and keep an offline copy; do not keep the only copy in Downloads on this Mac.
- [ ] **GitHub:** verify 2FA, at least two methods, a synced passkey or two
  device-bound keys, and fresh recovery codes in a durable secure location.
  GitHub Support cannot restore an account that has lost both 2FA and all
  recovery methods.
- [ ] **OpenAI:** verify MFA and another sign-in method. A passkey stored only on
  this Mac is not sufficient. If Advanced Account Security is enabled, retain
  the recovery keys and at least two secure methods.
- [ ] Repeat the same proof for AWS, Google Cloud, domain registrars, banking,
  brokerage, social accounts, and any service that can reset the others.
- [ ] Keep the phone, its passcode, charging cable, hardware security keys,
  backup codes, Wi-Fi password, and Apple Account password physically available
  during setup.

Authentication references: [Apple two-factor authentication](https://support.apple.com/en-us/102660),
[Apple verification codes](https://support.apple.com/en-us/102606),
[Apple security keys](https://support.apple.com/en-us/102637),
[GitHub recovery methods](https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa/configuring-two-factor-authentication-recovery-methods),
[Google backup codes](https://support.google.com/accounts/answer/1187538), and
[OpenAI passkeys](https://help.openai.com/en/articles/20001039-passkeys-to-secure-your-openai-account).

## Phase 3: prove the clean bootstrap

- [ ] Commit and push the hardened recovery work, or merge it into the default
  branch. Record the exact reviewed commit SHA; a local-only branch is not a
  recovery path.
- [ ] From another device or a disposable directory, clone
  `https://github.com/FrankLong1/setup_agents_mac`, check out that exact SHA,
  run the contract tests, and confirm the lean setup files exist.
- [ ] Review the lean default Brewfile. The historical everything-list is kept
  as `personal-full.Brewfile` and requires explicit `--full`; do not use it on
  day one unless every item is still justified. Use
  [BREWFILE_GUIDE.md](BREWFILE_GUIDE.md) for the capture, admission, validation,
  and cleanup workflow.
- [ ] Record licensed/manual apps in `MANUAL_APPS.md`, without license keys.
- [ ] Export only non-secret installed-state inventory with
  `./migration/capture-state.sh` and place the output in the encrypted backup.
- [ ] Have a second internet-capable device available to read this runbook if
  the Mac cannot activate or join Wi-Fi.

## Phase 4: erase only after the gate is green

This Mac is Apple silicon. Prefer Apple's Erase Assistant: **Apple menu > System
Settings > General > Transfer or Reset > Erase All Content and Settings**. Keep
the Mac on power and connected to the internet. Be prepared to enter the Apple
Account password for activation.

Do not use Disk Utility as the first path when Erase Assistant is available.
Disk Utility is the recovery path for cases where Erase Assistant is unavailable
or Apple Support specifically directs it. Apple's instructions warn that erase
permanently deletes the files on the Mac.

Apple references: [Erase Assistant from macOS Recovery guidance](https://support.apple.com/guide/mac-help/macos-recovery-a-mac-apple-silicon-mchl82829c17/mac)
and [erase an Apple-silicon Mac with Disk Utility](https://support.apple.com/en-us/102506).

## Phase 5: rebuild cleanly

1. During Setup Assistant, sign in with the proven Apple Account and trusted
   second factor. Prefer setting up as a new Mac rather than a full Migration
   Assistant restore if the purpose is to eliminate accumulated system state.
2. Install macOS updates, then Xcode Command Line Tools if prompted.
3. Clone this repository and check out the exact commit SHA proved before the
   erase. Run only the layers that reached the required rehearsal gate; do not
   trust an unrecorded moving branch or an M1-only prototype:

   ```bash
   git clone https://github.com/FrankLong1/setup_agents_mac.git
   cd setup_agents_mac
   git checkout <REVIEWED_RECOVERY_COMMIT_SHA>
   python3 -m unittest discover -s tests -v
   ./setup.sh --profile personal
   ./verify.sh --profile personal
   ```

4. Clone `gv_gcp_setup`; from its root use the repository's canonical auth flow:

   ```bash
   scripts/auth-repo.sh status --profile standard
   scripts/auth-repo.sh login --profile standard
   ```

5. Restore documents selectively. Do not copy old `~/Library`, browser session
   state, GitHub CLI tokens, cloud credentials, or shell permission-bypass
   aliases wholesale.
6. Generate new SSH keys when practical. If an old private key is truly needed,
   restore it only from the reviewed encrypted backup with correct permissions.
7. Re-enroll passkeys and trusted-device methods on the new Mac. Remove the old
   Mac or stale device-bound credentials from accounts only after new sign-in
   paths work.
8. Add optional applications in small batches. Use `--full` only as a reviewed
   reference, not as the default recovery action.
9. Rerun `./verify.sh --profile personal`, confirm Time Machine resumes, and
   repeat the four-account sign-in fire drill before declaring recovery done.

## Go / no-go record

- [ ] Automated preflight has no blockers.
- [ ] Fresh Time Machine backup completed and a test file restored.
- [ ] Independent second copy verified.
- [ ] iCloud statuses and representative remote files verified.
- [ ] Dirty/unpushed Git work resolved or independently protected.
- [ ] Password manager, Apple Account, primary email, and GitHub fire drills passed.
- [ ] Two independent recovery methods exist for every account that can reset another.
- [ ] Hardened setup work is committed and pushed or merged, its exact SHA is
  recorded off-Mac, and a clean-clone test of that SHA passed from another device.
- [ ] The user explicitly says **go** after reviewing this record.

If any box is unchecked, the decision is **NO-GO**.
