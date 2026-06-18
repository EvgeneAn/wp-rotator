#!/bin/bash

# Find where the script is located to safely locate files manually if needed
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
ENV_FILE="$SCRIPT_DIR/wp-rotate.env"

# Load local environment configuration if running manually outside Systemd
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

# 1. Map Project Root Path Fallback
DEFAULT_PROJECT_ROOT="$HOME/snap/wp-rotator"
WP_PROJECT_ROOT="${WP_PROJECT_ROOT:-$DEFAULT_PROJECT_ROOT}"

# 2. Map Monitor Directories (Uses Env Variable or falls back to defaults)
DIR1="${WP_MON1_DIR:-$HOME/Pictures/Wallpapers/Monitor1}"
DIR2="${WP_MON2_DIR:-$HOME/Pictures/Wallpapers/Monitor2}"

# 3. Define state file paths using the configured project root
STATE_DIR="${WP_PROJECT_ROOT}/.state"
mkdir -p "$STATE_DIR"

POOL1="$STATE_DIR/pool1.txt"
POOL2="$STATE_DIR/pool2.txt"

# --- MONITOR 1 LOGIC ---
if [ ! -s "$POOL1" ]; then
    find "$DIR1" -type f > "$POOL1"
fi
WP1=$(shuf -n 1 "$POOL1")
sed -i "\#$WP1#d" "$POOL1"

# --- MONITOR 2 LOGIC ---
if [ ! -s "$POOL2" ]; then
    find "$DIR2" -type f > "$POOL2"
fi
WP2=$(shuf -n 1 "$POOL2")
sed -i "\#$WP2#d" "$POOL2"

# --- APPLY WALLPAPERS ---
hydrapaper -c "$WP1" "$WP2"
