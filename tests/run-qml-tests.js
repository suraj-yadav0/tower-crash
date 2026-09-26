const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const qmlDir = path.resolve(__dirname, 'qml');
const files = fs.readdirSync(qmlDir).filter(f => f.startsWith('test_') && f.endsWith('.qml'));

console.log(`Running ${files.length} QML integration test suites...`);

let passed = 0;
let failed = 0;
const startTime = Date.now();

for (const file of files) {
    const filePath = path.join(qmlDir, file);
    const testName = file.replace(/\.qml$/, '');
    const t0 = Date.now();

    const proc = spawnSync('qmlscene', ['--platform', 'offscreen', filePath], {
        timeout: 8000,
        encoding: 'utf8'
    });

    const duration = Date.now() - t0;
    const output = (proc.stdout || '') + (proc.stderr || '');

    if (proc.status === 0 && output.includes('PASS:')) {
        passed++;
        console.log(`PASS ${testName} (${duration}ms)`);
    } else {
        failed++;
        console.error(`FAIL ${testName} (${duration}ms)`);
        if (proc.error) {
            console.error(`  Error: ${proc.error.message}`);
        } else {
            console.error(`  Exit Code: ${proc.status}`);
            console.error(`  Output: ${output.trim()}`);
        }
    }
}

const totalTime = Date.now() - startTime;
console.log(`\nQML Test Summary: ${passed} passed, ${failed} failed in ${totalTime}ms`);

if (failed > 0) {
    process.exit(1);
}
