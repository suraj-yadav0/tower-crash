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
