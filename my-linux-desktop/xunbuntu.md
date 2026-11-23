# Xubuntu 24.04 (Xfce) desktop changes

## 2026-11-23

### Android phone (Samsung) file transfer over USB
- Issue: phone in "File transfer" (MTP) mode was detected by `lsusb` but did not show up in the file manager.
- Installed `gvfs-backends` (MTP support for GVFS) and `mtp-tools`.
- Restarted Thunar (`thunar -q`) so the phone appears under **Devices**.
- Phone must be unlocked for its storage to be visible.

### Thumbnails / previews
- Set Thunar to show thumbnails everywhere: `xfconf-query -c thunar -p /misc-thumbnail-mode -n -t string -s THUNAR_THUMBNAIL_MODE_ALWAYS`.
- Installed `tumbler-plugins-extra` and `ffmpegthumbnailer` for video thumbnails.
- Thunar 4.18 still does not show previews for files on the phone (MTP), but they work for local files.

### Nautilus for browsing the phone with previews
- Installed `nautilus` alongside Thunar (Thunar is still the default file manager).
- Turned on previews for all files: `gsettings set org.gnome.nautilus.preferences show-image-thumbnails 'always'`.
- Dark mode: Xfce doesn't pass the dark setting to libadwaita apps, so `ADW_DEBUG_COLOR_SCHEME=prefer-dark` is added in:
  - `~/.local/share/applications/org.gnome.Nautilus.desktop` (menu launcher)
  - `~/.local/share/dbus-1/services/org.gnome.Nautilus.service` (when another app starts it in the background)

### Newer file picker in browsers (Brave)
- Issue: the old GTK3 file picker only has a list view with tiny previews and no zoom.
- Installed `xdg-desktop-portal-gnome` (GTK4 file picker with a grid view).
- Use it for file pickers only, everything else stays GTK: `~/.config/xdg-desktop-portal/xfce-portals.conf`
  ```
  [preferred]
  default=gtk
  org.freedesktop.impl.portal.FileChooser=gnome
  ```
- Copied `xdg-desktop-portal-gnome.service` into `~/.config/systemd/user/` without the `graphical-session.target` lines, which Xfce doesn't start.
- The preview size can't be changed in this picker (Ubuntu 24.04). For bigger previews, drag files from Nautilus into the browser.
- The install pulled in GNOME Shell and gdm3 as recommended packages. Kept `lightdm` as the display manager, then removed:
  `gdm3 gnome-shell gnome-shell-common yaru-theme-gnome-shell gnome-session-bin gnome-session-common gnome-control-center gnome-control-center-data gnome-control-center-faces ubuntu-session gnome-startup-applications`
- Tip: use `apt-get install --no-install-recommends xdg-desktop-portal-gnome` to avoid pulling in GNOME Shell and gdm3.

### Photo and video viewer with next/previous (like Windows Photos)
- Issue: Ristretto and Parole were still set as defaults but weren't installed.
- Installed `gthumb` (shows photos and videos in one viewer, arrow keys for next/previous) plus `gstreamer1.0-gtk3` and `gstreamer1.0-plugins-bad` for video playback, using `--no-install-recommends`.
- Made gThumb the default for common photo and video types: `xdg-mime default org.gnome.gThumb.desktop image/jpeg video/mp4 ...`
