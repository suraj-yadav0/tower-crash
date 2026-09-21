.pragma library

function createRing(index, ringSpacing) {
    var ringY = (index + 1) * ringSpacing;
    var segments = [0, 0, 0, 0, 0, 0, 0, 0];
    var isGoal = (index > 0 && (index + 1) % 20 === 0);

    if (index === 0) {
        segments[2] = 0;
        segments[6] = 1;
    } else if (isGoal) {
        for (var s = 0; s < 8; s++) {
            segments[s] = 0;
        }
    } else {
        var gapCount = 1;
        if (index > 4 && Math.random() < 0.45) {
            gapCount = 2;
        }

        var deadlyCount = 1;
        if (index >= 5 && index < 15) {
            deadlyCount = 2;
        } else if (index >= 15 && index < 30) {
            deadlyCount = Math.random() < 0.5 ? 2 : 3;
        } else if (index >= 30) {
            deadlyCount = Math.random() < 0.4 ? 3 : 4;
        }

        var slots = [0, 1, 2, 3, 4, 5, 6, 7];
        for (var si = slots.length - 1; si > 0; si--) {
            var randIdx = Math.floor(Math.random() * (si + 1));
            var temp = slots[si];
            slots[si] = slots[randIdx];
            slots[randIdx] = temp;
        }

        var ptr = 0;
        for (var g = 0; g < gapCount && ptr < slots.length; g++) {
            segments[slots[ptr++]] = 1;
        }
        for (var d = 0; d < deadlyCount && ptr < slots.length; d++) {
            segments[slots[ptr++]] = 2;
        }
    }

    return {
        index: index,
        y: ringY,
        segments: segments,
        passed: false,
        broken: false,
        isGoal: isGoal,
        goalAwarded: false,
        recoil: 0.0,
        recoilVelocity: 0.0,
        shockwaves: [],
        splats: []
    };
}
