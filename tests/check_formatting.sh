#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"

echo "Checking code formatting and style..."
FAILED=0

# 1. Check for trailing whitespace in source files
echo "Checking for trailing whitespace..."
TRAILING_WS=$(git grep -I -n '[[:blank:]]$' -- 'qml/*' 'tests/*' 'package.json' '*.json' || true)
if [ -n "$TRAILING_WS" ]; then
    echo "Error: Trailing whitespace found in:"
    echo "$TRAILING_WS"
    FAILED=1
else
    echo "Passed: No trailing whitespace found."
fi

# 2. Check for missing newline at EOF
echo "Checking for missing newline at EOF..."
for f in $(git ls-files 'qml/*' 'tests/*' 'package.json' '*.json'); do
    if [ -f "$f" ] && [ -s "$f" ]; then
        if [ "$(tail -c 1 "$f" | wc -l)" -eq 0 ]; then
            echo "Error: Missing newline at EOF in $f"
            FAILED=1
        fi
    fi
done
if [ "$FAILED" -eq 0 ]; then
    echo "Passed: All files have terminating newlines."
fi

# 3. Check for disallowed emojis in source files
echo "Checking for disallowed emojis..."
EMOJI_CHECK=$(python3 -c "
import os, re, sys
pattern = re.compile(r'[\U00010000-\U0010ffff]|[\u2600-\u27bf]|[\u2300-\u23ff]')
found = 0
for root, _, files in os.walk('.'):
    if any(p in root for p in ['.git', 'build', 'assets']): continue
    for f in files:
        if not f.endswith(('.qml', '.js', '.json', '.sh', '.md', '.pro', '.desktop')): continue
        p = os.path.join(root, f)
        content = open(p, 'r', encoding='utf-8', errors='ignore').read()
        matches = pattern.findall(content)
        if matches:
            print(f'Emoji found in {p}: {matches}')
            found += 1
if found > 0:
    sys.exit(1)
" || true)

if [ -n "$EMOJI_CHECK" ]; then
    echo "Error: Disallowed emoji characters found:"
    echo "$EMOJI_CHECK"
    FAILED=1
else
    echo "Passed: Zero emojis across source files."
fi

if [ "$FAILED" -ne 0 ]; then
    echo "Formatting check failed."
    exit 1
fi

echo "All code formatting and style checks passed."
