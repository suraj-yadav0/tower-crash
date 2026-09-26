const test = require('node:test');
const assert = require('node:assert');
const { loadQmlModule } = require('../helpers/qml-module-loader');

const Progression = loadQmlModule('qml/js/Progression.js');

test('Progression - difficulty names and multipliers', () => {
    assert.strictEqual(Progression.getDifficultyName(0), 'Easy');
    assert.strictEqual(Progression.getDifficultyName(1), 'Normal');
    assert.strictEqual(Progression.getDifficultyName(2), 'Hard');
    assert.strictEqual(Progression.getDifficultyName(3), 'Insane');
    assert.strictEqual(Progression.getDifficultyName(99), 'Normal');

    assert.strictEqual(Progression.getDifficultyScoreMultiplier(0), 0.8);
    assert.strictEqual(Progression.getDifficultyScoreMultiplier(1), 1.0);
    assert.strictEqual(Progression.getDifficultyScoreMultiplier(2), 1.5);
    assert.strictEqual(Progression.getDifficultyScoreMultiplier(3), 2.5);

    assert.strictEqual(Progression.getDifficultySpeedMultiplier(0), 0.88);
    assert.strictEqual(Progression.getDifficultySpeedMultiplier(1), 1.0);
    assert.strictEqual(Progression.getDifficultySpeedMultiplier(2), 1.12);
    assert.strictEqual(Progression.getDifficultySpeedMultiplier(3), 1.25);
});

test('Progression - checkpoint validation per mode', () => {
    assert.strictEqual(Progression.hasCheckpoints(0), true);
    assert.strictEqual(Progression.hasCheckpoints(1), true);
    assert.strictEqual(Progression.hasCheckpoints(2), true);
    assert.strictEqual(Progression.hasCheckpoints(3), false);

    assert.strictEqual(Progression.isCheckpointLevel(1, 1), true);
    assert.strictEqual(Progression.isCheckpointLevel(6, 1), true);
    assert.strictEqual(Progression.isCheckpointLevel(11, 1), true);
    assert.strictEqual(Progression.isCheckpointLevel(7, 1), false);
    assert.strictEqual(Progression.isCheckpointLevel(10, 1), false);

    // Insane mode never has checkpoints
    assert.strictEqual(Progression.isCheckpointLevel(1, 3), false);
    assert.strictEqual(Progression.isCheckpointLevel(6, 3), false);
    assert.strictEqual(Progression.isCheckpointLevel(11, 3), false);
});

test('Progression - zone transition identification', () => {
    assert.strictEqual(Progression.isZoneTransition(1), false);
    assert.strictEqual(Progression.isZoneTransition(10), false);
    assert.strictEqual(Progression.isZoneTransition(11), true);
    assert.strictEqual(Progression.isZoneTransition(21), true);
    assert.strictEqual(Progression.isZoneTransition(31), true);
    assert.strictEqual(Progression.isZoneTransition(91), true);
    assert.strictEqual(Progression.isZoneTransition(101), true);
});

test('Progression - 10 thematic zones lookup', () => {
    const expectedZones = [
        { level: 1, index: 1, name: 'Outer Terrace', desc: 'Foundations & Flow' },
        { level: 10, index: 1, name: 'Outer Terrace', desc: 'Foundations & Flow' },
        { level: 11, index: 2, name: 'Clockwork Shaft', desc: 'Rhythmic Descent' },
        { level: 25, index: 3, name: 'Prism Corridors', desc: 'Precision Navigation' },
        { level: 35, index: 4, name: 'Sector Shifts', desc: 'Shifting Sectors' },
        { level: 45, index: 5, name: 'The Crucible', desc: 'Midpoint Gauntlet' },
        { level: 55, index: 6, name: 'Shadow Spiral', desc: 'Narrow Margins' },
        { level: 70, index: 7, name: 'Pulse Conduit', desc: 'Pulse Velocity' },
        { level: 75, index: 8, name: 'The Labyrinth', desc: 'Complex Labyrinth' },
        { level: 85, index: 9, name: 'Inferno Core', desc: 'Grandmaster Trial' },
        { level: 100, index: 10, name: 'The Monolith', desc: 'The Summit Finale' }
    ];

    for (const z of expectedZones) {
        assert.strictEqual(Progression.getZoneIndex(z.level), z.index);
        assert.strictEqual(Progression.getZoneName(z.level), z.name);
        assert.strictEqual(Progression.getZoneDescription(z.level), z.desc);
        assert.strictEqual(Progression.getZoneTitle(z.level), `Zone ${z.index}: ${z.name}`);
    }
});

