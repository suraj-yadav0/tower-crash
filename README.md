# Tower Crash: Spiral Ball Jump

A native vertical arcade game built for Ubuntu Touch and Lomiri with Qt 5, QML, and JavaScript, packaged and deployed using Clickable.

## Overview

Tower Crash is a dynamic spiral descent game. A bouncing ball falls under gravity while the player rotates a cylindrical tower to align open gaps. Guide the ball down successive rings, build speed to trigger overdrive destruction, navigate oscillating gaps, and avoid hazardous red segments that end the run.

The game features 100 procedurally generated stages grouped into 10 thematic zones, 4 distinct difficulty modes (including permadeath), dynamic and unlockable visual themes, and local SQLite persistence.

## Key Features

- **100 Procedurally Scaled Stages**: Levels progress in complexity with rotating rings, moving hazards, oscillating gaps, and fragile platforms.
- **10 Thematic Zones**: Each 10-level block introduces distinct color palettes, visual identities, and obstacle configurations.
- **4 Difficulty Modes**: Choose from Easy, Normal, Hard, and Insane (permadeath) with independent progress tracking.
- **Combo and Overdrive Mechanics**: Dropping through 3 or more rings consecutively without bouncing charges Overdrive Superfall, granting invulnerability to shatter the next impact ring.
- **Dynamic Checkpoint System**: Save progress every 5 levels (Normal and Hard) or start at any previously cleared checkpoint.
- **Isolated SQLite Persistence**: High scores, checkpoint unlocks, completed stages, and settings are tracked independently per difficulty mode.
- **Audio and Haptics**: Procedural synthesizers, sound manager routing, and device haptic feedback.
- **Fully Automated CI**: Comprehensive testing across unit logic, QML component integration, code formatting, and package verification.

## Gameplay Mechanics

### Tower Rotation and Ball Physics
- **Rotation**: Touch and drag left or right to rotate the tower. Keyboard arrow keys are supported on desktop environments.
- **Ball Movement**: Simulates vertical gravity acceleration, terminal velocity, and elastic restitution bounces on safe platforms.
- **Gaps**: Rings contain gaps through which the ball can drop freely.
- **Hazards**: Red segments eliminate the ball on contact unless Overdrive Superfall is active.
- **Fragile Rings**: Certain rings shatter after a single bounce, forcing continuous movement.
- **Oscillating Rings**: Gaps and hazard sectors oscillate periodically, requiring timing and anticipation.

### Overdrive Superfall
Passing through 3 consecutive rings without touching any platform activates Overdrive. During Overdrive:
- Visual trails and speed lines appear behind the ball.
- Terminal velocity increases.
- The next ring hit is obliterated completely upon contact, clearing hazards and resetting the multiplier.

## Difficulty Modes

| Mode | Speed Multiplier | Score Multiplier | Gap Angle Adjustment | Checkpoints | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Easy** | 0.88x | 0.8x | +0.25 rad | Every 5 levels | Relaxed pace, wider gaps, fewer hazards, ideal for casual play. |
| **Normal** | 1.00x | 1.0x | Standard | Every 5 levels | Balanced arcade experience with standard progression. |
| **Hard** | 1.12x | 1.5x | -0.15 rad | Every 5 levels | Higher fall speeds, narrower gaps, and increased hazard density. |
| **Insane** | 1.25x | 2.5x | -0.25 rad | None (Permadeath) | Ruthless difficulty. Any collision resets progress back to Level 1. |

## Thematic Zones

The 100-level ascent is structured across 10 progressive zones:

1. **Zone 1: Outer Terrace** (Levels 1-10) - Foundations and flow introducing core descent mechanics.
2. **Zone 2: Clockwork Shaft** (Levels 11-20) - Rhythmic descent introducing oscillating segments.
3. **Zone 3: Prism Corridors** (Levels 21-30) - Precision navigation requiring tighter rotation adjustments.
4. **Zone 4: Sector Shifts** (Levels 31-40) - Shifting sectors with multi-gap configurations.
5. **Zone 5: The Crucible** (Levels 41-50) - Midpoint gauntlet featuring high-density hazard patterns.
6. **Zone 6: Shadow Spiral** (Levels 51-60) - Narrow margins and faster rotating platforms.
7. **Zone 7: Pulse Conduit** (Levels 61-70) - High-speed velocity corridors demanding fast reflexes.
8. **Zone 8: The Labyrinth** (Levels 71-80) - Complex maze-like ring openings and delayed gaps.
9. **Zone 9: Inferno Core** (Levels 81-90) - Grandmaster trial with intense hazard coverage.
10. **Zone 10: The Monolith** (Levels 91-100) - The summit finale testing mastery of all mechanics.

## Architecture and Project Structure

