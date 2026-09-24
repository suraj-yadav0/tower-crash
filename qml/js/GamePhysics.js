.pragma library

function getSegmentIndex(towerAngle, ringOffset) {
    var effectiveAngle = towerAngle + (ringOffset || 0.0);
    var relAngle = ((Math.PI / 2.0 - effectiveAngle) % (2.0 * Math.PI));
    if (relAngle < 0) {
        relAngle += 2.0 * Math.PI;
    }
    var idx = Math.floor(relAngle / (Math.PI / 4.0));
    if (idx < 0) idx = 0;
    if (idx > 7) idx = 7;
    return { index: idx, relAngle: relAngle };
}

function updateCamera(cameraY, ballY, activePlatformY, isSuperFall, dt, maxLag) {
    var targetCamera = (ballY > activePlatformY) ? ballY : activePlatformY;
    if (targetCamera > cameraY) {
        var camDiff = targetCamera - cameraY;
        if (camDiff < 0.001) {
            return targetCamera;
        }
        var followRate = isSuperFall ? 28.0 : 20.0;
        var camStep = camDiff * (1.0 - Math.exp(-followRate * dt));
        var newCam = cameraY + camStep;
        if (ballY - newCam > maxLag) {
            newCam = ballY - maxLag;
        }
        return newCam;
    }
    return cameraY;
}

function updateSquash(squash, squashVelocity, dt) {
    var springK = 360.0;
    var damping = 22.0;
    var force = -springK * (squash - 1.0) - damping * squashVelocity;
    var nextVel = squashVelocity + force * dt;
    var nextSquash = squash + nextVel * dt;
    if (Math.abs(nextSquash - 1.0) < 0.002 && Math.abs(nextVel) < 0.005) {
        return { squash: 1.0, velocity: 0.0 };
    }
    return { squash: nextSquash, velocity: nextVel };
}

function updateRings(rings, dt) {
    for (var rIdx = 0; rIdx < rings.length; rIdx++) {
        var rObj = rings[rIdx];
        if (rObj.broken) continue;

        if (rObj.rotationSpeed && rObj.rotationSpeed !== 0) {
            rObj.angleOffset += rObj.rotationSpeed * dt;
        } else if (rObj.isOscillating) {
            rObj.oscTime += dt * rObj.oscSpeed;
            rObj.angleOffset = Math.sin(rObj.oscTime) * rObj.oscAmplitude;
        }

        if (rObj.recoil !== 0 || rObj.recoilVelocity !== 0) {
            var rSpringK = 520.0;
            var rDamping = 28.0;
            var rForce = -rSpringK * rObj.recoil - rDamping * rObj.recoilVelocity;
            rObj.recoilVelocity += rForce * dt;
            rObj.recoil += rObj.recoilVelocity * dt;
            if (Math.abs(rObj.recoil) < 0.0005 && Math.abs(rObj.recoilVelocity) < 0.001) {
                rObj.recoil = 0.0;
                rObj.recoilVelocity = 0.0;
            }
        }

        if (rObj.shockwaves && rObj.shockwaves.length > 0) {
            for (var sw = rObj.shockwaves.length - 1; sw >= 0; sw--) {
                var wave = rObj.shockwaves[sw];
                wave.radius += wave.speed * dt;
                wave.alpha = Math.max(0.0, wave.maxAlpha * (1.0 - wave.radius / wave.maxRadius));
                if (wave.alpha <= 0.01 || wave.radius >= wave.maxRadius) {
                    rObj.shockwaves.splice(sw, 1);
                }
            }
        }

        if (rObj.splats && rObj.splats.length > 0) {
            for (var sp = 0; sp < rObj.splats.length; sp++) {
                var splat = rObj.splats[sp];
                if (splat.radius < splat.targetRadius) {
                    splat.radius = Math.min(splat.targetRadius, splat.radius + splat.growthSpeed * dt);
                }
                if (splat.dropletScale < 1.0) {
                    splat.dropletScale = Math.min(1.0, splat.dropletScale + dt * 14.0);
                }
            }
        }
    }
}

