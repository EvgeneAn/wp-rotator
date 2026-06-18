#!/bin/bash

# Setup default configurations
DEFAULT_PROJECT_DIR="$HOME/snap/wp-rotator"
WP_PROJECT_DIR="${WP_PROJECT_DIR:-$DEFAULT_PROJECT_DIR}"
SYSTEMD_DIR="$HOME/.config/systemd/user"
ENV_FILE="$WP_PROJECT_DIR/wp-rotate.env"

echo "============================================="
echo " Installing GNOME Multi-Monitor Wall Rotator "
echo "============================================="

# 1. Verify that the user created the environment file first
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: Configuration file not found at: $ENV_FILE"
    echo "Please create 'wp-rotate.env' before running this installer."
    exit 1
fi

# 2. Source the env file to ensure we create the custom user directories
source "$ENV_FILE"

# 3. Setup folder structures and script permissions
chmod +x "$WP_PROJECT_DIR/rotate-wp.sh"
mkdir -p "$SYSTEMD_DIR"
mkdir -p "$WP_MON1_DIR" "$WP_MON2_DIR"

# 4. COPY files to Systemd targets (No links!)
echo "📁 Copying configuration files to Systemd folder..."
cp -f "$WP_PROJECT_DIR/wp-rotate.service" "$SYSTEMD_DIR/wp-rotate.service"
cp -f "$WP_PROJECT_DIR/wp-rotate.timer" "$SYSTEMD_DIR/wp-rotate.timer"
cp -f "$ENV_FILE" "$SYSTEMD_DIR/wp-rotate.env"

# 5. DYNAMIC OVERRIDE: Inject the timeout value into Systemd Timer drop-in
echo "⏱️ Generating Timer Timeout Override (${WP_ROTATE_TIMEOUT:-15}m)..."
DROPIN_DIR="$SYSTEMD_DIR/wp-rotate.timer.d"
mkdir -p "$DROPIN_DIR"
cat << EOF > "$DROPIN_DIR/override.conf"
[Timer]
OnUnitActiveSec=${WP_ROTATE_TIMEOUT:-15}min
EOF

# 6. Fire up the Systemd loop
systemctl --user daemon-reload
systemctl --user enable --now wp-rotate.timer

echo "============================================="
echo "🎉 Setup Complete! Background rotation active."
echo "============================================="