```text
tower-crash/
|-- .github/
|   |-- ISSUE_TEMPLATE/
|   |   |-- bug_report.md
|   |   `-- feature_request.md
|   `-- workflows/
|       `-- ci.yml
|-- assets/
|   |-- logo.svg
|   `-- sounds/
|       |-- bounce.wav
|       `-- fanfare.wav
|-- qml/
|   |-- components/
|   |   |-- AboutView.qml
|   |   |-- GameBackground.qml
|   |   |-- GameCanvas.qml
|   |   |-- GameHud.qml
|   |   |-- GameOverModal.qml
|   |   |-- HowToPlayView.qml
|   |   |-- MilestoneBanner.qml
|   |   |-- ModalLayer.qml
|   |   |-- PauseModal.qml
|   |   |-- SettingsModal.qml
|   |   |-- SoundBackendMultimedia.qml
|   |   |-- SoundManager.qml
|   |   |-- StageClearModal.qml
|   |   |-- ThemePickerView.qml
|   |   `-- WelcomeScreen.qml
|   |-- js/
|   |   |-- GamePhysics.js
|   |   |-- ParticleSystem.js
|   |   |-- Progression.js
|   |   |-- RingGenerator.js
|   |   |-- Storage.js
|   |   `-- Themes.js
|   `-- Main.qml
|-- tests/
|   |-- helpers/
|   |   |-- mock-game.js
|   |   |-- mock-local-storage.js
|   |   `-- qml-module-loader.js
|   |-- qml/
|   |   |-- test_game_hud.qml
|   |   |-- test_game_over_modal.qml
|   |   |-- test_milestone_banner.qml
|   |   |-- test_pause_modal.qml
|   |   |-- test_settings_modal.qml
|   |   |-- test_stage_clear_modal.qml
|   |   `-- test_welcome_screen.qml
|   |-- unit/
|   |   |-- game-physics.test.js
|   |   |-- progression.test.js
|   |   |-- ring-generator.test.js
|   |   |-- storage.test.js
|   |   `-- themes.test.js
|   |-- check_formatting.sh
|   |-- run-qml-tests.js
|   `-- run_tests.sh
|-- apparmor.json
|-- clickable.json
|-- CODE_OF_CONDUCT.md
|-- CONTRIBUTING.md
|-- LICENSE
|-- manifest.json
|-- manifest.json.in
|-- package.json
|-- README.md
|-- tower-crash.desktop
`-- tower-crash.pro
```

### Module Responsibilities

- **`qml/Main.qml`**: Central state machine managing screen transitions, input routing, and coordination between components.
- **`qml/components/GameCanvas.qml`**: 60fps canvas-based pseudo-3D renderer with depth-sorted rings, lighting, shadows, and particle effects.
- **`qml/js/GamePhysics.js`**: Pure physics calculations for gravitational velocity, bounce dynamics, collision detection, and overdrive state.
- **`qml/js/RingGenerator.js`**: Procedural generation logic scaling ring gap widths, obstacle placement, and oscillation speeds.
- **`qml/js/Progression.js`**: Zone definitions, difficulty parameter multipliers, checkpoint evaluation, and level title formatting.
- **`qml/js/Storage.js`**: SQLite storage adapter isolating statistics, checkpoints, and high scores by difficulty mode.
- **`qml/js/Themes.js`**: Color schemes, ambient gradients, and color interpolation between zones.

## Development and Building

### Prerequisites

- Clickable 8.x (`pip install clickable-ut`)
- Docker or LXD configured for Clickable container builds
- Node.js 18+ (for testing)

### Run on Linux Desktop

Launch the application directly on your desktop workstation:

```bash
clickable desktop
```

### Install on an Ubuntu Touch Device

Connect your device via USB with Developer Mode enabled and run:

```bash
clickable
```

### Compile Package Only

To build the standalone `.click` package:

```bash
clickable build
```

### OpenStore Review & Publishing

Validate the built package against OpenStore security policies:

```bash
clickable review
```

Publish directly to the OpenStore:

```bash
clickable publish -- "Initial release of Tower Crash for Ubuntu Touch 24.04"
```

## Running Tests

The test suite includes JavaScript unit tests, QML component integration tests, lint checks, and formatting verification.

### Run All Tests

```bash
npm test
```

Or run the shell wrapper:

```bash
./tests/run_tests.sh
```

### Individual Test Suites

- **Unit tests**: `npm run test:unit`
- **QML integration tests**: `npm run test:qml`
- **QML linting**: `npm run lint`
- **Style and formatting checks**: `npm run format:check`

## Continuous Integration

Every commit and pull request triggers a 4-stage GitHub Actions pipeline:

1. **JavaScript Unit Tests**: Verifies physics, procedural generation, progression, themes, and persistence modules.
2. **Lint & Code Style**: Executes `qmllint` syntax validation and style/formatting verification (whitespace, newlines, zero-emoji rule).
3. **QML Integration Tests**: Mounts and verifies visual modal states and HUD properties in a headless Qt environment.
4. **Package Verification**: Builds the complete Ubuntu Touch `.click` package using Clickable in a containerized Noble environment.

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) for commit standards, coding style, and testing requirements, and review the [Code of Conduct](CODE_OF_CONDUCT.md).

## Maintainer

Suraj Yadav <surajyadav200701@gmail.com>

## License

This project is licensed under the GNU General Public License v3.0 or later (GPL-3.0-or-later). See the [LICENSE](LICENSE) file for details.
