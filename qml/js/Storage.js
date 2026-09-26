.pragma library
.import QtQuick.LocalStorage 2.0 as Sql

var _cache = null;
var _dirty = {};

function getDatabase() {
    var db = Sql.LocalStorage.openDatabaseSync("TowerCrashDB", "", "Tower Crash Persistence", 100000);
    try {
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS kv(k TEXT UNIQUE, v TEXT)');
        });
    } catch (e) {
        console.log("Storage.getDatabase table creation error:", e);
    }
    return db;
}

function loadStats(forceReload) {
    if (_cache && !forceReload) {
        return _cache;
    }

    var stats = {
        difficultyMode: 1,
        bestScore: 0,
        bestScore_0: 0,
        bestScore_1: 0,
        bestScore_2: 0,
        bestScore_3: 0,
        highestLevel_0: 1,
        highestLevel_1: 1,
        highestLevel_2: 1,
        highestLevel_3: 1,
        unlockedCheckpoints_0: [1],
        unlockedCheckpoints_1: [1],
        unlockedCheckpoints_2: [1],
        unlockedCheckpoints_3: [1],
        selectedCheckpoint_0: 1,
        selectedCheckpoint_1: 1,
        selectedCheckpoint_2: 1,
        selectedCheckpoint_3: 1,
        totalRings: 0,
        lifetimeScore: 0,
        maxComboStreak: 0,
        completedStagesCount: 0,
        totalPlayTimeSeconds: 0,
        gamesPlayedCount: 0,
        gameCleared: false,
        soundEnabled: true,
        soundVolume: 0.85,
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
                if (k === "difficultyMode") {
                    var parsedMode = parseInt(v);
                    if (!isNaN(parsedMode) && parsedMode >= 0 && parsedMode <= 3) {
                        stats.difficultyMode = parsedMode;
                    }
                }
                else if (k === "bestScore") stats.bestScore = parseInt(v) || 0;
                else if (k.indexOf("bestScore_") === 0) stats[k] = parseInt(v) || 0;
                else if (k.indexOf("highestLevel_") === 0) stats[k] = Math.max(1, parseInt(v) || 1);
                else if (k.indexOf("selectedCheckpoint_") === 0) stats[k] = Math.max(1, parseInt(v) || 1);
                else if (k.indexOf("unlockedCheckpoints_") === 0) {
                    try {
                        var parsedCp = JSON.parse(v);
                        if (Array.isArray(parsedCp) && parsedCp.length > 0) {
                            stats[k] = parsedCp.map(function(n) { return parseInt(n) || 1; });
                        }
                    } catch (err) {}
                }
                else if (k === "totalRings" || k === "totalRingsSmashed") stats.totalRings = parseInt(v) || 0;
                else if (k === "lifetimeScore") stats.lifetimeScore = parseInt(v) || 0;
                else if (k === "maxComboStreak") stats.maxComboStreak = parseInt(v) || 0;
                else if (k === "completedStagesCount") stats.completedStagesCount = parseInt(v) || 0;
                else if (k === "totalPlayTimeSeconds") stats.totalPlayTimeSeconds = parseInt(v) || 0;
                else if (k === "gamesPlayedCount") stats.gamesPlayedCount = parseInt(v) || 0;
                else if (k === "gameCleared") stats.gameCleared = (v === "1");
                else if (k === "soundEnabled") stats.soundEnabled = (v !== "0");
                else if (k === "soundVolume") stats.soundVolume = (parseFloat(v) >= 0.0) ? Math.min(1.0, Math.max(0.0, parseFloat(v))) : 0.85;
                else if (k === "hapticsEnabled") stats.hapticsEnabled = (v !== "0");
                else if (k === "speedMode") {
                    var parsedSpeed = parseInt(v);
                    if (!isNaN(parsedSpeed) && parsedSpeed >= 0 && parsedSpeed <= 2) {
                        stats.speedMode = parsedSpeed;
                    }
                }
                else if (k === "themeMode") stats.themeMode = !isNaN(parseInt(v)) ? parseInt(v) : 0;
                else if (k === "touchSensitivityMultiplier") stats.touchSensitivityMultiplier = parseFloat(v) || 1.0;
                else if (k === "highestLevelReached") stats.highestLevelReached = Math.max(1, parseInt(v) || 1);
                else if (k === "selectedCheckpoint") stats.selectedCheckpoint = Math.max(1, parseInt(v) || 1);
                else if (k === "unlockedCheckpoints") {
                    try {
                        var parsed = JSON.parse(v);
                        if (Array.isArray(parsed) && parsed.length > 0) {
                            stats.unlockedCheckpoints = parsed.map(function(n) { return parseInt(n) || 1; });
                        }
                    } catch (err) {}
                }
            }
        });
    } catch (e) {
        console.log("Storage.loadStats error:", e);
    }

    // Backward compatibility: link un-suffixed records to Normal mode (1)
    if (!stats.bestScore_1 && stats.bestScore > 0) stats.bestScore_1 = stats.bestScore;
    if (stats.highestLevel_1 === 1 && stats.highestLevelReached > 1) stats.highestLevel_1 = stats.highestLevelReached;
    if (stats.unlockedCheckpoints_1.length === 1 && stats.unlockedCheckpoints.length > 1) {
        stats.unlockedCheckpoints_1 = stats.unlockedCheckpoints.slice();
    }
    if (stats.selectedCheckpoint_1 === 1 && stats.selectedCheckpoint > 1) {
        stats.selectedCheckpoint_1 = stats.selectedCheckpoint;
    }

    // Insane mode (3) strictly has no checkpoints
    stats.unlockedCheckpoints_3 = [1];
    stats.selectedCheckpoint_3 = 1;

    // Backfill checkpoints for non-permadeath modes
    for (var m = 0; m < 3; m++) {
        var high = stats["highestLevel_" + m] || 1;
        var cps = (stats["unlockedCheckpoints_" + m] || [1]).slice();
        for (var lvl = 1; lvl <= high; lvl += 5) {
            if (cps.indexOf(lvl) === -1) {
                cps.push(lvl);
            }
        }
        cps.sort(function(a, b) { return a - b; });
        stats["unlockedCheckpoints_" + m] = cps;

        var sel = stats["selectedCheckpoint_" + m] || 1;
        if (cps.indexOf(sel) === -1) {
            stats["selectedCheckpoint_" + m] = cps[cps.length - 1] || 1;
        }
    }

    // Set active stats for the loaded difficulty mode
    var activeMode = stats.difficultyMode;
    stats.bestScore = stats["bestScore_" + activeMode] || 0;
    stats.highestLevelReached = stats["highestLevel_" + activeMode] || 1;
    stats.unlockedCheckpoints = (activeMode === 3) ? [1] : (stats["unlockedCheckpoints_" + activeMode] || [1]);
    stats.selectedCheckpoint = (activeMode === 3) ? 1 : (stats["selectedCheckpoint_" + activeMode] || 1);

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
    } catch (e) {
        console.log("Storage.flushPendingWrites error:", e);
    }
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

