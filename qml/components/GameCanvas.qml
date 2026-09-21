import QtQuick 2.9
import Lomiri.Components 1.3
import "../js/Themes.js" as Themes

Canvas {
    id: root
    anchors.fill: parent

    property var game: null

    onPaint: {
        if (!game) return;

        var ctx = getContext("2d");
        var w = width;
        var h = height;
        var centerX = w / 2.0;

        ctx.clearRect(0, 0, w, h);

        var theme = Themes.getTheme(game.currentLevel);

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

        // Render platforms
        for (var r = 0; r < game.rings.length; r++) {
            var ring = game.rings[r];
            if (ring.broken) continue;

            var ringScreenY = bScreenY + (ring.y - camY);
            if (ringScreenY < -rSpacing || ringScreenY > h + rSpacing) {
                continue;
            }

            for (var seg = 0; seg < 8; seg++) {
                var segType = ring.segments[seg];
                if (segType === 1) continue;

                var topColor = ring.isGoal ? "#ffd700" : ((segType === 0) ? theme.topSafe : theme.topHazard);
                var sideColor = ring.isGoal ? "#cca300" : ((segType === 0) ? theme.sideSafe : theme.sideHazard);

                var startAngle = game.towerAngle + seg * (Math.PI / 4.0);
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

            // Render platform paint splats
            if (ring.splats.length > 0) {
                for (var sp = 0; sp < ring.splats.length; sp++) {
                    var splat = ring.splats[sp];
                    var splatAngle = game.towerAngle + splat.angle;
                    var midR = (outR + inR) / 2.0;
                    var sx = centerX + midR * Math.cos(splatAngle);
                    var sy = ringScreenY + midR * Math.sin(splatAngle) * tilt;

                    ctx.save();
                    ctx.translate(sx, sy);
                    ctx.scale(1.0, tilt);
                    ctx.beginPath();
                    ctx.arc(0, 0, splat.radius, 0, Math.PI * 2.0);
                    ctx.fillStyle = theme.ballMid;
                    ctx.globalAlpha = 0.7;
                    ctx.fill();
                    ctx.restore();
                }
            }
        }

        // Platform drop shadow
        for (var sr = 0; sr < game.rings.length; sr++) {
            var targetRing = game.rings[sr];
            if (targetRing.broken) continue;
            if (targetRing.y >= bY) {
                var dist = targetRing.y - bY;
                if (dist < rSpacing * 1.6) {
                    var shadowY = bScreenY + (targetRing.y - camY);
                    var alpha = Math.max(0.1, 0.5 * (1.0 - dist / (rSpacing * 1.6)));
                    var shadowScale = Math.max(0.4, 1.0 - (dist / (rSpacing * 1.6)) * 0.5);

                    ctx.save();
                    ctx.translate(centerX, shadowY);
                    ctx.scale(1.0, tilt);
                    ctx.beginPath();
                    ctx.arc(0, 0, game.ballRadius * shadowScale, 0, Math.PI * 2.0);
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
            var trailScreenY = bScreenY + (trItem.y - camY);
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

        var actualBallScreenY = bScreenY + (game.ballY - camY);

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
        ctx.scale(1.0 / Math.sqrt(game.squash), game.squash);

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
