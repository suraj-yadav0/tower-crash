.pragma library
.import QtQuick.LocalStorage 2.0 as Sql

function getDatabase() {
    return Sql.LocalStorage.openDatabaseSync("TowerCrashDB", "1.0", "Tower Crash Persistence", 100000);
}

function loadStats() {
    var stats = {
        bestScore: 0,
        totalRings: 0,
        soundEnabled: true,
        hapticsEnabled: true,
        speedMode: 1,
        themeMode: 0,
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
                if (row.k === "bestScore") stats.bestScore = parseInt(row.v) || 0;
                else if (row.k === "totalRings") stats.totalRings = parseInt(row.v) || 0;
                else if (row.k === "soundEnabled") stats.soundEnabled = (row.v !== "0");
                else if (row.k === "hapticsEnabled") stats.hapticsEnabled = (row.v !== "0");
                else if (row.k === "speedMode") stats.speedMode = parseInt(row.v) || 1;
                else if (row.k === "themeMode") stats.themeMode = parseInt(row.v) || 0;
                else if (row.k === "highestLevelReached") stats.highestLevelReached = Math.max(1, parseInt(row.v) || 1);
                else if (row.k === "selectedCheckpoint") stats.selectedCheckpoint = Math.max(1, parseInt(row.v) || 1);
                else if (row.k === "unlockedCheckpoints") {
                    try {
                        var parsed = JSON.parse(row.v);
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

    return stats;
}

function saveStat(key, val) {
    try {
        var db = getDatabase();
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS kv(k TEXT UNIQUE, v TEXT)');
            tx.executeSql('INSERT OR REPLACE INTO kv VALUES(?, ?)', [key, val.toString()]);
        });
    } catch (e) {}
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

