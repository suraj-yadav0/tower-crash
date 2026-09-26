const test = require('node:test');
const assert = require('node:assert');
const { loadQmlModule } = require('../helpers/qml-module-loader');
const { createMockLocalStorage } = require('../helpers/mock-local-storage');
const { createMockGame } = require('../helpers/mock-game');

function setupPhysics() {
    const { Sql } = createMockLocalStorage();
    const Storage = loadQmlModule('qml/js/Storage.js', { Sql });
    const Progression = loadQmlModule('qml/js/Progression.js');
    const GamePhysics = loadQmlModule('qml/js/GamePhysics.js');
    const units = { gu: (v) => v * 8 };
    const i18n = {
        tr: (s) => ({
            arg: (x) => ({
                arg: (y) => String(s).replace('%1', x).replace('%2', y),
                toString: () => String(s).replace('%1', x)
            }),
            toString: () => String(s)
        })
    };
    return { GamePhysics, Storage, Progression, units, i18n };
}

test('GamePhysics - getSegmentIndex angular conversion', () => {
    const { GamePhysics } = setupPhysics();

    // Zero angle -> facing front (PI/2), which maps to index 2
    const center = GamePhysics.getSegmentIndex(0, 0);
    assert.strictEqual(center.index, 2);

    // Quarter turn
    const q1 = GamePhysics.getSegmentIndex(Math.PI / 2, 0);
    assert.strictEqual(q1.index, 0);

    // Negative angle wrapping
    const neg = GamePhysics.getSegmentIndex(-Math.PI / 4, 0);
    assert.ok(neg.index >= 0 && neg.index <= 7);

    // Large angle wrapping
    const large = GamePhysics.getSegmentIndex(10 * Math.PI, 0);
    assert.ok(large.index >= 0 && large.index <= 7);
});

test('GamePhysics - camera smooth tracking and maxLag clamp', () => {
    const { GamePhysics } = setupPhysics();

    const initialCam = 100;
    const targetY = 200;

    // Standard camera step
    const nextCam = GamePhysics.updateCamera(initialCam, targetY, 0, false, 0.016, 150);
    assert.ok(nextCam > initialCam, 'Camera should move toward target');
    assert.ok(nextCam <= targetY, 'Camera should not overshoot target');

    // Superfall camera accelerates
    const superCam = GamePhysics.updateCamera(initialCam, targetY, 0, true, 0.016, 150);
    assert.ok(superCam > nextCam, 'Superfall camera follow rate should be faster');

    // Max lag clamping: if ball is 300 units ahead and maxLag is 100, camera must be at least ballY - 100
    const clampedCam = GamePhysics.updateCamera(0, 500, 0, false, 0.001, 100);
    assert.ok(clampedCam >= 400, 'Camera should be clamped to maxLag');

    // Does not move backward when ball is above camera
    const backCam = GamePhysics.updateCamera(150, 100, 0, false, 0.016, 150);
    assert.strictEqual(backCam, 150, 'Camera should not scroll upward');
});

test('GamePhysics - squash spring damper settles to equilibrium', () => {
    const { GamePhysics } = setupPhysics();

    let squash = 0.6; // Compressed after a bounce
    let vel = 2.0;
    const dt = 0.016;

    // Simulate several frames
    for (let f = 0; f < 60; f++) {
        const res = GamePhysics.updateSquash(squash, vel, dt);
        squash = res.squash;
        vel = res.velocity;
    }

    assert.ok(Math.abs(squash - 1.0) < 0.05, `Squash should settle close to 1.0 (got ${squash})`);
});

test('GamePhysics - ring motion and recoil updates', () => {
    const { GamePhysics } = setupPhysics();

    const rings = [
        { broken: false, rotationSpeed: 2.0, angleOffset: 0.0, recoil: 0.0, recoilVelocity: 0.0, shockwaves: [], splats: [] },
        { broken: false, isOscillating: true, oscSpeed: 1.5, oscAmplitude: 0.4, oscTime: 0.0, angleOffset: 0.0, recoil: 0.0, recoilVelocity: 0.0, shockwaves: [], splats: [] },
        { broken: true, rotationSpeed: 2.0, angleOffset: 0.0, recoil: 0.0, recoilVelocity: 0.0, shockwaves: [], splats: [] }
    ];

    GamePhysics.updateRings(rings, 0.1);

    assert.ok(rings[0].angleOffset > 0, 'Rotating ring should advance angleOffset');
    assert.ok(rings[1].oscTime > 0, 'Oscillating ring should advance oscTime');
    assert.strictEqual(rings[2].angleOffset, 0.0, 'Broken ring should not be updated');
});

