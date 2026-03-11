# Sunshine Headless Setup (NVIDIA + GNOME Wayland + Fedora)

Setup for running Sunshine game streaming server headlessly on an NVIDIA GPU with GNOME Wayland. This allows remote gaming via Moonlight without a physical display or physical login.

## Why these changes are needed

- **Auto-login**: GNOME doesn't start without someone logging in. Sunshine needs a desktop session.
- **KMS capture**: On Wayland, Sunshine normally uses the XDG portal for screen capture, which pops up a permission dialog. With no one at the screen, the dialog goes unanswered and Sunshine hangs. KMS capture bypasses the portal entirely.
- **CAP_SYS_ADMIN**: Required for KMS capture to access DRM/KMS framebuffers.
- **NoNewPrivileges=false**: The default Sunshine service sets `NoNewPrivileges=true`, which blocks capabilities like CAP_SYS_ADMIN from being used.
- **Dummy HDMI plug**: NVIDIA's KMS doesn't enumerate monitors without a physical (or dummy) display connected. A ~$5 HDMI dummy plug tricks the GPU into reporting a real display with proper EDID (4K 120Hz etc).

## Prerequisites

- Dummy HDMI plug connected to the GPU
- Sunshine installed via RPM (not Flatpak)

## Setup

### 1. Enable GDM auto-login

Edit `/etc/gdm/custom.conf` and add under the `[daemon]` section:

```ini
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=avi
```

### 2. Set CAP_SYS_ADMIN on the Sunshine binary

```bash
sudo setcap cap_sys_admin+ep $(readlink -f /usr/bin/sunshine)
```

> Note: This must be re-run after every Sunshine update since the binary gets replaced.

### 3. Configure Sunshine to use KMS capture

Edit `~/.config/sunshine/sunshine.conf`:

```ini
capture = kms
```

### 4. Override the Sunshine systemd service

Create/edit `~/.config/systemd/user/sunshine.service.d/override.conf`:

```ini
[Service]
Restart=always
RestartSec=5
NoNewPrivileges=false
```

Then reload:

```bash
systemctl --user daemon-reload
systemctl --user restart sunshine.service
```

## Removal

### 1. Remove GDM auto-login

Edit `/etc/gdm/custom.conf` and remove (or comment out) the two lines:

```ini
# AutomaticLoginEnable=True
# AutomaticLogin=avi
```

### 2. Remove CAP_SYS_ADMIN from the Sunshine binary

```bash
sudo setcap -r $(readlink -f /usr/bin/sunshine)
```

### 3. Remove KMS capture config

Delete the `capture = kms` line from `~/.config/sunshine/sunshine.conf`, or delete the file if that's the only line.

### 4. Remove the service override

Delete the override file and reload:

```bash
rm ~/.config/systemd/user/sunshine.service.d/override.conf
systemctl --user daemon-reload
systemctl --user restart sunshine.service
```

## Troubleshooting

- **Sunshine logs**: `journalctl --user -u sunshine.service --boot -0 --no-pager`
- **Check KMS monitor list**: Look for `Start of KMS monitor list` in logs. If empty, the dummy plug isn't detected or isn't connected.
- **CAP_SYS_ADMIN not working**: Check that `NoNewPrivileges=false` is in the override and that `setcap` was run on the real binary path (follow the symlink with `readlink -f`).
- **Sunshine updated and KMS stopped working**: Re-run the `setcap` command from step 2.