test('Progression - nearest checkpoint calculation', () => {
    const cps = [1, 6, 11, 16];

    assert.strictEqual(Progression.getNearestCheckpoint(5, cps, 1), 1);
    assert.strictEqual(Progression.getNearestCheckpoint(6, cps, 1), 6);
    assert.strictEqual(Progression.getNearestCheckpoint(9, cps, 1), 6);
    assert.strictEqual(Progression.getNearestCheckpoint(14, cps, 1), 11);
    assert.strictEqual(Progression.getNearestCheckpoint(20, cps, 1), 16);

    // Permadeath mode always returns 1
    assert.strictEqual(Progression.getNearestCheckpoint(20, cps, 3), 1);
});

test('Progression - checkpoint unlocking rules', () => {
    let cps = [1];
    cps = Progression.unlockCheckpoint(6, cps, 1);
    assert.deepStrictEqual(cps, [1, 6]);

    // Unlocking duplicate checkpoint does not duplicate
    cps = Progression.unlockCheckpoint(6, cps, 1);
    assert.deepStrictEqual(cps, [1, 6]);

    // Non-checkpoint level does not unlock
    cps = Progression.unlockCheckpoint(7, cps, 1);
    assert.deepStrictEqual(cps, [1, 6]);

    // Insane mode never unlocks
    cps = Progression.unlockCheckpoint(11, cps, 3);
    assert.deepStrictEqual(cps, [1, 6]);
});

test('Progression - level tier and base checkpoint score', () => {
    assert.strictEqual(Progression.getLevelTier(1), 1);
    assert.strictEqual(Progression.getLevelTier(5), 1);
    assert.strictEqual(Progression.getLevelTier(6), 2);
    assert.strictEqual(Progression.getLevelTier(11), 3);

    // Starting at level 1 or insane mode has 0 base score
    assert.strictEqual(Progression.getCheckpointBaseScore(1, 1), 0);
    assert.strictEqual(Progression.getCheckpointBaseScore(11, 3), 0);

    // Checkpoint base score accumulates rewards for skipped levels
    const normalScore = Progression.getCheckpointBaseScore(6, 1);
    assert.ok(normalScore > 0, 'Normal checkpoint score should be positive');

    const easyScore = Progression.getCheckpointBaseScore(6, 0);
    const hardScore = Progression.getCheckpointBaseScore(6, 2);
    assert.ok(easyScore < normalScore, 'Easy checkpoint score should be lower than Normal');
    assert.ok(hardScore > normalScore, 'Hard checkpoint score should be higher than Normal');
});

test('Progression - level progress percentage clamping', () => {
    const ringSpacing = 140;
    const ringsPerLevel = 20;

    // Beginning of level 1
    assert.strictEqual(Progression.calculateLevelProgress(0, 1, ringSpacing, ringsPerLevel), 0.0);

    // Halfway through level 1
    const halfwayY = 10 * ringSpacing;
    const progress = Progression.calculateLevelProgress(halfwayY, 1, ringSpacing, ringsPerLevel);
    assert.ok(Math.abs(progress - 0.5) < 0.001);

    // Clamping limits
    assert.strictEqual(Progression.calculateLevelProgress(-100, 1, ringSpacing, ringsPerLevel), 0.0);
    assert.strictEqual(Progression.calculateLevelProgress(50 * ringSpacing, 1, ringSpacing, ringsPerLevel), 1.0);
});