test('GamePhysics - collision: gap fall increases streak and activates superfall', () => {
    const { GamePhysics, Storage, Progression, units, i18n } = setupPhysics();
    const { game, soundManager, stageClearTimer } = createMockGame();

    // Ring with segment 2 as gap (0=safe, 1=gap, 2=hazard)
    const ring = {
        y: 100,
        segments: [0, 0, 1, 0, 0, 0, 0, 0], // segment 2 is gap at angle 0
        broken: false,
        isGoal: false,
        recoil: 0,
        recoilVelocity: 0
    };
    game.rings = [ring];

    // Fall through ring from y=90 to y=110
    const collided = GamePhysics.checkBallCollision(game, 90, 110, 1.0, soundManager, stageClearTimer, units, Storage, Progression, i18n);
    assert.strictEqual(collided.gameOver, false, 'Passing through gap should not cause game over');
    assert.strictEqual(collided.nextY, 110, 'Ball should continue past gap');
    assert.strictEqual(game.streak, 1, 'Streak should increment after falling through gap');
    assert.strictEqual(game.totalRings, 1);
    assert.ok(game.score > 0, 'Score should increase after passing ring');

    // Two more gap falls triggers superfall
    game.rings = [{ y: 200, segments: [0, 0, 1, 0, 0, 0, 0, 0], broken: false, isGoal: false }];
    GamePhysics.checkBallCollision(game, 190, 210, 1.0, soundManager, stageClearTimer, units, Storage, Progression, i18n);
    assert.strictEqual(game.streak, 2);
    assert.strictEqual(game.isSuperFall, false);

    game.rings = [{ y: 300, segments: [0, 0, 1, 0, 0, 0, 0, 0], broken: false, isGoal: false }];
    GamePhysics.checkBallCollision(game, 290, 310, 1.0, soundManager, stageClearTimer, units, Storage, Progression, i18n);
    assert.strictEqual(game.streak, 3);
    assert.strictEqual(game.isSuperFall, true, 'Streak of 3 should activate superfall overdrive');
});

test('GamePhysics - collision: normal safe bounce and score scaling', () => {
    const { GamePhysics, Storage, Progression, units, i18n } = setupPhysics();
    const { game, soundManager, stageClearTimer } = createMockGame({ difficultyMode: 1, currentLevel: 1 });

    // Segment 2 is safe (0)
    const ring = {
        y: 100,
        segments: [1, 1, 0, 1, 1, 1, 1, 1],
        broken: false,
        isGoal: false,
        recoil: 0,
        recoilVelocity: 0
    };
    game.rings = [ring];

    const collided = GamePhysics.checkBallCollision(game, 90, 110, 1.0, soundManager, stageClearTimer, units, Storage, Progression, i18n);
    assert.strictEqual(collided.gameOver, false);
    assert.strictEqual(collided.nextY, 100, 'Ball should be placed on ring surface for bounce');
    assert.strictEqual(soundManager.bounces, 1, 'Safe landing should play bounce sound');
    assert.strictEqual(game.streak, 0, 'Safe landing resets combo streak');
    assert.strictEqual(game.gameOver, false, 'Safe landing should not cause game over');
});

test('GamePhysics - collision: hazard segment causes game over when not in superfall', () => {
    const { GamePhysics, Storage, Progression, units, i18n } = setupPhysics();
    const { game, soundManager, stageClearTimer } = createMockGame({ isSuperFall: false });

    // Segment 2 is hazard (2)
    const ring = {
        y: 100,
        segments: [1, 1, 2, 1, 1, 1, 1, 1],
        broken: false,
        isGoal: false,
        recoil: 0,
        recoilVelocity: 0
    };
    game.rings = [ring];

    const collided = GamePhysics.checkBallCollision(game, 90, 110, 1.0, soundManager, stageClearTimer, units, Storage, Progression, i18n);
    assert.strictEqual(collided.gameOver, true, 'Landing on hazard without superfall must trigger game over');
    assert.strictEqual(game.gameOver, true);
    assert.ok(soundManager.haptics >= 1);
});

test('GamePhysics - collision: superfall destroys hazard without dying', () => {
    const { GamePhysics, Storage, Progression, units, i18n } = setupPhysics();
    const { game, soundManager, stageClearTimer } = createMockGame({ isSuperFall: true, streak: 4 });

    // Segment 2 is hazard (2)
    const ring = {
        y: 100,
        segments: [1, 1, 2, 1, 1, 1, 1, 1],
        broken: false,
        isGoal: false,
        recoil: 0,
        recoilVelocity: 0
    };
    game.rings = [ring];

    const collided = GamePhysics.checkBallCollision(game, 90, 110, 1.0, soundManager, stageClearTimer, units, Storage, Progression, i18n);
    assert.strictEqual(collided.gameOver, false, 'Superfall should destroy hazard without dying');
    assert.strictEqual(game.gameOver, false);
    assert.strictEqual(ring.broken, true);
    assert.ok(game.shatterEvents.length >= 1);
    assert.strictEqual(game.isSuperFall, false, 'Superfall ends after smashing a platform');
});

test('GamePhysics - collision: goal ring triggers stage completion and checkpoint timer', () => {
    const { GamePhysics, Storage, Progression, units, i18n } = setupPhysics();
    const { game, soundManager, stageClearTimer } = createMockGame({ currentLevel: 5 });

    // Level 5 goal ring leads to Level 6 (which is a checkpoint)
    const goalRing = {
        index: 99,
        y: 100,
        segments: [0, 0, 0, 0, 0, 0, 0, 0],
        broken: false,
        isGoal: true,
        goalLevel: 5,
        isGrandGoal: false,
        goalAwarded: false,
        recoil: 0,
        recoilVelocity: 0
    };
    game.rings = [goalRing];

    const collided = GamePhysics.checkBallCollision(game, 90, 110, 1.0, soundManager, stageClearTimer, units, Storage, Progression, i18n);
    assert.strictEqual(collided.gameOver, false);
    assert.strictEqual(soundManager.fanfares, 1);
    assert.strictEqual(stageClearTimer.started, true, 'Stage clear timer should be started for checkpoint stage');
    assert.strictEqual(game.stageClearStage, 5);
    assert.strictEqual(game.stageClearNextCheckpoint, 6);
});
