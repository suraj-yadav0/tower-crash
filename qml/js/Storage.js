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
        speedMode: 1
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
            }
        });
    } catch (e) {}

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
