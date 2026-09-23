import QtQuick 2.9
import Lomiri.Components 1.3
import "../js/Themes.js" as Themes

Canvas {
    id: root
    anchors.fill: parent

    property var game: null

    Connections {
        target: game
        onCurrentThemeChanged: root.requestPaint()
    }

    onPaint: {
        if (!game) return;

        var ctx = getContext("2d");
        var w = width;
        var h = height;
        var centerX = w / 2.0;

        ctx.clearRect(0, 0, w, h);

        var theme = (game && game.currentTheme) ? game.currentTheme : Themes.getTheme(game ? game.currentLevel : 1);

        // Dynamic gradient background
        var bgGrad = ctx.createLinearGradient(0, 0, 0, h);
        bgGrad.addColorStop(0.0, theme.bgTop);
        bgGrad.addColorStop(1.0, theme.bgBottom);
        ctx.fillStyle = bgGrad;
        ctx.fillRect(0, 0, w, h);

        // Central column cylinder
        var poleGrad = ctx.createLinearGradient(
            centerX - game.poleRadius, 0,
            centerX + game.poleRadius, 0
        );
        poleGrad.addColorStop(0.0, theme.pole1);
        poleGrad.addColorStop(0.35, theme.pole2);
        poleGrad.addColorStop(1.0, theme.pole3);
        ctx.fillStyle = poleGrad;
        ctx.fillRect(
            centerX - game.poleRadius,
            0,
            game.poleRadius * 2,
            h
        );

        var rSpacing = game.ringSpacing;
        var bY = game.ballY;
        var camY = game.cameraY;
        var bScreenY = game.ballScreenY;
        var outR = game.outerRadius;
        var inR = game.innerRadius;
        var tilt = game.tiltRatio;
        var rHeight = game.ringHeight;
        var midR = (outR + inR) / 2.0;

        // Render platforms
        for (var r = 0; r < game.rings.length; r++) {
            var ring = game.rings[r];
            if (ring.broken) continue;

            var ringScreenY = bScreenY + (ring.y - camY) + (ring.recoil || 0);
            if (ringScreenY < -rSpacing || ringScreenY > h + rSpacing) {
                continue;
            }

            for (var seg = 0; seg < 8; seg++) {
                var segType = ring.segments[seg];
                if (segType === 1) continue;

                var isFragile = (segType === 3);
                var topColor = ring.isGoal ? (ring.isGrandGoal ? "#FFF275" : (theme.goalTop || "#E8C872")) : ((segType === 0 || isFragile) ? theme.topSafe : theme.topHazard);
                var sideColor = ring.isGoal ? (ring.isGrandGoal ? "#D4AF37" : (theme.goalSide || "#B09242")) : ((segType === 0 || isFragile) ? theme.sideSafe : theme.sideHazard);

                var ringOffset = ring.angleOffset || 0.0;
                var startAngle = game.towerAngle + ringOffset + seg * (Math.PI / 4.0);
                var endAngle = startAngle + (Math.PI / 4.0);

                // Extrude front 3D rim
                var samples = 6;
                var topPoints = [];
                var bottomPoints = [];

                for (var s = 0; s <= samples; s++) {
                    var a = startAngle + (endAngle - startAngle) * (s / samples);
                    var sinA = Math.sin(a);
                    var cosA = Math.cos(a);

                    if (sinA > -0.05) {
                        var px = centerX + outR * cosA;
                        var py = ringScreenY + outR * sinA * tilt;
                        topPoints.push({ x: px, y: py });
                        bottomPoints.push({ x: px, y: py + rHeight });
                    }
                }

                if (topPoints.length > 1) {
                    ctx.beginPath();
                    ctx.moveTo(topPoints[0].x, topPoints[0].y);
                    for (var p = 1; p < topPoints.length; p++) {
                        ctx.lineTo(topPoints[p].x, topPoints[p].y);
                    }
                    for (var bp = bottomPoints.length - 1; bp >= 0; bp--) {
                        ctx.lineTo(bottomPoints[bp].x, bottomPoints[bp].y);
                    }
                    ctx.closePath();
                    ctx.fillStyle = sideColor;
                    ctx.fill();
                }

                // Render platform face
                ctx.save();
                ctx.translate(centerX, ringScreenY);
                ctx.scale(1.0, tilt);

                ctx.beginPath();
                ctx.arc(0, 0, outR, startAngle, endAngle, false);
                ctx.arc(0, 0, inR, endAngle, startAngle, true);
                ctx.closePath();

                ctx.fillStyle = topColor;
                ctx.fill();

                ctx.lineWidth = 1.2;
                ctx.strokeStyle = "rgba(10, 15, 20, 0.45)";
                ctx.stroke();

                ctx.restore();
            }

            // Render platform shockwave ripples
            if (ring.shockwaves && ring.shockwaves.length > 0) {
                for (var sw = 0; sw < ring.shockwaves.length; sw++) {
                    var wave = ring.shockwaves[sw];
                    var waveAngle = game.towerAngle + wave.angle;
                    var wx = centerX + midR * Math.cos(waveAngle);
                    var wy = ringScreenY + midR * Math.sin(waveAngle) * tilt;

                    ctx.save();
                    ctx.translate(wx, wy);
                    ctx.scale(1.0, tilt);

                    ctx.beginPath();
                    ctx.arc(0, 0, wave.radius, 0, Math.PI * 2.0);
                    ctx.lineWidth = Math.max(1.0, 3.2 * (wave.alpha / wave.maxAlpha));
                    ctx.strokeStyle = "rgba(255, 255, 255, " + wave.alpha.toFixed(2) + ")";
                    ctx.stroke();

                    ctx.beginPath();
                    ctx.arc(0, 0, wave.radius * 0.62, 0, Math.PI * 2.0);
                    ctx.lineWidth = 1.6;
                    ctx.strokeStyle = "rgba(255, 255, 255, " + (wave.alpha * 0.45).toFixed(2) + ")";
                    ctx.stroke();

                    ctx.restore();
                }
            }

            // Render platform paint splats
            if (ring.splats && ring.splats.length > 0) {
                for (var sp = 0; sp < ring.splats.length; sp++) {
                    var splat = ring.splats[sp];
                    var splatAngle = game.towerAngle + splat.angle;
                    var sx = centerX + midR * Math.cos(splatAngle);
                    var sy = ringScreenY + midR * Math.sin(splatAngle) * tilt;

                    ctx.save();
                    ctx.translate(sx, sy);
                    ctx.scale(1.0, tilt);

                    ctx.beginPath();
                    ctx.arc(0, 0, splat.radius, 0, Math.PI * 2.0);
                    ctx.fillStyle = theme.ballMid;
                    ctx.globalAlpha = 0.75;
                    ctx.fill();

                    ctx.beginPath();
                    ctx.arc(-splat.radius * 0.28, -splat.radius * 0.28, splat.radius * 0.32, 0, Math.PI * 2.0);
                    ctx.fillStyle = "rgba(255, 255, 255, 0.45)";
                    ctx.fill();

                    if (splat.droplets && splat.droplets.length > 0) {
                        var dropScale = splat.dropletScale || 1.0;
                        ctx.fillStyle = theme.ballMid;
                        ctx.globalAlpha = 0.65;
                        for (var dp = 0; dp < splat.droplets.length; dp++) {
                            var drop = splat.droplets[dp];
                            ctx.beginPath();
                            ctx.arc(drop.dx * dropScale, drop.dy * dropScale, drop.radius * dropScale, 0, Math.PI * 2.0);
                            ctx.fill();
                        }
                    }

                    ctx.restore();
                }
            }
        }

        // Dynamic squash-and-stretch computation combining impact compression and flight elongation
        var renderSquash = game.squash;
        if (game.squash >= 1.0) {
            var flightStretch = 1.0;
            if (game.ballVy < 0) {
                flightStretch += 0.22 * Math.min(1.0, Math.abs(game.ballVy) / game.bounceSpeed);
            } else {
                var stretchFactor = game.isSuperFall ? 0.34 : 0.18;
                flightStretch += stretchFactor * Math.min(1.0, game.ballVy / game.maxFallSpeed);
            }
            renderSquash = game.squash * flightStretch;
        }

        // Platform drop shadow
        for (var sr = 0; sr < game.rings.length; sr++) {
            var targetRing = game.rings[sr];
            if (targetRing.broken) continue;
            if (targetRing.y >= bY) {
                var dist = targetRing.y - bY;
                if (dist < rSpacing * 1.6) {
                    var shadowY = bScreenY + (targetRing.y - camY) + (targetRing.recoil || 0) + midR * tilt;
                    var distFraction = Math.min(1.0, dist / (rSpacing * 1.6));
                    var proximity = 1.0 - distFraction;
                    var alpha = Math.max(0.08, 0.60 * Math.pow(proximity, 1.8));
                    var shadowScale = Math.max(0.35, 1.0 - distFraction * 0.55);
                    var shadowSx = (1.0 / Math.sqrt(renderSquash)) * shadowScale;
                    var shadowSy = shadowScale;

                    ctx.save();
                    ctx.translate(centerX, shadowY);
                    ctx.scale(shadowSx, shadowSy * tilt);
                    ctx.beginPath();
                    ctx.arc(0, 0, game.ballRadius, 0, Math.PI * 2.0);
                    ctx.fillStyle = "rgba(0, 0, 0, " + alpha.toFixed(2) + ")";
                    ctx.fill();
                    ctx.restore();
                }
                break;
            }
        }

        // Motion trail behind the ball
        var bRadius = game.ballRadius;
        for (var tr = 0; tr < game.ballTrail.length; tr++) {
            var trItem = game.ballTrail[tr];
            if (trItem.alpha <= 0) continue;
            var trailScreenY = bScreenY + (trItem.y - camY) + midR * tilt - bRadius;
            var trailRadius = bRadius * (0.4 + 0.5 * (tr / game.ballTrail.length));

            ctx.save();
            ctx.translate(centerX, trailScreenY);
            ctx.beginPath();
            ctx.arc(0, 0, trailRadius, 0, Math.PI * 2.0);
            ctx.fillStyle = trItem.isSuper ? "#ff793f" : theme.ballMid;
            ctx.globalAlpha = trItem.alpha * 0.5;
            ctx.fill();
            ctx.restore();
        }

        var contactScreenY = bScreenY + (game.ballY - camY) + midR * tilt;
        var actualBallScreenY = contactScreenY - bRadius * renderSquash;

        // Super fall flame aura
        if (game.isSuperFall) {
            ctx.save();
            ctx.translate(centerX, actualBallScreenY);
            ctx.beginPath();
            ctx.arc(0, 0, bRadius * 1.8, 0, Math.PI * 2.0);
            var flameGrad = ctx.createRadialGradient(0, 0, bRadius * 0.5, 0, 0, bRadius * 1.8);
            flameGrad.addColorStop(0.0, "rgba(255, 218, 121, 0.9)");
            flameGrad.addColorStop(0.5, "rgba(255, 121, 63, 0.6)");
            flameGrad.addColorStop(1.0, "rgba(255, 56, 56, 0.0)");
            ctx.fillStyle = flameGrad;
            ctx.fill();
            ctx.restore();
        }

        // Ball rendering with squash-and-stretch
        ctx.save();
        ctx.translate(centerX, actualBallScreenY);
        ctx.scale(1.0 / Math.sqrt(renderSquash), renderSquash);

        var ballGrad = ctx.createRadialGradient(
            -bRadius * 0.32,
            -bRadius * 0.35,
            bRadius * 0.1,
            0,
            0,
            bRadius
        );
        ballGrad.addColorStop(0.0, theme.ballLight);
        ballGrad.addColorStop(0.35, theme.ballMid);
        ballGrad.addColorStop(1.0, theme.ballDark);

        ctx.beginPath();
        ctx.arc(0, 0, bRadius, 0, Math.PI * 2.0);
        ctx.fillStyle = ballGrad;
        ctx.fill();

        // High-gloss specular highlight
        ctx.beginPath();
        ctx.arc(-bRadius * 0.32, -bRadius * 0.35, bRadius * 0.26, 0, Math.PI * 2.0);
        ctx.fillStyle = "rgba(255, 255, 255, 0.55)";
        ctx.fill();

        ctx.restore();

        // Render active 3D particles
        for (var ptIdx = 0; ptIdx < game.particles.length; ptIdx++) {
            var particle = game.particles[ptIdx];
            var partScreenY = bScreenY + (particle.y - camY) + particle.z * tilt;
            var partScreenX = centerX + particle.x;

            ctx.save();
            ctx.translate(partScreenX, partScreenY);
            ctx.beginPath();
            ctx.arc(0, 0, particle.size, 0, Math.PI * 2.0);
            ctx.fillStyle = particle.color;
            ctx.globalAlpha = Math.max(0, particle.alpha);
            ctx.fill();
            ctx.restore();
        }
    }
}
