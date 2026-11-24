#!/bin/bash
# Enable hibernate on Xubuntu 24.04 with an ext4 swap file (/swap.img).
# Usage: sudo bash xubuntu_enable_hibernate.sh [swap size in GiB, default 32]
set -euo pipefail

SWAP=/swap.img
SIZE_GB="${1:-32}"

[ "$(id -u)" -eq 0 ] || { echo "Run with sudo"; exit 1; }
[ "$(findmnt -no FSTYPE -T /)" = ext4 ] || { echo "Root filesystem is not ext4, stopping"; exit 1; }

echo "== 1. Resize swap file to ${SIZE_GB}G"
swapoff "$SWAP" 2>/dev/null || true
rm -f "$SWAP"
fallocate -l "${SIZE_GB}G" "$SWAP"
chmod 600 "$SWAP"
mkswap "$SWAP" >/dev/null
swapon "$SWAP"
grep -q "^$SWAP" /etc/fstab || echo "$SWAP none swap sw 0 0" >> /etc/fstab

echo "== 2. Find resume location"
UUID=$(findmnt -no UUID -T "$SWAP")
OFFSET=$(filefrag -v "$SWAP" | awk '$1=="0:" {sub(/\.\./,"",$4); print $4; exit}')
[ -n "$UUID" ] && [ -n "$OFFSET" ] || { echo "Could not find UUID/offset"; exit 1; }
echo "   resume=UUID=$UUID resume_offset=$OFFSET"

echo "== 3. Add resume settings to GRUB"
cp -n /etc/default/grub /etc/default/grub.bak-before-hibernate
sed -i -E 's/ ?resume(_offset)?=[^" ]*//g' /etc/default/grub
sed -i -E "s/^GRUB_CMDLINE_LINUX_DEFAULT=\"([^\"]*)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\1 resume=UUID=$UUID resume_offset=$OFFSET\"/" /etc/default/grub
grep ^GRUB_CMDLINE_LINUX_DEFAULT /etc/default/grub
update-grub

echo "== 4. Add resume settings to initramfs"
echo "RESUME=UUID=$UUID resume_offset=$OFFSET" > /etc/initramfs-tools/conf.d/resume
update-initramfs -u -k all

echo "== 5. Allow Hibernate in the log-out menu"
cat > /etc/polkit-1/rules.d/85-allow-hibernate.rules <<'EOF'
polkit.addRule(function(action, subject) {
    if ((action.id == "org.freedesktop.login1.hibernate" ||
         action.id == "org.freedesktop.login1.hibernate-multiple-sessions" ||
         action.id == "org.freedesktop.login1.handle-hibernate-key") &&
        subject.local && subject.active && subject.isInGroup("sudo")) {
        return polkit.Result.YES;
    }
});
EOF
systemctl restart polkit

echo "== Done. Reboot once so the new boot settings take effect."
echo "HIBERNATE_SETUP_DONE"
