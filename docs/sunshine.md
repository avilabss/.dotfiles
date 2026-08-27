# Sunshine on an unattended Fedora host

This guide prepares one unattended Fedora machine to stream its KDE Plasma
Wayland desktop through Sunshine to Moonlight. It assumes an NVIDIA GPU, SDDM,
and a dummy HDMI or DisplayPort plug. Complete the steps locally before relying
on remote access.

The result is not a display-free Wayland host. SDDM automatically starts a real
Plasma session for a dummy display, and Sunshine captures that session with
KMS.

> **Security warning.** Automatic login gives anyone with physical access an
> unlocked desktop after boot. KMS also gives the Sunshine executable access to
> `CAP_SYS_ADMIN`, a broad Linux capability. Use this setup only on
> a physically controlled host, keep Sunshine off the public internet, and
> follow the rollback steps if unattended access is no longer required.

## Before you begin

Confirm all of these assumptions:

- Fedora KDE Plasma is installed and SDDM is the active display manager.
- The NVIDIA driver works, DRM modesetting is enabled, and the dummy plug is
  connected to the NVIDIA GPU before boot.
- The host and Moonlight client can reach each other on a trusted network.
- You can use the host locally for initial setup and recovery.
- You accept that a graphical login and an active dummy display are required.

Check the driver, display manager, and DRM modesetting before making changes:

```bash
nvidia-smi
systemctl status display-manager.service
cat /sys/module/nvidia_drm/parameters/modeset
```

The final command should print `Y`. Fix the NVIDIA installation or modesetting
before continuing if any check fails. In **System Settings → Display & Monitor**,
verify that Plasma detects the dummy display, then choose its resolution,
refresh rate, scale, and primary-display status.

Record the current SDDM, power-management, screen-locking, display, Sunshine
capture, and service settings. You will need those values for rollback.

## What the Ansible role handles

Before installation, choose the exact trusted URL that will open the web UI.
The repository's existing `sunshine_csrf_allowed_origins` entry is a
machine-specific example, not a reusable default. Replace it in
`ansible/group_vars/all.yml` unless it already matches this host:

```yaml
sunshine_csrf_allowed_origins:
  - https://<host-ip>:47990
```

Use the stable LAN IP address or local DNS name that the browser will use.
Include `https://` and port `47990`. Add only origins you trust, and record the
previous list for rollback. If you need more than one trusted host name, add a
YAML list item for each one rather than allowing a broad network origin.

Also record whether firewalld and the two Sunshine rules exist before the role
runs. Query the active daemon when available, or query the permanent
configuration offline when the service is inactive:

```bash
systemctl is-enabled firewalld
systemctl is-active firewalld
if systemctl is-active --quiet firewalld; then
  FIREWALL_ZONE="$(sudo firewall-cmd --get-default-zone)"
  sudo firewall-cmd --permanent --zone="$FIREWALL_ZONE" \
    --query-port=47984-47990/tcp
  sudo firewall-cmd --permanent --zone="$FIREWALL_ZONE" \
    --query-port=47998-48000/udp
elif command -v firewall-offline-cmd >/dev/null; then
  FIREWALL_ZONE="$(sudo firewall-offline-cmd --get-default-zone)"
  sudo firewall-offline-cmd --zone="$FIREWALL_ZONE" \
    --query-port=47984-47990/tcp
  sudo firewall-offline-cmd --zone="$FIREWALL_ZONE" \
    --query-port=47998-48000/udp
else
  printf '%s\n' 'firewalld absent; both rules are absent'
fi
printf 'default zone: %s\n' "${FIREWALL_ZONE:-not installed}"
```

Record whether firewalld is enabled and active, the default zone, and each `yes`
or `no` query result. Do not treat a failed daemon query as `no`. Use the
offline branch. From the dotfiles repository, install the optional Sunshine
role:

```bash
./bootstrap.sh --tags sunshine
```

On Fedora, the role does the following:

- Enables the configured LizardByte COPR and installs the native `Sunshine` RPM.
- Installs and starts firewalld.
- Opens Sunshine's configured TCP and UDP port ranges.
- Writes the configured web UI origin to
  `~/.config/sunshine/sunshine.conf`.
- Enables and starts the canonical
  `app-dev.lizardbyte.app.Sunshine.service` user service.

