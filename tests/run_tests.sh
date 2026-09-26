#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"

echo "=== Running JavaScript Module Unit Tests ==="
node --test tests/unit/*.test.js

if command -v qmlscene >/dev/null 2>&1; then
    echo ""
    echo "=== Running QML Component Integration Tests ==="
    node tests/run-qml-tests.js
else
    echo ""
    echo "Notice: qmlscene not found in PATH; skipping QML integration tests."
fi

echo ""
echo "All automated test suites passed successfully."
