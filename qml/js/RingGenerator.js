.pragma library

var lastGapStart = 5;

function resetGenerator() {
    lastGapStart = 5;
}

function createRing(index, ringSpacing, prevRing, difficultyMode) {
    var mode = (difficultyMode !== undefined) ? difficultyMode : 1;
    var ringY = (index + 1) * ringSpacing;
    var segments = [0, 0, 0, 0, 0, 0, 0, 0];
    var levelRings = 20;
    var level = Math.floor(index / levelRings) + 1;
    var posInLevel = index % levelRings;
    var isGoal = (index > 0 && (index + 1) % levelRings === 0);
    var isGrandGoal = isGoal && (level >= 100);

    if (index === 0 || posInLevel === 0) {
        // Starting ring of run or checkpoint level: ensure slot 2 is safe ground.
        // Keep front landing zone (slots 1, 2, 3) solid and clear of hazards.
        segments[1] = 0;
        segments[2] = 0;
        segments[3] = 0;
        var initialGap;
        if (mode === 0) {
            initialGap = (level <= 5) ? 3 : 2;
        } else if (mode === 2) {
            initialGap = (level <= 2) ? 2 : 1;
        } else if (mode === 3) {
            initialGap = 1;
        } else {
            initialGap = (level <= 2) ? 3 : ((level <= 5) ? 2 : 1);
        }
        var gapStart = 5;
        for (var g = 0; g < initialGap; g++) {
            segments[(gapStart + g) % 8] = 1;
        }
        lastGapStart = gapStart;
    } else if (isGoal) {
        // Goal platform at the end of each level: all segments safe.
        for (var s = 0; s < 8; s++) {
            segments[s] = 0;
        }
        lastGapStart = (lastGapStart + 1) % 8;
    } else {
        // Progressive difficulty calculation across 10 distinct 10-level Zones
        var gapWidth = 2;
        var hazardCount = 0;
        var maxOffset = 1;

        if (level <= 10) {
            if (level <= 5) {
                gapWidth = (posInLevel <= 6 || Math.random() < 0.5) ? 3 : 2;
                hazardCount = (posInLevel <= 8) ? 0 : (Math.random() < 0.6 ? 0 : 1);
                maxOffset = 1;
            } else {
                gapWidth = (Math.random() < 0.4) ? 3 : 2;
                hazardCount = (Math.random() < 0.5) ? 1 : 0;
                maxOffset = 1;
            }
        } else if (level <= 20) {
            gapWidth = 2;
            hazardCount = (Math.random() < 0.5) ? 1 : 2;
            maxOffset = 2;
        } else if (level <= 30) {
            gapWidth = (Math.random() < 0.5) ? 2 : 1;
            hazardCount = 2;
            maxOffset = 2;
        } else if (level <= 40) {
            gapWidth = (Math.random() < 0.2) ? 2 : 1;
            hazardCount = (Math.random() < 0.5) ? 2 : 3;
            maxOffset = 3;
        } else if (level <= 50) {
            gapWidth = 1;
            hazardCount = 3;
            maxOffset = 3;
        } else if (level <= 60) {
            gapWidth = 1;
            hazardCount = (Math.random() < 0.6) ? 3 : 4;
            maxOffset = 3;
        } else if (level <= 70) {
            gapWidth = 1;
            hazardCount = (Math.random() < 0.5) ? 3 : 4;
            maxOffset = 4;
        } else if (level <= 80) {
            gapWidth = 1;
            hazardCount = 4;
            maxOffset = 4;
        } else if (level <= 90) {
            gapWidth = 1;
            hazardCount = (Math.random() < 0.5) ? 4 : 5;
            maxOffset = 4;
        } else {
            gapWidth = 1;
            hazardCount = (Math.random() < 0.4) ? 4 : 5;
            maxOffset = 4;
        }

        if (mode === 0) {
            gapWidth = Math.min(3, gapWidth + 1);
            if (level <= 20) gapWidth = Math.max(2, gapWidth);
            hazardCount = Math.max(0, hazardCount - 1);
            if (hazardCount > 3) hazardCount = 3;
        } else if (mode === 2) {
            if (level >= 15) gapWidth = 1;
            hazardCount = Math.min(5, hazardCount + 1);
            maxOffset = Math.min(4, maxOffset + 1);
        } else if (mode === 3) {
            gapWidth = (level <= 3) ? 2 : 1;
            hazardCount = (level <= 3) ? 1 : ((level <= 10) ? 2 : Math.min(5, Math.max(3, hazardCount + 1)));
            maxOffset = Math.min(4, maxOffset + 1);
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

        // Zone 3+ Dual-Opening mechanic: occasional second opening on opposite side
        if (level >= 21 && !isGoal && Math.random() < 0.25) {
            var oppSlot = (newGapStart + 4) % 8;
            segments[oppSlot] = 1;
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

            if (level >= 61 && level <= 70) {
                // Zone 7: Flank the gap directly
                for (var fDist = 1; fDist <= 4; fDist++) {
                    var fs1 = (gapCenter + fDist) % 8;
                    var fs2 = (gapCenter - fDist + 8) % 8;
                    if (!protectedSlots[fs1] && segments[fs1] === 0 && hazardCandidates.indexOf(fs1) === -1) {
                        hazardCandidates.push(fs1);
                    }
                    if (!protectedSlots[fs2] && segments[fs2] === 0 && hazardCandidates.indexOf(fs2) === -1) {
                        hazardCandidates.push(fs2);
                    }
                }
            } else {
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

        // Fragile Safe segments (type 3): break upon first bounce
        var fragileThreshold = (mode === 0) ? 999 : ((mode === 2) ? 30 : ((mode === 3) ? 15 : 41));
        if (level >= fragileThreshold && !isGoal && Math.random() < (mode === 3 ? 0.40 : 0.30)) {
            for (var fs = 0; fs < 8; fs++) {
                if (segments[fs] === 0) {
                    segments[fs] = 3;
                    break;
                }
            }
        }

        // Rotating rings mechanic
        var rotationSpeed = 0.0;
        var rotThreshold = (mode === 0) ? 50 : ((mode === 2) ? 20 : ((mode === 3) ? 10 : 31));
        var rotChance = (mode === 0) ? 0.15 : ((mode === 2) ? 0.30 : ((mode === 3) ? 0.40 : 0.22));
        var rotSpeedMult = (mode === 0) ? 0.6 : ((mode === 2) ? 1.25 : ((mode === 3) ? 1.4 : 1.0));
        if (level >= rotThreshold && !isGoal && posInLevel > 1 && Math.random() < rotChance) {
            rotationSpeed = (Math.random() < 0.5 ? 1 : -1) * (0.45 + Math.random() * 0.4) * rotSpeedMult;
        }

        // Moving / Oscillating gap mechanic
        var isOscillating = false;
        var oscSpeed = 0.0;
        var oscAmplitude = 0.0;
        var oscThreshold = (mode === 0) ? 999 : ((mode === 2) ? 40 : ((mode === 3) ? 25 : 61));
        var oscChance = (mode === 0) ? 0.0 : ((mode === 2) ? 0.30 : ((mode === 3) ? 0.35 : 0.25));
        if (level >= oscThreshold && !isGoal && rotationSpeed === 0 && Math.random() < oscChance) {
            isOscillating = true;
            oscSpeed = (1.4 + Math.random() * 0.8) * (mode === 3 ? 1.3 : 1.0);
            oscAmplitude = (mode === 3 ? 0.45 : 0.35);
        }
    }

    return {
        index: index,
        y: ringY,
        segments: segments,
        passed: false,
        broken: false,
        isGoal: isGoal,
        isGrandGoal: isGrandGoal,
        goalAwarded: false,
        rotationSpeed: rotationSpeed || 0.0,
        angleOffset: 0.0,
        isOscillating: isOscillating || false,
        oscSpeed: oscSpeed || 0.0,
        oscAmplitude: oscAmplitude || 0.0,
        oscTime: 0.0,
        recoil: 0.0,
        recoilVelocity: 0.0,
        shockwaves: [],
        splats: []
    };
}
