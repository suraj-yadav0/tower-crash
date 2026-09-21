.pragma library

var lastGapStart = 5;

function resetGenerator() {
    lastGapStart = 5;
}

function createRing(index, ringSpacing, prevRing) {
    var ringY = (index + 1) * ringSpacing;
    var segments = [0, 0, 0, 0, 0, 0, 0, 0];
    var levelRings = 20;
    var level = Math.floor(index / levelRings) + 1;
    var posInLevel = index % levelRings;
    var isGoal = (index > 0 && (index + 1) % levelRings === 0);

    if (index === 0) {
        // Starting ring: player starts bouncing on slot 2 (front center).
        // Provide a wide, generous 3-segment opening at slots 5, 6, 7 (opposite side).
        // Zero hazards.
        segments[1] = 0;
        segments[2] = 0;
        segments[3] = 0;
        segments[5] = 1;
        segments[6] = 1;
        segments[7] = 1;
        lastGapStart = 5;
    } else if (isGoal) {
        // Goal platform at the end of each level: all segments safe.
        for (var s = 0; s < 8; s++) {
            segments[s] = 0;
        }
        lastGapStart = (lastGapStart + 1) % 8;
    } else {
        // Progressive difficulty calculation based on level and position in level.
        var gapWidth = 2;
        var hazardCount = 0;
        var maxOffset = 1;

        if (level === 1) {
            // Level 1: Gentle introduction.
            // Rings 1 to 6: 3-segment wide opening (135 degrees), 0 hazards.
            // Rings 7 to 18: 2-segment opening (90 degrees), 1 hazard placed opposite.
            if (posInLevel <= 6) {
                gapWidth = 3;
                hazardCount = 0;
                maxOffset = 1;
            } else {
                gapWidth = 2;
                hazardCount = 1;
                maxOffset = 1;
            }
        } else if (level === 2) {
            // Level 2: Finding flow.
            // 2-segment opening, 1 to 2 hazards placed away from landing zone.
            gapWidth = 2;
            hazardCount = (posInLevel < 10) ? 1 : (Math.random() < 0.5 ? 1 : 2);
            maxOffset = 2;
        } else if (level === 3) {
            // Level 3: Intermediate challenge.
            // Alternating 2-segment and 1-segment openings, 2 hazards.
            gapWidth = (Math.random() < 0.65) ? 2 : 1;
            hazardCount = 2;
            maxOffset = 3;
        } else if (level === 4) {
            // Level 4: Advanced descent.
            // Mostly 1-segment openings, 2 to 3 hazards.
            gapWidth = (Math.random() < 0.35) ? 2 : 1;
            hazardCount = (Math.random() < 0.4) ? 2 : 3;
            maxOffset = 3;
        } else {
            // Level 5+: Master tier.
            // Narrow 1-segment openings, 3 to 4 hazards.
            gapWidth = 1;
            var extraHazards = Math.min(1, Math.floor((level - 5) / 2));
            hazardCount = Math.min(4, 3 + extraHazards);
            maxOffset = 4;
        }

        // Determine reference gap position from previous ring if available
        var refGap = lastGapStart;
        if (prevRing && prevRing.segments) {
            for (var ps = 0; ps < 8; ps++) {
                if (prevRing.segments[ps] === 1) {
                    refGap = ps;
                    break;
                }
            }
        }

        // Calculate new gap position with constrained offset
        var offsetChoice;
        if (maxOffset <= 1) {
            var offsets = [0, 1, -1];
            offsetChoice = offsets[Math.floor(Math.random() * offsets.length)];
        } else {
            var range = maxOffset * 2 + 1;
            offsetChoice = Math.floor(Math.random() * range) - maxOffset;
            if (offsetChoice === 0 && Math.random() < 0.5) {
                offsetChoice = (Math.random() < 0.5) ? 1 : -1;
            }
        }

        var newGapStart = (refGap + offsetChoice + 8) % 8;
        lastGapStart = newGapStart;

        // Mark gap segments
        for (var gw = 0; gw < gapWidth; gw++) {
            var gSlot = (newGapStart + gw) % 8;
            segments[gSlot] = 1;
        }

        // Determine candidate hazard slots.
        // In early levels (Level 1 & 2), the slot directly beneath the previous
        // ring's gap is strictly protected (prevents blind drop deaths).
        var protectedSlots = {};
        if (level <= 2 && prevRing && prevRing.segments) {
            for (var chk = 0; chk < 8; chk++) {
                if (prevRing.segments[chk] === 1) {
                    protectedSlots[chk] = true;
                }
            }
        }

        // Also protect current gap segments
        for (var cur = 0; cur < gapWidth; cur++) {
            protectedSlots[(newGapStart + cur) % 8] = true;
        }

        // Place hazards strategically away from the gap center
        if (hazardCount > 0) {
            var hazardCandidates = [];
            var gapCenter = (newGapStart + Math.floor(gapWidth / 2)) % 8;

            for (var dist = 4; dist >= 1; dist--) {
                var s1 = (gapCenter + dist) % 8;
                var s2 = (gapCenter - dist + 8) % 8;
                if (!protectedSlots[s1] && segments[s1] === 0 && hazardCandidates.indexOf(s1) === -1) {
                    hazardCandidates.push(s1);
                }
                if (!protectedSlots[s2] && segments[s2] === 0 && hazardCandidates.indexOf(s2) === -1) {
                    hazardCandidates.push(s2);
                }
            }

            // Fallback: any remaining safe slot that is not protected
            if (hazardCandidates.length < hazardCount) {
                for (var f = 0; f < 8; f++) {
                    if (!protectedSlots[f] && segments[f] === 0 && hazardCandidates.indexOf(f) === -1) {
                        hazardCandidates.push(f);
                    }
                }
            }

            // In higher levels (Level 3+), also allow protected slots if needed
            if (level >= 3 && hazardCandidates.length < hazardCount) {
                for (var af = 0; af < 8; af++) {
                    if (segments[af] === 0 && hazardCandidates.indexOf(af) === -1) {
                        hazardCandidates.push(af);
                    }
                }
            }

            for (var hz = 0; hz < hazardCount && hz < hazardCandidates.length; hz++) {
                segments[hazardCandidates[hz]] = 2;
            }
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