function checkBallCollision(game, prevY, nextY, speedScale, soundManager, stageClearTimer, units, Storage, Progression, i18n) {
    for (var i = 0; i < game.rings.length; i++) {
        var ring = game.rings[i];
        if (ring.broken) continue;

        if (prevY <= ring.y && nextY >= ring.y) {
            var hit = getSegmentIndex(game.towerAngle, ring.angleOffset);
            var segmentIdx = hit.index;
            var relAngle = hit.relAngle;
            var segType = ring.segments[segmentIdx];

            if (ring.isGoal) {
                ring.broken = true;
                var goalLevel = Math.floor(ring.index / game.levelRings) + 1;
                var isGrand = ring.isGrandGoal || (goalLevel >= 100);
                var nextLvl = goalLevel + 1;
                var isZone = Progression.isZoneTransition(nextLvl);
                var isCp = Progression.isCheckpointLevel(nextLvl);

                game.bannerIsCheckpoint = isCp;
                game.bannerIsZone = isZone;

                if (isGrand) {
                    game.spawnShatterDebris(ring.y, true, true, game.currentTheme, false);
                    game.score += 1000;
                    game.bannerText = i18n.tr("TOWER CONQUERED! 100 LEVELS COMPLETE!");
                    Storage.saveStat("gameCleared", "1");
                    soundManager.milestoneHaptic();
                } else if (isZone) {
                    game.spawnShatterDebris(ring.y, true, false, game.currentTheme, false);
                    game.score += 250;
                    game.bannerText = i18n.tr("ZONE %1 ENTERED!").arg(Math.floor((nextLvl - 1) / 10) + 1);
                    soundManager.milestoneHaptic();
                } else if (isCp) {
                    game.spawnShatterDebris(ring.y, true, false, game.currentTheme, false);
                    game.score += 150;
                    game.bannerText = i18n.tr("CHECKPOINT STAGE %1!").arg(nextLvl);
                    soundManager.milestoneHaptic();
                } else {
                    game.spawnShatterDebris(ring.y, true, false, game.currentTheme, false);
                    game.score += 100;
                    game.bannerText = i18n.tr("LEVEL %1 COMPLETE!").arg(goalLevel);
                    soundManager.haptic(true);
                }
                game.bannerOpacity = 1.0;
                soundManager.playFanfare();

                var earned = isGrand ? 1000 : (isZone ? 250 : (isCp ? 150 : 100));
                var currentStreak = game.streak;
                game.streak = 0;
                game.isSuperFall = false;
                game.totalRings++;
                Storage.recordStageCompleted(earned);
                Storage.queueStat("totalRings", game.totalRings);
                Storage.queueStat("totalRingsSmashed", game.totalRings);

                game.ballY = ring.y;
                game.ballVy = -game.bounceSpeed * speedScale * 0.95;
                game.cameraY = ring.y;
                game.activePlatformY = ring.y;
                game.squash = 0.45;
                game.squashVelocity = (1.0 - game.squash) * 40.0;
                nextY = ring.y;

                if (nextLvl > game.highestLevelReached) {
                    game.highestLevelReached = nextLvl;
                    Storage.saveHighestLevel(nextLvl);
                }
                if (isCp) {
                    game.unlockCheckpoint(nextLvl);
                }

                if (game.score > game.bestScore) {
                    game.bestScore = game.score;
                    Storage.queueStat("bestScore", game.bestScore);
                }
                if (game.activePlayTimeAccumulator > 0.0) {
                    Storage.recordPlayTime(game.activePlayTimeAccumulator);
                    game.activePlayTimeAccumulator = 0.0;
                }
                Storage.flushPendingWrites();

                if (isCp || isGrand) {
                    game.stageClearStage = goalLevel;
                    game.stageClearBonus = earned;
                    game.stageClearStreak = currentStreak;
                    game.stageClearIsCheckpoint = isCp;
                    game.stageClearNextCheckpoint = nextLvl;
                    game.stageClearIsGrand = isGrand;
                    game.milestoneRingY = ring.y;
                    game.isStageClearCelebrating = true;
                    game.isStageClearOpen = false;
                    if (stageClearTimer) {
                        stageClearTimer.restart();
                    }
                }
                break;
            }

            if (game.isSuperFall && segType !== 1) {
                ring.broken = true;
                game.spawnShatterDebris(ring.y, false, false, game.currentTheme, true);
                soundManager.playBounce(1.0);
                soundManager.haptic(true);

                game.score += 25;
                game.streak = 0;
                game.isSuperFall = false;
                game.totalRings++;
                Storage.queueStat("totalRings", game.totalRings);
                Storage.queueStat("totalRingsSmashed", game.totalRings);

                game.ballY = ring.y;
                game.ballVy = -game.bounceSpeed * speedScale;
                game.activePlatformY = ring.y;
                game.squash = 0.48;
                game.squashVelocity = (1.0 - game.squash) * 38.0;
                nextY = ring.y;

                if (game.score > game.bestScore) {
                    game.bestScore = game.score;
                    Storage.queueStat("bestScore", game.bestScore);
                }
                break;
            }

            if (segType === 0 || segType === 3) {
                var impactSpeed = Math.abs(game.ballVy);
                var normSpeed = (game.maxFallSpeed > 0) ? Math.min(1.0, impactSpeed / game.maxFallSpeed) : 0.6;
                game.ballY = ring.y;
                game.ballVy = -game.bounceSpeed * speedScale;
                game.activePlatformY = ring.y;
                game.streak = 0;
                game.isSuperFall = false;
                game.squash = 0.54;
                game.squashVelocity = (1.0 - game.squash) * 36.0;
                nextY = ring.y;

                if (segType === 3) {
                    ring.segments[segmentIdx] = 1;
                    game.spawnSegmentShatter(ring.y, relAngle, game.currentTheme.topSafe, game.currentTheme.sideSafe);
                }
                soundManager.playBounce(normSpeed);
                soundManager.haptic(false);

                ring.recoil = units.gu(0.55);
                ring.recoilVelocity = units.gu(5.0);

                if (!ring.shockwaves) ring.shockwaves = [];
                ring.shockwaves.push({
                    angle: relAngle,
                    radius: units.gu(0.6),
                    maxRadius: units.gu(6.0),
                    speed: units.gu(30.0),
                    alpha: 0.85,
                    maxAlpha: 0.85
                });

                if (!ring.splats) ring.splats = [];
                if (ring.splats.length >= 2) ring.splats.shift();
                var droplets = [];
                var dropCount = 2;
                for (var d = 0; d < dropCount; d++) {
                    var dAngle = Math.random() * Math.PI * 2.0;
                    var dDist = units.gu(2.4 + Math.random() * 2.0);
                    droplets.push({
                        dx: Math.cos(dAngle) * dDist,
                        dy: Math.sin(dAngle) * dDist,
                        radius: units.gu(0.3 + Math.random() * 0.4)
                    });
                }
                ring.splats.push({
                    angle: relAngle,
                    radius: units.gu(0.5),
                    targetRadius: units.gu(2.2 + Math.random() * 0.9),
                    growthSpeed: units.gu(24.0),
                    droplets: droplets,
                    dropletScale: 0.1
                });

                var theme = game.currentTheme;
                game.spawnBounceDust(ring.y, theme.ballMid, theme.ballLight);
                break;
            } else if (segType === 2) {
                game.ballY = ring.y;
                game.ballVy = 0;
                game.gameOver = true;
                game.activePlatformY = ring.y;
                game.cameraY = ring.y;
                game.isSuperFall = false;
                soundManager.haptic(true);
                game.spawnParticles(0, ring.y, 12, game.currentTheme.topHazard, 1.4);

                if (game.score > game.bestScore) {
                    game.bestScore = game.score;
                    Storage.queueStat("bestScore", game.bestScore);
                }
                if (game.activePlayTimeAccumulator > 0.0) {
                    Storage.recordPlayTime(game.activePlayTimeAccumulator);
                    game.activePlayTimeAccumulator = 0.0;
                }
                Storage.flushPendingWrites();
                return { nextY: nextY, gameOver: true };
            } else if (segType === 1) {
                if (!ring.passed) {
                    ring.passed = true;
                    if (game.activePlatformY < ring.y) {
                        game.activePlatformY = ring.y;
                    }
                    game.streak++;
                    game.score += game.streak;
                    game.totalRings++;

                    if (game.streak >= 3) {
                        soundManager.haptic(true);
                        if (game.ballVy > game.gravity * 0.35) {
                            game.isSuperFall = true;
                        }
                    }

                    if (game.score > game.bestScore) {
                        game.bestScore = game.score;
                        Storage.queueStat("bestScore", game.bestScore);
                    }
                    Storage.queueStat("totalRings", game.totalRings);
                    Storage.queueStat("totalRingsSmashed", game.totalRings);
                    Storage.recordComboStreak(game.streak);
                }
            }
        }
    }
    return { nextY: nextY, gameOver: false };
}

