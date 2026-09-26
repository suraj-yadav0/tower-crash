.pragma library

function getDifficultyName(mode) {
    var m = (mode !== undefined) ? mode : 1;
    switch (m) {
        case 0: return "Easy";
        case 2: return "Hard";
        case 3: return "Insane";
        case 1:
        default: return "Normal";
    }
}

function getDifficultyScoreMultiplier(mode) {
    var m = (mode !== undefined) ? mode : 1;
    switch (m) {
        case 0: return 0.8;
        case 2: return 1.5;
        case 3: return 2.5;
        case 1:
        default: return 1.0;
    }
}

function getDifficultySpeedMultiplier(mode) {
    var m = (mode !== undefined) ? mode : 1;
    switch (m) {
        case 0: return 0.88;
        case 2: return 1.12;
        case 3: return 1.25;
        case 1:
        default: return 1.0;
    }
}

function hasCheckpoints(mode) {
    return mode !== 3;
}

function isCheckpointLevel(lvl, mode) {
    if (mode === 3) return false;
    return lvl === 1 || (lvl > 1 && (lvl - 1) % 5 === 0);
}

function isZoneTransition(lvl) {
    return lvl > 1 && (lvl % 10 === 1);
}

function getZoneIndex(lvl) {
    var l = (lvl !== undefined && lvl > 0) ? lvl : 1;
    return Math.min(10, Math.max(1, Math.floor((l - 1) / 10) + 1));
}

function getZoneName(lvl) {
    var zone = getZoneIndex(lvl);
    switch (zone) {
        case 1: return "Outer Terrace";
        case 2: return "Clockwork Shaft";
        case 3: return "Prism Corridors";
        case 4: return "Sector Shifts";
        case 5: return "The Crucible";
        case 6: return "Shadow Spiral";
        case 7: return "Pulse Conduit";
        case 8: return "The Labyrinth";
        case 9: return "Inferno Core";
        case 10: return "The Monolith";
        default: return "Outer Terrace";
    }
}

function getZoneTitle(lvl) {
    var z = getZoneIndex(lvl);
    return "Zone " + z + ": " + getZoneName(lvl);
}

function getZoneDescription(lvl) {
    var zone = getZoneIndex(lvl);
    switch (zone) {
        case 1: return "Foundations & Flow";
        case 2: return "Rhythmic Descent";
        case 3: return "Precision Navigation";
        case 4: return "Shifting Sectors";
        case 5: return "Midpoint Gauntlet";
        case 6: return "Narrow Margins";
        case 7: return "Pulse Velocity";
        case 8: return "Complex Labyrinth";
        case 9: return "Grandmaster Trial";
        case 10: return "The Summit Finale";
        default: return "Foundations & Flow";
    }
}

function getNearestCheckpoint(lvl, unlockedCheckpoints, mode) {
    if (mode === 3) return 1;
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

function unlockCheckpoint(lvl, unlockedCheckpoints, mode) {
    if (mode === 3 || !isCheckpointLevel(lvl, mode)) return unlockedCheckpoints || [1];
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

function getLevelTier(lvl) {
    return Math.max(1, Math.floor((lvl - 1) / 5) + 1);
}

function getCheckpointBaseScore(startLevel, mode) {
    var m = (mode !== undefined) ? mode : 1;
    if (!startLevel || startLevel <= 1 || m === 3) return 0;
    var mult = getDifficultyScoreMultiplier(m);
    var total = 0;
    for (var lvl = 1; lvl < startLevel; lvl++) {
        var tier = getLevelTier(lvl);
        var ringBase = 20 * tier * mult;
        var stageBonus = 100 * mult;
        if (lvl % 10 === 0) {
            stageBonus = 250 * mult;
        } else if (lvl % 5 === 0) {
            stageBonus = 150 * mult;
        }
        total += Math.round(ringBase + stageBonus);
    }
    return total;
}
