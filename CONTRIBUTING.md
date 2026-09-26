# Contributing to Tower Crash

Thank you for contributing to Tower Crash. This document provides guidelines and commands for setting up your environment, adhering to code style, writing tests, and submitting changes.

## Code of Conduct

All contributors are expected to uphold the [Code of Conduct](CODE_OF_CONDUCT.md). Please report unacceptable behavior to surajyadav200701@gmail.com.

## Development Setup

### Prerequisites

- Node.js 18 or later
- npm
- Clickable 8.x (`pip install clickable-ut` or through distribution package managers)
- Container engine: Docker or LXD configured for Clickable
- Optional: Qt 5 QML development tools (`qml-tools`, `qmlscene`) for local qmllint

### Repository Setup

Clone the repository and install test dependencies:

```bash
git clone https://github.com/suraj-yadav0/tower-crash.git
cd tower-crash
npm install
```

## Running the Application

### Linux Desktop Run

To build and run the game directly on your Linux desktop:

```bash
clickable desktop
```

Desktop controls:
- Mouse drag left/right: Rotate the tower
- Left/Right arrow keys: Keyboard fallback rotation

### Deploy to an Ubuntu Touch Device

Connect your device via USB with Developer Mode enabled:

```bash
clickable
```

### Build Package Only

To build the `.click` package without launching or deploying:

```bash
clickable build
```

## Testing and Quality Verification

All contributions must pass local tests, linting, and formatting checks before submission.

### Run All Tests

```bash
npm test
```

Or execute the test runner directly:

```bash
./tests/run_tests.sh
```

### Unit Tests

Unit tests validate pure game logic (physics, progression, ring generator, themes, persistence):

```bash
npm run test:unit
```

### QML Integration Tests

QML tests verify UI component rendering and modal properties:

```bash
npm run test:qml
```

### Linting

Check QML syntax and structural rules:

```bash
npm run lint
```

### Formatting and Style Validation

Verify that there is no trailing whitespace, all files terminate with newlines, and no emojis exist:

```bash
npm run format:check
```

## Coding and Style Standards

### 1. Zero Emojis (Hard Rule)

Do not use emojis anywhere in the repository:
- No emojis in code, variable names, strings, or comments
- No emojis in commit messages
- No emojis in documentation or pull request descriptions

An automated check enforces this rule during CI.

### 2. Variable and Function Naming

- Use clear, contextual variable names (for example: `stageIndex`, `hazardCount`, `isPaused`).
- Do not append data types to variable names (avoid `itemListArray`, `scoreNumber`, `configObject`).
- Follow standard JavaScript camelCase conventions for functions and variables.
- Follow PascalCase for QML component file names and type names.

### 3. Comments and Documentation

- Write self-documenting code with meaningful identifiers.
- Add comments only to explain why a decision was made, document non-obvious edge cases, or note mathematical formulas.
- Avoid line-by-line syntax narration (for example, do not write `// increment counter by 1`).
- Never use decorative comment banners (such as `// =====================`).

### 4. Code Formatting

- Terminate every file with a single newline (LF).
- Keep all lines free of trailing whitespace.
- Use 4 spaces for indentation in QML and JavaScript files.

### 5. Architectural Boundaries

- Place reusable visual controls and modal dialogs in `qml/components/`.
- Keep mathematical computations, state machines, and generation algorithms inside `qml/js/`.
- Keep database schema management and persistence calls inside `qml/js/Storage.js`.
- Always write corresponding unit tests under `tests/unit/` for any changes made to `qml/js/`.

## Commit Message Guidelines

Commit messages must follow the Conventional Commits specification:

```text
<type>(<scope>): <short imperative description>
```

Types:
- `feat`: A new feature or gameplay mechanic
- `fix`: A bug fix
- `test`: Adding or updating test suites
- `refactor`: Code reorganization with no functional changes
- `docs`: Documentation updates
- `ci`: CI configuration or workflow updates
- `chore`: Build configuration or dependency updates

Examples:
- `feat(gameplay): add fragile rings mechanic to zone 4`
- `fix(storage): correct speed mode integer conversion on reload`
- `docs: update build instructions for clickable 8.10`

When closing an issue, reference it in the commit message or pull request description (for example: `closes #20`).

## Pull Request Process

1. Create a feature branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. Implement your changes following the coding standards.
3. Verify that all tests and lint checks pass:
   ```bash
   npm test
   npm run lint
   npm run format:check
   ```
4. Push your branch to GitHub and open a Pull Request targeting `main`.
5. Ensure all GitHub Actions workflow checks pass. Address any reviewer feedback promptly.