function updatePhysicsStep(game, dt, soundManager, stageClearTimer, units, Storage, Progression, i18n, Particles) {
    var prevY = game.ballY;

    game.activePlayTimeAccumulator += dt;
    if (game.activePlayTimeAccumulator >= 5.0) {
        Storage.recordPlayTime(game.activePlayTimeAccumulator);
        game.activePlayTimeAccumulator = 0.0;
    }

    if (!game.isDragging && Math.abs(game.angularVelocity) > 0.0001) {
        game.towerAngle += game.angularVelocity;
        game.angularVelocity *= Math.pow(0.04, dt);
    }

    var currentDepth = Math.floor(game.ballY / game.ringSpacing);
    var speedScale = 1.0 + Math.min(0.35, currentDepth * 0.005);
    var effectiveGravity = game.gravity * speedScale;

    game.ballVy += effectiveGravity * dt;
    if (game.ballVy > game.maxFallSpeed) {
        game.ballVy = game.maxFallSpeed;
    }

    game.isSuperFall = (game.streak >= 3 && game.ballVy > game.gravity * 0.35);

    var nextY = game.ballY + game.ballVy * dt;
    if (game.isStageClearCelebrating && game.ballVy > 0 && nextY >= game.milestoneRingY) {
        nextY = game.milestoneRingY;
        game.ballVy = 0.0;
    }

    if (game.ballVy > 0) {
        game.ballTrail.push({
            y: game.ballY,
            isSuper: game.isSuperFall,
            alpha: 0.7
        });
        if (game.ballTrail.length > 5) {
            game.ballTrail.shift();
        }
    } else if (game.ballTrail.length > 0) {
        game.ballTrail.shift();
    }
    for (var t = 0; t < game.ballTrail.length; t++) {
        game.ballTrail[t].alpha -= dt * 3.5;
    }

    if (game.bannerOpacity > 0) {
        game.bannerOpacity = Math.max(0.0, game.bannerOpacity - dt * 0.6);
    }

    if (game.ballVy > 0 && !game.isStageClearCelebrating) {
        var collision = checkBallCollision(game, prevY, nextY, speedScale, soundManager, stageClearTimer, units, Storage, Progression, i18n);
        nextY = collision.nextY;
        if (collision.gameOver) {
            return false;
        }
    }

    game.ballY = nextY;
    game.cameraY = updateCamera(
        game.cameraY,
        game.ballY,
        game.activePlatformY,
        game.isSuperFall,
        dt,
        units.gu(8.5)
    );

    var sq = updateSquash(game.squash, game.squashVelocity, dt);
    game.squash = sq.squash;
    game.squashVelocity = sq.velocity;

    updateRings(game.rings, dt);
    Particles.updateParticles(game.particles, dt, game.gravity, game.poleRadius, units);

    var lastRing = game.rings[game.rings.length - 1];
    while (lastRing && lastRing.y < game.cameraY + game.ringSpacing * 8) {
        game.generateRing();
        lastRing = game.rings[game.rings.length - 1];
    }

    while (game.rings.length > 0 &&
           game.rings[0].y < game.cameraY - game.ringSpacing * 3) {
        game.rings.shift();
    }

    return true;
}
