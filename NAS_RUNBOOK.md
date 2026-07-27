# TrueNAS + Tailscale runbook

Use this runbook to attach this Mac to the home TrueNAS as persistent SMB
storage. It is written for an agent operating the Mac; never request or store
the user’s passwords in the repository, shell history, or chat.

## Current topology

| Item | Value |
| --- | --- |
| TrueNAS LAN UI | `http://192.168.50.222` |
| TrueNAS Tailscale host | `truenas-scale.tailbe754a.ts.net` |
| TrueNAS Tailscale IP | `100.68.72.115` |
| SMB data shares | `shared_data`, `frank_data` |
| SMB user | `frank` (non-admin share account) |
| Auto-mount job | `com.frank.nas-mount-doctor` |

Prefer the MagicDNS hostname in all SMB URLs. It works both at home and away
when Tailscale is connected. Do not expose SMB (TCP 445) to the public
internet.

## Desired state

- Finder mounts both shares at `/Volumes/shared_data` and
  `/Volumes/frank_data`.
- The macOS login Keychain holds the SMB credential; no plaintext password is
  present in this repository or in the doctor configuration.
- `com.frank.nas-mount-doctor` runs at login and every five minutes. It asks
  Finder to reconnect a missing share after Wi-Fi, Tailscale, or the NAS comes
  back.
- Time Machine is a **separate** SMB share/dataset and is not one of the two
  general-purpose data shares.

## Initial setup

1. Verify Tailscale is running and the NAS is online:

   ```bash
   /Applications/Tailscale.app/Contents/MacOS/Tailscale status
   /Applications/Tailscale.app/Contents/MacOS/Tailscale ping truenas-scale.tailbe754a.ts.net
   ```

2. Open Finder’s SMB sign-in dialog. Let the user enter the non-admin SMB
   username and password, then select **Remember this password in my keychain**:

   ```bash
   open 'smb://truenas-scale.tailbe754a.ts.net/'
   ```

   Do not ask the user to paste that password into chat or a terminal.

3. Confirm both shares mount. If Finder presents a share list, select
   `shared_data` and `frank_data`.

4. Review or recreate the local-only doctor configuration:

   ```bash
   cp nas/mount-doctor.env.example nas/mount-doctor.local.env
   ```

   Its required values are:

   ```bash
   NAS_DATA_URLS=(
     "smb://frank@truenas-scale.tailbe754a.ts.net/shared_data"
     "smb://frank@truenas-scale.tailbe754a.ts.net/frank_data"
   )
   ```

5. Validate and install the doctor:

   ```bash
   ./nas/mount-doctor.sh
   ./nas/install-mount-doctor.sh
   ```

The installer creates the per-user file
`~/Library/LaunchAgents/com.frank.nas-mount-doctor.plist`. The configuration is
intentionally Git-ignored.

## Verification checklist

Run these non-disruptive checks. They do not disconnect shares or reveal a
password.

```bash
/Applications/Tailscale.app/Contents/MacOS/Tailscale ping --timeout=5s truenas-scale.tailbe754a.ts.net
nc -G 5 -z truenas-scale.tailbe754a.ts.net 445
mount | rg 'truenas-scale\.tailbe754a\.ts\.net/(shared_data|frank_data)'
launchctl print "gui/$(id -u)/com.frank.nas-mount-doctor"
tail -n 30 ~/Library/Logs/nas-mount-doctor.log
```

Expected results:

- Tailscale returns a `pong` from `100.68.72.115`.
- TCP port 445 succeeds.
- Both shares appear as `smbfs` mounts.
- The LaunchAgent shows `last exit code = 0` and `run interval = 300 seconds`.

Avoid unmounting a live share merely to test reconnect behavior; the doctor can
be run manually and reports mounted shares without disruption.

## Recovery

If a share is missing:

1. Confirm Tailscale is connected and the NAS responds to the ping above.
2. Run `./nas/mount-doctor.sh`.
3. If Finder asks for credentials, have the user enter the share-account
   password and save it to Keychain.
4. If SMB rejects authentication, log into TrueNAS as an administrator and
   check the non-admin SMB user, its dataset ACL, and the SMB share. Do not use
   the TrueNAS admin account for routine Finder mounts.
5. Inspect `~/Library/Logs/nas-mount-doctor.log` and the LaunchAgent status.

## Time Machine (deferred)

Create a dedicated TrueNAS child dataset and SMB share with the **Time Machine
Share** purpose. Enable the Apple SMB2/3 protocol extension in the TrueNAS SMB
service, then select that share in **System Settings → General → Time Machine**.
Set a backup size limit in macOS if offered. Do not point Time Machine at
`shared_data` or `frank_data`.

TrueNAS share configuration requires an administrator login in the TrueNAS UI;
the Time Machine user may still be a dedicated non-admin SMB account.