function getDifficultyStats(mode) {
    if (!_cache) loadStats();
    var m = Math.max(0, Math.min(3, parseInt(mode) || 0));

    var rawCp = (m === 3) ? [1] : (_cache["unlockedCheckpoints_" + m] || [1]);
    var cpList = [1];
    if (Array.isArray(rawCp)) {
        cpList = rawCp.slice();
    } else if (typeof rawCp === "string") {
        try {
            var parsed = JSON.parse(rawCp);
            if (Array.isArray(parsed) && parsed.length > 0) cpList = parsed;
        } catch (e) {}
    }

    var high = Math.max(1, parseInt(_cache["highestLevel_" + m]) || 1);
    if (m !== 3) {
        for (var lvl = 1; lvl <= high; lvl += 5) {
            if (cpList.indexOf(lvl) === -1) {
                cpList.push(lvl);
            }
        }
        cpList.sort(function(a, b) { return a - b; });
    }

    var selCp = (m === 3) ? 1 : Math.max(1, parseInt(_cache["selectedCheckpoint_" + m]) || 1);
    if (cpList.indexOf(selCp) === -1) {
        selCp = cpList[cpList.length - 1] || 1;
    }

    return {
        bestScore: Math.max(0, parseInt(_cache["bestScore_" + m]) || 0),
        highestLevelReached: high,
        unlockedCheckpoints: cpList,
        selectedCheckpoint: selCp
    };
}

