.pragma library
.import QtQuick.LocalStorage 2.0 as Sql

var _cache = null;
var _dirty = {};

function getDatabase() {
    var db = Sql.LocalStorage.openDatabaseSync("TowerCrashDB", "", "Tower Crash Persistence", 100000);
    if (db.version === "" || db.version === "1.0") {
        try {
            db.changeVersion(db.version, "1.1", function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS kv(k TEXT UNIQUE, v TEXT)');
            });
        } catch (e) {
            // Version already changed or changeVersion not supported
        }
    }
    return db;
}

function loadStats(forceReload) {
    if (_cache && !forceReload) {
        return _cache;
    }

    var stats = {
        bestScore: 0,
        totalRings: 0,
        lifetimeScore: 0,
        maxComboStreak: 0,
        completedStagesCount: 0,
        totalPlayTimeSeconds: 0,
        gamesPlayedCount: 0,
        gameCleared: false,
        soundEnabled: true,
        hapticsEnabled: true,
        speedMode: 1,
        themeMode: 0,
        touchSensitivityMultiplier: 1.0,
        highestLevelReached: 1,
        unlockedCheckpoints: [1],
        selectedCheckpoint: 1
    };

    try {
        var db = getDatabase();
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS kv(k TEXT UNIQUE, v TEXT)');
            var rs = tx.executeSql('SELECT k, v FROM kv');
            for (var i = 0; i < rs.rows.length; i++) {
                var row = rs.rows.item(i);
                var k = row.k;
                var v = row.v;
                if (k === "bestScore") stats.bestScore = parseInt(v) || 0;
                else if (k === "totalRings" || k === "totalRingsSmashed") stats.totalRings = parseInt(v) || 0;
                else if (k === "lifetimeScore") stats.lifetimeScore = parseInt(v) || 0;
                else if (k === "maxComboStreak") stats.maxComboStreak = parseInt(v) || 0;
                else if (k === "completedStagesCount") stats.completedStagesCount = parseInt(v) || 0;
                else if (k === "totalPlayTimeSeconds") stats.totalPlayTimeSeconds = parseInt(v) || 0;
                else if (k === "gamesPlayedCount") stats.gamesPlayedCount = parseInt(v) || 0;
                else if (k === "gameCleared") stats.gameCleared = (v === "1");
                else if (k === "soundEnabled") stats.soundEnabled = (v !== "0");
                else if (k === "hapticsEnabled") stats.hapticsEnabled = (v !== "0");
                else if (k === "speedMode") stats.speedMode = parseInt(v) || 1;
                else if (k === "themeMode") stats.themeMode = parseInt(v) || 0;
                else if (k === "touchSensitivityMultiplier") stats.touchSensitivityMultiplier = parseFloat(v) || 1.0;
                else if (k === "highestLevelReached") stats.highestLevelReached = Math.max(1, parseInt(v) || 1);
                else if (k === "selectedCheckpoint") stats.selectedCheckpoint = Math.max(1, parseInt(v) || 1);
                else if (k === "unlockedCheckpoints") {
                    try {
                        var parsed = JSON.parse(v);
                        if (Array.isArray(parsed) && parsed.length > 0) {
                            stats.unlockedCheckpoints = parsed;
                        }
                    } catch (err) {}
                }
            }
        });
    } catch (e) {}

    // Unlock checkpoints up to highest level reached
    for (var lvl = 1; lvl <= stats.highestLevelReached; lvl += 5) {
        if (stats.unlockedCheckpoints.indexOf(lvl) === -1) {
            stats.unlockedCheckpoints.push(lvl);
        }
    }
    stats.unlockedCheckpoints.sort(function(a, b) { return a - b; });

    _cache = stats;
    return stats;
}

function flushPendingWrites() {
    var keys = Object.keys(_dirty);
    if (keys.length === 0) return;
    try {
        var db = getDatabase();
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS kv(k TEXT UNIQUE, v TEXT)');
            for (var i = 0; i < keys.length; i++) {
                var k = keys[i];
                var v = _dirty[k] != null ? _dirty[k].toString() : "";
                tx.executeSql('INSERT OR REPLACE INTO kv VALUES(?, ?)', [k, v]);
            }
        });
        _dirty = {};
    } catch (e) {}
}

function saveStat(key, val) {
    if (!_cache) _cache = {};
    _cache[key] = val;
    _dirty[key] = val;
    flushPendingWrites();
}

function queueStat(key, val) {
    if (!_cache) _cache = {};
    _cache[key] = val;
    _dirty[key] = val;
}

function getStat(key, fallback) {
    if (_cache && _cache[key] !== undefined) {
        return _cache[key];
    }
    return fallback;
}

function saveHighestLevel(level) {
    saveStat("highestLevelReached", Math.max(1, parseInt(level) || 1));
}

function saveUnlockedCheckpoints(checkpoints) {
    if (Array.isArray(checkpoints)) {
        saveStat("unlockedCheckpoints", JSON.stringify(checkpoints));
    }
}

function saveSelectedCheckpoint(level) {
    saveStat("selectedCheckpoint", Math.max(1, parseInt(level) || 1));
}

function recordGamePlayed() {
    var count = (getStat("gamesPlayedCount", 0) || 0) + 1;
    saveStat("gamesPlayedCount", count);
}

function recordComboStreak(streak) {
    var currentMax = getStat("maxComboStreak", 0) || 0;
    if (streak > currentMax) {
        saveStat("maxComboStreak", streak);
    }
}

function recordStageCompleted(points) {
    var stages = (getStat("completedStagesCount", 0) || 0) + 1;
    var lifetime = (getStat("lifetimeScore", 0) || 0) + (points || 0);
    queueStat("completedStagesCount", stages);
    queueStat("lifetimeScore", lifetime);
    flushPendingWrites();
}

function recordPlayTime(seconds) {
    var total = (getStat("totalPlayTimeSeconds", 0) || 0) + (seconds || 0);
    queueStat("totalPlayTimeSeconds", Math.round(total));
}
