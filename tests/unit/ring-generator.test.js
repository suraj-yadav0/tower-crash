const test = require('node:test');
const assert = require('node:assert');
const { loadQmlModule } = require('../helpers/qml-module-loader');

const RingGenerator = loadQmlModule('qml/js/RingGenerator.js');

test('RingGenerator - first ring generation per difficulty', () => {
    RingGenerator.resetGenerator();

    // Mode 0: Easy initial gap
    const easyRing = RingGenerator.createRing(0, 140, null, 0);
    const easyGap = easyRing.segments.filter(s => s === 1).length;
    assert.strictEqual(easyGap, 3, 'Easy mode first ring should have gap of 3');

    // Mode 1: Normal initial gap
    const normalRing = RingGenerator.createRing(0, 140, null, 1);
    const normalGap = normalRing.segments.filter(s => s === 1).length;
    assert.strictEqual(normalGap, 3, 'Normal mode first ring should have gap of 3');

    // Mode 2: Hard initial gap
    const hardRing = RingGenerator.createRing(0, 140, null, 2);
    const hardGap = hardRing.segments.filter(s => s === 1).length;
    assert.strictEqual(hardGap, 2, 'Hard mode first ring should have gap of 2');

    // Mode 3: Insane initial gap
    const insaneRing = RingGenerator.createRing(0, 140, null, 3);
    const insaneGap = insaneRing.segments.filter(s => s === 1).length;
    assert.strictEqual(insaneGap, 1, 'Insane mode first ring should have gap of 1');
});

test('RingGenerator - goal rings and grand finale', () => {
    RingGenerator.resetGenerator();

    // Index 19 is the 20th ring (Goal for level 1)
    const level1Goal = RingGenerator.createRing(19, 140, null, 1);
    assert.strictEqual(level1Goal.isGoal, true, 'Ring 19 should be level 1 goal');
    assert.strictEqual(level1Goal.isGrandGoal, false);

    // Index 39 is the 40th ring (Goal for level 2)
    const level2Goal = RingGenerator.createRing(39, 140, null, 1);
    assert.strictEqual(level2Goal.isGoal, true, 'Ring 39 should be level 2 goal');
    assert.strictEqual(level2Goal.isGrandGoal, false);

    // Index 1999 is the 2000th ring (Goal for level 100 - Grand Goal)
    const summitGoal = RingGenerator.createRing(1999, 140, null, 1);
    assert.strictEqual(summitGoal.isGoal, true);
    assert.strictEqual(summitGoal.isGrandGoal, true);
});

test('RingGenerator - hazard limits in Easy mode', () => {
    RingGenerator.resetGenerator();

    // Check 100 rings in high level (e.g. level 50, rings 980-1080)
    for (let i = 980; i < 1080; i++) {
        const ring = RingGenerator.createRing(i, 140, null, 0);
        if (ring.isGoal) continue;
        const hazards = ring.segments.filter(s => s === 2).length;
        assert.ok(hazards <= 3, `Easy mode hazards should not exceed 3 (got ${hazards} on ring ${i})`);
    }
});

test('RingGenerator - rotation mechanic threshold per difficulty', () => {
    // Generate rings before and after threshold for each mode
    // Easy mode rotation threshold: level 50 (ring index >= 980)
    RingGenerator.resetGenerator();
    let easyEarlyHasRotation = false;
    for (let i = 0; i < 500; i++) {
        const r = RingGenerator.createRing(i, 140, null, 0);
        if (r.rotationSpeed && r.rotationSpeed !== 0) easyEarlyHasRotation = true;
    }
    assert.strictEqual(easyEarlyHasRotation, false, 'Easy mode should not rotate before level 50');

    // Insane mode rotation threshold: level 10 (ring index >= 180)
    RingGenerator.resetGenerator();
    let insaneEarlyHasRotation = false;
    for (let i = 0; i < 180; i++) {
        const r = RingGenerator.createRing(i, 140, null, 3);
        if (r.rotationSpeed && r.rotationSpeed !== 0) insaneEarlyHasRotation = true;
    }
    assert.strictEqual(insaneEarlyHasRotation, false, 'Insane mode should not rotate before level 10');
});

test('RingGenerator - oscillating rings disabled in Easy mode', () => {
    RingGenerator.resetGenerator();
    let easyHasOscillation = false;
    for (let i = 0; i < 1500; i++) {
        const r = RingGenerator.createRing(i, 140, null, 0);
        if (r.isOscillating) easyHasOscillation = true;
    }
    assert.strictEqual(easyHasOscillation, false, 'Easy mode should never spawn oscillating rings');
});

test('RingGenerator - segments always sum to 8', () => {
    RingGenerator.resetGenerator();
    for (let i = 0; i < 200; i++) {
        const ring = RingGenerator.createRing(i, 140, null, 1);
        assert.strictEqual(ring.segments.length, 8, `Ring ${i} must have 8 segments`);
        for (const seg of ring.segments) {
            assert.ok([0, 1, 2, 3].indexOf(seg) !== -1, `Invalid segment type ${seg} on ring ${i}`);
        }
    }
});