function saveDifficultyMode(mode) {
    var m = Math.max(0, Math.min(3, parseInt(mode) || 0));
    saveStat("difficultyMode", m);
    if (_cache) {
        _cache.difficultyMode = m;
        _cache.bestScore = Math.max(0, parseInt(_cache["bestScore_" + m]) || 0);
        _cache.highestLevelReached = Math.max(1, parseInt(_cache["highestLevel_" + m]) || 1);
        _cache.unlockedCheckpoints = (m === 3) ? [1] : (_cache["unlockedCheckpoints_" + m] || [1]);
        _cache.selectedCheckpoint = (m === 3) ? 1 : (_cache["selectedCheckpoint_" + m] || 1);
    }
}

function saveBestScoreForMode(score, mode) {
    var m = Math.max(0, Math.min(3, parseInt(mode) || 0));
    var val = Math.max(0, parseInt(score) || 0);
    saveStat("bestScore_" + m, val);
    if (!_cache) _cache = {};
    _cache["bestScore_" + m] = val;
    if (m === 1 || (_cache.difficultyMode !== undefined && m === _cache.difficultyMode)) {
        saveStat("bestScore", val);
        _cache.bestScore = val;
    }
}

function saveHighestLevelForMode(level, mode) {
    var m = Math.max(0, Math.min(3, parseInt(mode) || 0));
    var val = Math.max(1, parseInt(level) || 1);
    saveStat("highestLevel_" + m, val);
    if (!_cache) _cache = {};
    _cache["highestLevel_" + m] = val;
    if (m === 1 || (_cache.difficultyMode !== undefined && m === _cache.difficultyMode)) {
        saveStat("highestLevelReached", val);
        _cache.highestLevelReached = val;
    }
}

function saveUnlockedCheckpointsForMode(checkpoints, mode) {
    var m = Math.max(0, Math.min(3, parseInt(mode) || 0));
    if (m === 3) return;
    if (Array.isArray(checkpoints)) {
        var clean = checkpoints.map(function(n) { return parseInt(n) || 1; });
        clean.sort(function(a, b) { return a - b; });
        var str = JSON.stringify(clean);
        saveStat("unlockedCheckpoints_" + m, str);
        if (!_cache) _cache = {};
        _cache["unlockedCheckpoints_" + m] = clean.slice();
        if (m === 1 || (_cache.difficultyMode !== undefined && m === _cache.difficultyMode)) {
            saveStat("unlockedCheckpoints", str);
            _cache.unlockedCheckpoints = clean.slice();
        }
    }
}

function saveSelectedCheckpointForMode(checkpoint, mode) {
    var m = Math.max(0, Math.min(3, parseInt(mode) || 0));
    if (m === 3) return;
    var val = Math.max(1, parseInt(checkpoint) || 1);
    saveStat("selectedCheckpoint_" + m, val);
    if (!_cache) _cache = {};
    _cache["selectedCheckpoint_" + m] = val;
    if (m === 1 || (_cache.difficultyMode !== undefined && m === _cache.difficultyMode)) {
        saveStat("selectedCheckpoint", val);
        _cache.selectedCheckpoint = val;
    }
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

function saveSoundVolume(volume) {
    var vol = Math.max(0.0, Math.min(1.0, parseFloat(volume) || 0.0));
    saveStat("soundVolume", vol.toFixed(2));
}

function saveTouchSensitivity(multiplier) {
    var mult = Math.max(0.4, Math.min(2.5, parseFloat(multiplier) || 1.0));
    saveStat("touchSensitivityMultiplier", mult.toFixed(2));
}
