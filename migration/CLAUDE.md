# Installed-State Capture

Capture the current Mac's installed software inventory:

```bash
./migration/capture-state.sh
```

The default destination is `~/mac-setup-inventory/<UTC timestamp>`. The capture includes a Brewfile, application names, font names, editor-extension lists, npm global-package metadata, and basic system information.

It deliberately excludes SSH keys, credentials, shell secrets, user documents, and application databases. Compare the generated Brewfile with `setup/profiles/personal.Brewfile`; do not blindly replace the curated profile.
