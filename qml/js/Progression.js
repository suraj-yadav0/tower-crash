.pragma library

function isCheckpointLevel(lvl) {
    return lvl === 1 || (lvl > 1 && (lvl - 1) % 5 === 0);
}

function isZoneTransition(lvl) {
    return lvl > 1 && (lvl % 10 === 1);
}

function getNearestCheckpoint(lvl, unlockedCheckpoints) {
    var nearest = 1;
    var list = unlockedCheckpoints || [1];
    for (var i = 0; i < list.length; i++) {
        var cp = list[i];
        if (cp <= lvl && cp > nearest) {
            nearest = cp;
        }
    }
    return nearest;
}

function unlockCheckpoint(lvl, unlockedCheckpoints) {
    if (!isCheckpointLevel(lvl)) return unlockedCheckpoints || [1];
    var list = (unlockedCheckpoints || [1]).slice();
    if (list.indexOf(lvl) === -1) {
        list.push(lvl);
        list.sort(function(a, b) { return a - b; });
    }
    return list;
}

function calculateLevel(ballY, ringSpacing, levelRings, offset) {
    var off = offset || 0;
    return Math.floor(Math.max(0, ballY - off) / (ringSpacing * levelRings)) + 1;
}

function calculateLevelProgress(ballY, currentLevel, ringSpacing, levelRings) {
    var depthInLevel = (Math.max(0, ballY) / ringSpacing) - (currentLevel - 1) * levelRings;
    return Math.min(1.0, Math.max(0.0, depthInLevel / levelRings));
}
