# Tower Crash

Tower Crash is a helix-jump arcade game for Ubuntu Touch and Lomiri, built with Qt Quick / QML and JavaScript.

Rotate the tower to drop the bouncing ball through gaps, build momentum to smash through rings, and avoid red hazard blocks.

## Features

- 100 progressive levels across 10 visual zones
- 4 difficulty settings: Easy, Normal, Hard, and Insane (permadeath)
- Combo and overdrive superfall mechanics
- Checkpoint auto-saves every 5 levels (Normal and Hard)
- Offline SQLite progress and high score tracking
- Desktop keyboard controls and touch input

## Controls

- Touch: Drag left or right to rotate the tower
- Desktop Keyboard: Left and Right arrow keys

## Build and Run

The project uses [Clickable](https://clickable-ut.dev/).

### Desktop

Run on a Linux workstation:

```bash
clickable desktop
```

### Ubuntu Touch Device

With Developer Mode enabled and your device connected over USB:

```bash
clickable
```

### Package

Build the standalone `.click` package:

```bash
clickable build
```

## Tests

Run the test suite (unit tests, QML integration tests, linter, and formatting checks):

```bash
npm test
```

Individual checks:

```bash
npm run test:unit
npm run test:qml
npm run lint
npm run format:check
```

## License

GPL-3.0-or-later. See [LICENSE](LICENSE) for details.
