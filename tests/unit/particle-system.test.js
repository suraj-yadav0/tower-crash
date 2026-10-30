const test = require('node:test');
const assert = require('node:assert');
const { loadQmlModule } = require('../helpers/qml-module-loader');

function setupParticles() {
    const Particles = loadQmlModule('qml/js/ParticleSystem.js');
    const units = { gu: (v) => v * 8 };
    return { Particles, units };
}

test('ParticleSystem - spawnShatterDebris creates falling blocks for all solid segments', () => {
    const { Particles, units } = setupParticles();
    const particles = [];
    const outerRadius = 160;
    const innerRadius = 40;
    const ringY = 200;
    const ringHeight = 24;

    // Ring with 2 gaps and 6 solid segments (safe and hazard)
    const ring = {
        segments: [0, 0, 1, 1, 2, 0, 0, 0],
        angleOffset: 0.1,
        rotationSpeed: 0.5
    };
    const theme = {
        topSafe: '#D99B26',
        sideSafe: '#A06B15',
        topHazard: '#BA3C3C',
        sideHazard: '#8E2A2A',
        goalTop: '#E8C872',
        goalSide: '#B09242'
    };

    Particles.spawnShatterDebris(particles, units, outerRadius, innerRadius, ringY, false, false, theme, true, ring, 0.0, ringHeight);

    // Filter spawned falling blocks
    const blocks = particles.filter(p => p.kind === 'block');
    assert.strictEqual(blocks.length, 6, 'Should spawn exactly 6 falling blocks for the 6 solid segments');

    // Verify hazard segment properties
    const hazardBlocks = blocks.filter(b => b.isHazard);
    assert.strictEqual(hazardBlocks.length, 1, 'Should preserve hazard segment flag');
    assert.strictEqual(hazardBlocks[0].topColor, theme.topHazard);
    assert.strictEqual(hazardBlocks[0].sideColor, theme.sideHazard);

    // Verify physical momentum and tumbling properties
    for (const b of blocks) {
        assert.ok(b.vy > 0, 'Each block should have initial downward smash impulse');
        assert.ok(b.vx !== 0 || b.vz !== 0, 'Each block should have outward radial velocity');
        assert.ok(b.vrotX !== 0 || b.vrotY !== 0 || b.vrotZ !== 0, 'Each block should have 3D tumbling rotation');
        assert.strictEqual(b.height, ringHeight);
        assert.strictEqual(b.outerRadius, outerRadius);
        assert.strictEqual(b.innerRadius, innerRadius);
        assert.strictEqual(b.alpha, 1.0);
    }
});

test('ParticleSystem - spawnSegmentShatter creates single falling block', () => {
    const { Particles, units } = setupParticles();
    const particles = [];
    const outerRadius = 160;
    const innerRadius = 40;
    const ringY = 150;
    const ringHeight = 24;

    const ring = {
        segments: [0, 0, 3, 0, 0, 0, 0, 0],
        angleOffset: 0.0
    };

    Particles.spawnSegmentShatter(particles, units, outerRadius, innerRadius, ringY, Math.PI / 2, '#D99B26', '#A06B15', 2, 0.0, ring, ringHeight);

    const blocks = particles.filter(p => p.kind === 'block');
    assert.strictEqual(blocks.length, 1, 'Should spawn exactly 1 falling block for the broken fragile segment');

    const block = blocks[0];
    assert.strictEqual(block.topColor, '#D99B26');
    assert.strictEqual(block.sideColor, '#A06B15');
    assert.ok(block.vy > 0, 'Block should have downward impulse');
    assert.ok(block.vrotX !== 0, 'Block should have forward tumble');
});

test('ParticleSystem - updateParticles accelerates blocks with gravity and tumbling', () => {
    const { Particles, units } = setupParticles();
    const gravity = 800;
    const poleRadius = 30;
    const dt = 0.016;

    const block = {
        kind: 'block',
        x: 100,
        y: 200,
        z: 0,
        vx: 50,
        vy: 10,
        vz: 0,
        rotX: 0,
        rotY: 0,
        rotZ: 0,
        vrotX: 2.0,
        vrotY: 1.5,
        vrotZ: 3.0,
        outerRadius: 160,
        innerRadius: 40,
        alpha: 1.0,
        decay: 0.70
    };
    const particles = [block];

    Particles.updateParticles(particles, dt, gravity, poleRadius, units);

    assert.ok(block.y > 200, 'Block should fall downward in Y');
    assert.ok(block.vy > 10, 'Block vy should increase from gravity');
    assert.ok(block.rotX > 0, 'Block rotX pitch should advance');
    assert.ok(block.rotY > 0, 'Block rotY yaw should advance');
    assert.ok(block.rotZ > 0, 'Block rotZ roll should advance');
    assert.ok(block.alpha < 1.0, 'Block alpha should decay');
});

test('ParticleSystem - updateParticles pole collision bounces block radially outward', () => {
    const { Particles, units } = setupParticles();
    const gravity = 800;
    const poleRadius = 40;
    const dt = 0.016;

    // Block placed directly against pole moving inward
    const block = {
        kind: 'block',
        x: 35,
        y: 200,
        z: 0,
        vx: -60,
        vy: 10,
        vz: 0,
        outerRadius: 160,
        innerRadius: 40,
        alpha: 1.0,
        decay: 0.70
    };
    const particles = [block];

    Particles.updateParticles(particles, dt, gravity, poleRadius, units);

    assert.ok(block.x > 35, 'Block should be pushed outward away from central pole');
    assert.ok(block.vx > 0, 'Inward velocity should reverse into outward bounce');
});
