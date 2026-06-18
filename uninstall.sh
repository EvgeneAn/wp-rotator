#!/bin/bash

DEFAULT_PROJECT_ROOT="$HOME/snap/wp-rotator"
WP_PROJECT_ROOT="${WP_PROJECT_ROOT:-$DEFAULT_PROJECT_ROOT}"
SYSTEMD_DIR="$HOME/.config/systemd/user"

echo "============================================="
echo " Uninstalling GNOME Multi-Monitor Wall Rotator"
echo "============================================="

# 1. Stop and disable the Systemd Timer loop safely
echo "🛑 Stopping and disabling background timer..."
if systemctl --user is-active --quiet wp-rotate.timer; then
    systemctl --user stop wp-rotate.timer
fi

if systemctl --user is-enabled --quiet wp-rotate.timer 2>/dev/null; then
    systemctl --user disable wp-rotate.timer
fi

# 2. DELETE the copied configuration files entirely from Systemd
echo "🧹 Wiping configuration files from Systemd directory..."
rm -f "$SYSTEMD_DIR/wp-rotate.timer"
rm -f "$SYSTEMD_DIR/wp-rotate.service"
rm -f "$SYSTEMD_DIR/wp-rotate.env"
rm -rf "$SYSTEMD_DIR/wp-rotate.timer.d"

# 3. Clean up generated state file logs inside the project root
echo "🧹 Wiping runtime pool logs..."
rm -rf "$WP_PROJECT_ROOT"/.state

# 4. Force Systemd to reload its configuration cache to finalize deletion
echo "⚡ Reloading Systemd daemon..."
systemctl --user daemon-reload

echo "============================================="
echo "🎉 Removal Complete!"
echo "Note: Your source project files and wallpapers remain untouched."
echo "============================================="