If the COPR or package is unavailable for the Fedora release or architecture,
bootstrap warns and continues. Confirm that the native package and canonical
unit are present before proceeding:

```bash
rpm -q Sunshine
command -v sunshine
systemctl --user is-enabled app-dev.lizardbyte.app.Sunshine.service
systemctl --user is-active app-dev.lizardbyte.app.Sunshine.service
grep '^csrf_allowed_origins' ~/.config/sunshine/sunshine.conf
```

The final output must contain the exact origin selected above. Use that same
origin for every web UI step in this guide.

Do not substitute Flatpak or AppImage for this setup. Current upstream builds
of those package types do not support KMS capture; the native RPM does.

The role does not configure NVIDIA, the dummy display, SDDM automatic login,
Plasma power behavior, KMS selection, or Moonlight pairing. Complete those steps
below.

## Enable a Plasma Wayland login

A Wayland compositor does not run at the login screen. SDDM automatic login is
what creates the unattended Plasma session that Sunshine captures.

### Preferred method in KDE System Settings

1. Open **System Settings** and search for **Login Screen (SDDM)**.
2. Open its behavior or advanced settings. The exact page name varies with the
   Plasma version.
3. Enable automatic login, select the intended local account, and select the
   **Plasma (Wayland)** session.
4. Apply the change and authenticate when prompted.

This avoids guessing the installed session file name. Do not use automatic
login on a machine that is not physically secure. The account password no
longer blocks local access after boot.

### Manual SDDM fallback

Use this only when the System Settings module is unavailable. First list the
installed Wayland sessions:

```bash
ls -1 /usr/share/wayland-sessions/*.desktop
```

Session names vary across Fedora and Plasma versions. Use the basename of the
Plasma Wayland file shown on this host, including `.desktop`, in place of
`<session-file>`. Use the account that will own the graphical session in place
of `<username>`.

Create a dedicated drop-in without modifying vendor files. Check that this
guide's path is unused **before** opening an editor:

```bash
sudo install -d -m 0755 /etc/sddm.conf.d
if sudo test -e /etc/sddm.conf.d/90-sunshine-autologin.conf; then
  printf '%s\n' 'Existing SDDM drop-in found; stop and preserve it.'
else
  sudoedit /etc/sddm.conf.d/90-sunshine-autologin.conf
fi
```

If the command reports an existing drop-in, stop. Do not overwrite or later
delete that file; use the System Settings method or inspect and preserve the
existing local SDDM configuration instead.

Add:

```ini
[Autologin]
User=<username>
Session=<session-file>
Relogin=false
```

Reboot while local recovery is still available. In the automatically logged-in
session, verify that it is Wayland:

```bash
printf '%s\n' "$XDG_SESSION_TYPE"
loginctl session-status
```

The type should be `wayland`, and the session should be active and local.

## Keep the graphical session available

In **System Settings → Power Management**, adjust the active AC-power profile
for an unattended host. Some Plasma versions call this page **Energy Saving**.

1. Prevent automatic system sleep, suspend, and hibernation.
2. Set inactivity and lid actions, when present, so they do not end the session.
3. Decide whether the display may power off. If powering it off makes the dummy
   output disappear, leave the output enabled.
4. Review automatic screen locking. A lock screen can block unattended control
   or capture on some versions. Disabling it improves availability but further
   weakens physical security. Test the selected policy rather than assuming it
   works remotely.

Reboot once more and confirm that the dummy display still appears in **Display
& Monitor** and that the Plasma session remains available after the configured
idle interval.

## Select and verify KMS capture

Open Sunshine's web UI at `https://<host-ip>:47990`. The certificate is
self-signed, so a browser warning is expected. Verify that the address is the
intended host before accepting it. Create the initial Sunshine credentials if
prompted, then set the capture method to **KMS** in the audio/video
configuration and save the change.

You can make the same setting directly by ensuring this line is present in
`~/.config/sunshine/sunshine.conf`:

```ini
capture = kms
```

### Verify package permissions

The current native RPM records the required capabilities on the real Sunshine
binary. Inspect them instead of applying an old unconditional workaround:

```bash
SUNSHINE_BIN="$(readlink -f "$(command -v sunshine)")"
getcap "$SUNSHINE_BIN"
```

The output must include `cap_sys_admin` in the permitted set. Current packages
also include `cap_sys_nice`. `CAP_SYS_ADMIN` grants access to many privileged
kernel operations beyond display capture. Do not grant it to a Flatpak,
AppImage, wrapper script, or an unverified executable.

