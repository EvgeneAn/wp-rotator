# Multi-Monitor Wallpaper Rotator for GNOME 50+

A simple, dependency-light background wallpaper rotator tailored for GNOME layouts. It utilizes **HydraPaper** to set unique wallpapers per monitor and leverages **Systemd User Timers** to cycle them flawlessly on a custom schedule without resource-heavy background apps.

## Key Features

- **Zero Duplicates:** Uses a smart pool-based countdown strategy ensuring you see every image in your folders once before any repeats.
- **Multi-Monitor Optimized:** Targets specific directories for individual screens (e.g., Folder 1 for Monitor 1, Folder 2 for Monitor 2).
- **Natively Integrated:** Uses Systemd user timers instead of flakey crontabs, eliminating DBUS/GNOME display environment issues.
- **Centralized Configuration:** Shared environment profiles read cleanly by both Systemd and local shell environments.
- **Portable Architecture:** Supports full directory customization using an inline shell runtime wrapper inside Systemd.

---

## Directory Structure

To keep your system clean, this project consolidates all of its assets inside a single project folder:

```text
~/snap/wp-rotator/
├── install.sh              # Static system installation script
├── uninstall.sh            # Complete uninstallation script
├── rotate-wp.sh            # The core execution script
├── wp-rotate.service       # Systemd service (The Worker)
├── wp-rotate.timer         # Systemd timer (The Clock base)
├── wp-rotate.env           # User configuration file (Create manually!)
└── .state/                 # Generated state-tracking directory
    ├── pool1.txt           # Monitor 1 unplayed images stack
    └── pool2.txt           # Monitor 2 unplayed images stack
```

---

## Requirements

- **HydraPaper**: `3.0+` (Critical: Requires the revised `-c/--cli` argument syntax)
- **GNOME Shell**: `50+` (Tested and validated on GNOME 50.2)
- **Systemd**: `245+` (Tested on Systemd 260; requires user-space system unit compatibility)
- **Core Utilities**: Standard GNU `sed` and `shuf`

---

## Setup & Configuration

### 1. Download the Project

Clone or place the project files directly inside your user directory (default: `~/snap/wp-rotator/`).

### 2. Create the Configuration File

Before running the installer, you must manually create a configuration file named `wp-rotate.env` inside the project folder (`~/snap/wp-rotator/wp-rotate.env`).

Paste the following template into your file and adjust the paths or timeout interval to match your preferences:

```env
WP_ROTATE_TIMEOUT=15
WP_PROJECT_ROOT=/home/YOUR_USERNAME/snap/wp-rotator
WP_MON1_DIR=/home/YOUR_USERNAME/Pictures/Wallpapers/Monitor1
WP_MON2_DIR=/home/YOUR_USERNAME/Pictures/Wallpapers/Monitor2
```

_(Replace `YOUR_USERNAME` with your actual Linux user directory name)._

### 3. Run the Automated Installer

Once your environment file is saved in place, execute the installation script to handle file mapping, permissions, dynamic Systemd scheduler drop-ins, and system hooks automatically:

```bash
chmod +x ~/snap/wp-rotator/install.sh
~/snap/wp-rotator/install.sh
```

---

## Configuration Reference (`wp-rotate.env`)

The project relies entirely on your environment variables to guide its automation behavior. The script implements safe fallbacks for missing directories, but setting them manually guarantees maximum reliability.

| Variable                | Description                                                                          | Default Fallback Value           |
| :---------------------- | :----------------------------------------------------------------------------------- | :------------------------------- |
| **`WP_ROTATE_TIMEOUT`** | The wallpaper rotation frequency interval measured strictly in minutes.              | `15`                             |
| **`WP_PROJECT_ROOT`**   | The absolute directory path where this repository and its tracking pools live.       | `~/snap/wp-rotator`              |
| **`WP_MON1_DIR`**       | The path to the image pool directory designated for your first (primary) monitor.    | `~/Pictures/Wallpapers/Monitor1` |
| **`WP_MON2_DIR`**       | The path to the image pool directory designated for your second (secondary) monitor. | `~/Pictures/Wallpapers/Monitor2` |

---

## Management & Troubleshooting

### Check Countdown Status

To see exactly when your wallpapers will swap next, run:

```bash
systemctl --user status wp-rotate.timer
```

### Trigger a Manual Swap

If you don't want to wait for the timer and want to forcefully jump to the next set of images right now, trigger the service manually:

```bash
systemctl --user start wp-rotate.service
```

### Reset the Playlist Loop Early

If you add new images to your wallpaper folders and want to rebuild your active pool immediately, simply wipe out the tracking state folder:

```bash
rm -rf ~/snap/wp-rotator/.state
```

---

## Uninstallation

If you ever wish to remove the rotation schedule from your system, a complete uninstallation script is provided. It safely stops the background processes, tears down Systemd assets, and wipes active pool data.

To keep your personal items safe, it **does not delete** your source wallpaper folders or your custom `wp-rotate.env` configuration profile.

Run the uninstaller with:

```bash
chmod +x ~/snap/wp-rotator/uninstall.sh
~/snap/wp-rotator/uninstall.sh
```

---

## License

This project is licensed under the MIT License.
