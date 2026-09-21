# Tower Crash: Spiral Ball Jump

A native Ubuntu Touch game built with QML and Lomiri UI Toolkit 1.3, packaged with Clickable.

## Overview
Tower Crash is a Helix Jump style vertical arcade game where a ball falls continuously under gravity while the player drags left or right to rotate the tower. Align gaps beneath the ball to fall deeper and rack up score, bounce on safe platforms to maintain control, and avoid red hazard segments that end the run.

## Requirements
- Clickable 8.x (`clickable --version`)
- Docker or LXD (configured for Clickable container builds)

## Development and Testing

### Run on Linux Desktop
To build and launch the game locally in desktop mode:
```bash
clickable desktop
```
Controls:
- Mouse drag left/right: Rotate the tower
- Left/Right arrow keys: Keyboard rotation fallback

### Build and Install on an Ubuntu Touch Device
Connect your Ubuntu Touch device via USB (with Developer Mode enabled) and run:
```bash
clickable
```
Clickable builds the click package and installs it onto the device over ADB.

### Build Package Only
To compile the `.click` package without installing:
```bash
clickable build
```

## Project Structure
- `qml/Main.qml`: Single-file core game logic, physics loop, Canvas 2D pseudo-3D renderer, and Lomiri UI.
- `clickable.json`: Clickable configuration specifying the pure-qml-qmake builder.
- `tower-crash.pro`: QMake project file defining auxiliary installs for click packaging.
- `manifest.json.in` / `manifest.json`: Click package manifests targeting Ubuntu Touch 24.04.
- `apparmor.json`: AppArmor security profile.
- `tower-crash.desktop`: Lomiri desktop entry for the application drawer.
- `assets/logo.svg`: Application vector icon.
- `LICENSE`: GNU General Public License v3.0 text.

## Maintainer
Suraj Yadav <surajyadav200701@gmail.com>

## License
This project is licensed under the GNU General Public License v3.0 or later (GPL-3.0-or-later). See the [LICENSE](LICENSE) file for the full license text.