If the native RPM is installed but the capability is missing, first restore
the package-owned metadata and check again:

```bash
sudo dnf reinstall Sunshine
SUNSHINE_BIN="$(readlink -f "$(command -v sunshine)")"
getcap "$SUNSHINE_BIN"
```

Only if the installed package still lacks the capability and Sunshine's log
explicitly reports that KMS needs it, apply the upstream capability set to the
resolved native binary and immediately verify it:

```bash
SUNSHINE_BIN="$(readlink -f "$(command -v sunshine)")"
sudo setcap cap_sys_admin,cap_sys_nice+p "$SUNSHINE_BIN"
getcap "$SUNSHINE_BIN"
```

Package upgrades replace the binary and therefore may change its capabilities.
Recheck with `getcap`; do not assume a manual repair survives an update.

### Verify the service restrictions

The current native unit does not set `NoNewPrivileges=true`, so it normally
needs no service override. Inspect the effective unit and property:

```bash
systemctl --user cat app-dev.lizardbyte.app.Sunshine.service
systemctl --user show app-dev.lizardbyte.app.Sunshine.service \
  -p NoNewPrivileges
```

If the property is `NoNewPrivileges=yes`, locate the older or local drop-in
shown by `systemctl --user cat`. Remove that stale override when it is yours.
Add the narrowly scoped, guide-owned override below only when another required
drop-in cannot be removed. Check that its unique path is unused before creating
it:

```bash
SUNSHINE_DROPIN="$HOME/.config/systemd/user/app-dev.lizardbyte.app.Sunshine.service.d"
if test -e "$SUNSHINE_DROPIN/zz-sunshine-kms.conf"; then
  printf '%s\n' 'Existing Sunshine drop-in found; stop and preserve it.'
else
  mkdir -p "$SUNSHINE_DROPIN"
  ${EDITOR:-vi} "$SUNSHINE_DROPIN/zz-sunshine-kms.conf"
fi
```

If the command reports an existing drop-in, stop and preserve it. Otherwise
add:

```ini
[Service]
NoNewPrivileges=false
```

Do not copy older overrides that change the command, run Sunshine as root, or
replace the package's restart policy. After the daemon reload in the next
section, repeat the `systemctl --user show ... -p NoNewPrivileges` check and
confirm it reports `NoNewPrivileges=no`.

## Restart and test Sunshine

Reload user units in case a drop-in changed, then enable and restart the
canonical service:

```bash
systemctl --user daemon-reload
systemctl --user enable --now app-dev.lizardbyte.app.Sunshine.service
systemctl --user restart app-dev.lizardbyte.app.Sunshine.service
systemctl --user --no-pager --full status \
  app-dev.lizardbyte.app.Sunshine.service
journalctl --user --unit app-dev.lizardbyte.app.Sunshine.service \
  --boot --no-pager
```

The log should identify KMS capture and list the dummy display without a
capability, framebuffer, encoder, or display error. Always use the canonical
unit name in commands. `sunshine.service` is only a convenience alias created
when the package unit is enabled.

## Pair Moonlight

1. Install Moonlight on a client connected to the trusted network.
2. Let it discover the host, or add `<host-ip>` manually.
3. Select the host to display a pairing PIN.
4. Sign in to `https://<host-ip>:47990`, open **PIN**, enter the Moonlight PIN,
   and give the client a recognizable name.
5. Start **Desktop** in Moonlight and test video, audio, keyboard, mouse, and a
   controller if used.

Do not forward Sunshine or web UI ports directly from an internet router.

## Roll back the manual setup

Restore the values recorded at the start of this guide, in this order:

1. **Stop remote use.** Disconnect Moonlight so session changes do not interrupt
   active work.
2. **Revoke the pairing.** In Sunshine's **Troubleshooting** page, find the
   paired-client list and unpair the named Moonlight client. Use **Unpair all**
   if the relevant entry cannot be identified. Then remove or forget the host
   in Moonlight. Disconnecting by itself does not revoke the client's
   certificate.
3. **Restore Sunshine capture.** In the web UI, return the capture method to its
   previous value, which is normally automatic. You can instead remove only the
   `capture = kms` line that this guide added.
