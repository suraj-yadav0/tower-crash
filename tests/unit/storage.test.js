const test = require('node:test');
const assert = require('node:assert');
const { loadQmlModule } = require('../helpers/qml-module-loader');
const { createMockLocalStorage } = require('../helpers/mock-local-storage');

function setupStorage() {
    const { Sql, _store } = createMockLocalStorage();
    const Storage = loadQmlModule('qml/js/Storage.js', { Sql });
    return { Storage, _store };
}

test('Storage - default values on empty database', () => {
    const { Storage } = setupStorage();
    const stats = Storage.loadStats(true);

    assert.strictEqual(stats.difficultyMode, 1);
    assert.strictEqual(stats.bestScore, 0);
    assert.strictEqual(stats.highestLevelReached, 1);
    assert.strictEqual(stats.speedMode, 1);
    assert.deepStrictEqual([...stats.unlockedCheckpoints], [1]);
    assert.strictEqual(stats.selectedCheckpoint, 1);
});

test('Storage - speedMode 0 preservation (falsy 0 bug fix)', () => {
    const { Storage, _store } = setupStorage();

    // Directly simulate speedMode stored as "0" in sqlite
    _store.set('speedMode', '0');

    const stats = Storage.loadStats(true);
    assert.strictEqual(stats.speedMode, 0, 'speedMode 0 must not be overridden with 1');
});

test('Storage - isolated difficulty best scores', () => {
    const { Storage } = setupStorage();
    Storage.loadStats(true);

    Storage.saveDifficultyMode(1);
    Storage.saveBestScoreForMode(1200, 1);

    Storage.saveBestScoreForMode(450, 0);
    Storage.saveBestScoreForMode(3000, 2);
    Storage.saveBestScoreForMode(5000, 3);

    const stats0 = Storage.getDifficultyStats(0);
    const stats1 = Storage.getDifficultyStats(1);
    const stats2 = Storage.getDifficultyStats(2);
    const stats3 = Storage.getDifficultyStats(3);

    assert.strictEqual(stats0.bestScore, 450);
    assert.strictEqual(stats1.bestScore, 1200);
    assert.strictEqual(stats2.bestScore, 3000);
    assert.strictEqual(stats3.bestScore, 5000);
});

test('Storage - isolated highest level reached', () => {
    const { Storage } = setupStorage();
    Storage.loadStats(true);

    Storage.saveHighestLevelForMode(15, 0);
    Storage.saveHighestLevelForMode(32, 1);
    Storage.saveHighestLevelForMode(8, 2);
    Storage.saveHighestLevelForMode(3, 3);

    assert.strictEqual(Storage.getDifficultyStats(0).highestLevelReached, 15);
    assert.strictEqual(Storage.getDifficultyStats(1).highestLevelReached, 32);
    assert.strictEqual(Storage.getDifficultyStats(2).highestLevelReached, 8);
    assert.strictEqual(Storage.getDifficultyStats(3).highestLevelReached, 3);
});

test('Storage - checkpoints isolated and Insane mode locked to level 1', () => {
    const { Storage } = setupStorage();
    Storage.loadStats(true);

    // Save checkpoints for Normal mode
    Storage.saveUnlockedCheckpointsForMode([1, 6, 11, 16], 1);
    Storage.saveSelectedCheckpointForMode(11, 1);

    // Attempt to save checkpoints for Insane mode (must be ignored)
    Storage.saveUnlockedCheckpointsForMode([1, 6, 11], 3);
    Storage.saveSelectedCheckpointForMode(11, 3);

    const normalStats = Storage.getDifficultyStats(1);
    const insaneStats = Storage.getDifficultyStats(3);

    assert.deepStrictEqual([...normalStats.unlockedCheckpoints], [1, 6, 11, 16]);
    assert.strictEqual(normalStats.selectedCheckpoint, 11);

    assert.deepStrictEqual([...insaneStats.unlockedCheckpoints], [1]);
    assert.strictEqual(insaneStats.selectedCheckpoint, 1);
});

test('Storage - write queue and flushPendingWrites', () => {
    const { Storage, _store } = setupStorage();
    Storage.loadStats(true);

    Storage.queueStat('totalRings', 85);
    Storage.queueStat('lifetimeScore', 12500);

    // Not yet written to persistent store
    assert.strictEqual(_store.has('totalRings'), false);

    // Flush batch
    Storage.flushPendingWrites();

    assert.strictEqual(_store.get('totalRings'), '85');
    assert.strictEqual(_store.get('lifetimeScore'), '12500');
});

test('Storage - backfills missing checkpoints up to highest level', () => {
    const { Storage, _store } = setupStorage();

    // Highest level is 17 in DB, but unlockedCheckpoints was stored as only [1]
    _store.set('highestLevel_1', '17');
    _store.set('unlockedCheckpoints_1', JSON.stringify([1]));

    const stats = Storage.loadStats(true);
    const diff1 = Storage.getDifficultyStats(1);

    // Levels 6, 11, 16 should be automatically backfilled
    assert.deepStrictEqual([...diff1.unlockedCheckpoints], [1, 6, 11, 16]);
});