4. **Remove the conditional service override.** If this guide created it, run:

   ```bash
   rm -f ~/.config/systemd/user/app-dev.lizardbyte.app.Sunshine.service.d/zz-sunshine-kms.conf
   rmdir --ignore-fail-on-non-empty \
     ~/.config/systemd/user/app-dev.lizardbyte.app.Sunshine.service.d
   systemctl --user daemon-reload
   systemctl --user restart app-dev.lizardbyte.app.Sunshine.service
   ```

5. **Restore package capabilities.** If you ran `setcap`, reinstall the RPM so
   its package-owned capability metadata is authoritative again:

   ```bash
   sudo dnf reinstall Sunshine
   ```

   Do not use `setcap -r` as a general rollback while keeping this RPM; current
   native packages intentionally ship the capability required by KMS.
6. **Restore Plasma settings.** Return power, idle, lock-screen, and display
   settings to the values recorded before setup.
7. **Restore automatic login.** In KDE System Settings, restore the recorded
   enabled state, account, and session. Disable automatic login only if it was
   disabled before this guide. If this guide created the manual fallback file,
   remove that file only; any lower-priority pre-existing SDDM configuration
   will then take effect again:

   ```bash
   sudo rm -f /etc/sddm.conf.d/90-sunshine-autologin.conf
   ```

8. **Restore the allowed-origin list.** Put the previously recorded
   `sunshine_csrf_allowed_origins` list back in `ansible/group_vars/all.yml`. If
   Sunshine remains installed, rerun `./bootstrap.sh --tags sunshine` locally
   and verify the resulting `csrf_allowed_origins` line.
9. Reboot and verify that SDDM asks for credentials and no unattended Plasma
   session starts. Remove the dummy plug after the host no longer depends on it.

To uninstall Sunshine as well, disable its user unit and remove the package:

```bash
systemctl --user disable --now app-dev.lizardbyte.app.Sunshine.service
sudo dnf remove Sunshine
```

Remove a firewall rule only if the pre-install query reported `no` (or
firewalld was absent), and only after confirming no other service now relies on
that range:

```bash
sudo firewall-cmd --permanent --zone=<recorded-zone> \
  --remove-port=47984-47990/tcp
sudo firewall-cmd --permanent --zone=<recorded-zone> \
  --remove-port=47998-48000/udp
sudo firewall-cmd --reload
```

If firewalld itself was disabled or inactive before installation, restore that
state only after confirming no other installed service now relies on it.

You may disable the repository with
`sudo dnf copr disable lizardbyte/beta` if you no longer need it. Keep or remove
`~/.config/sunshine/` according to whether you still need the credentials and
application settings. The directory contains user data, so do not delete it
blindly.

## Troubleshooting by symptom

| Symptom | Check |
|---|---|
| Boot stops at SDDM | Disable automatic login from a local console; confirm the configured user exists and the `Session` value matches a file under `/usr/share/wayland-sessions/` |
| Session is X11, not Wayland | Select Plasma Wayland in the SDDM System Settings module or correct the version-specific session filename in the local drop-in |
| Moonlight shows a black screen after idle | Confirm the Plasma session is active, the dummy output is still enabled, and power or lock-screen policy did not hide the session |
| Log says no display or the KMS monitor list is empty | Reseat the dummy plug, check **Display & Monitor**, and confirm NVIDIA DRM modesetting still prints `Y` |
| Log reports `CAP_SYS_ADMIN` or framebuffer permission errors | Confirm this is the native RPM, run `getcap` on the resolved binary, inspect `NoNewPrivileges`, and use the conditional repair steps above |
| Service name is not found | Use `app-dev.lizardbyte.app.Sunshine.service`; inspect installed units with `systemctl --user list-unit-files '*Sunshine*'` |
| Web UI is unreachable | Check the canonical service, use the host address allowed by the repository's `sunshine_csrf_allowed_origins`, and inspect firewalld without exposing the port publicly |
| Host does not appear in Moonlight | Add `<host-ip>` manually, verify both devices can reach each other, and confirm the role's TCP/UDP rules are active |
| KMS breaks after an update | Re-run `getcap`, inspect the current unit, and review the current package or upstream release notes before reapplying any manual repair |

Current upstream references: [Sunshine getting
started](https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2getting__started.html),
[capture configuration](https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2configuration.html),
and [troubleshooting](https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2troubleshooting.html).
