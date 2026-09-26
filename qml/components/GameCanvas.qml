import QtQuick 2.9
import Lomiri.Components 1.3
import "../js/Themes.js" as Themes

Canvas {
    id: root
    anchors.fill: parent
    renderTarget: Canvas.FramebufferObject
    renderStrategy: Canvas.Threaded

    property var game: null

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    Connections {
        target: game
        function onCurrentThemeChanged() { root.requestPaint(); }
        function onThemeTransitionProgressChanged() { root.requestPaint(); }
    }

    onPaint: {
        if (!game) return;

        var ctx = getContext("2d");
        var w = width;
        var h = height;
        var centerX = w / 2.0;

        ctx.clearRect(0, 0, w, h);

        var theme = (game && game.currentTheme) ? game.currentTheme : Themes.getTheme(game ? game.currentLevel : 1);

        var pole1Clr = theme.pole1;
        var pole2Clr = theme.pole2;
        var pole3Clr = theme.pole3;

        if (game && game.previousTheme && game.themeTransitionProgress < 1.0) {
            var tProg = game.themeTransitionProgress;
            var prevT = game.previousTheme;
            pole1Clr = Themes.lerpColor(prevT.pole1, theme.pole1, tProg);
            pole2Clr = Themes.lerpColor(prevT.pole2, theme.pole2, tProg);
            pole3Clr = Themes.lerpColor(prevT.pole3, theme.pole3, tProg);
        }

        var rSpacing = game.ringSpacing;
        var bY = game.ballY;
        var camY = game.cameraY;
        var bScreenY = game.ballScreenY;
        var outR = game.outerRadius;
        var inR = game.innerRadius;
        var tilt = game.tiltRatio;
        var rHeight = game.ringHeight;
        var midR = (outR + inR) / 2.0;

        var sharedTopGrad = ctx.createRadialGradient(-outR * 0.35, -outR * 0.35, inR * 0.4, 0, 0, outR * 1.15);
        sharedTopGrad.addColorStop(0.0, "rgba(255, 255, 255, 0.18)");
        sharedTopGrad.addColorStop(0.55, "rgba(255, 255, 255, 0.02)");
        sharedTopGrad.addColorStop(1.0, "rgba(0, 0, 0, 0.18)");

        var sharedInnerAo = ctx.createRadialGradient(0, 0, inR, 0, 0, inR + units.gu(0.8));
        sharedInnerAo.addColorStop(0.0, "rgba(0, 0, 0, 0.10)");
        sharedInnerAo.addColorStop(1.0, "rgba(0, 0, 0, 0.0)");

        var botAoH = units.gu(0.9);
        var sharedBotAoGrad = ctx.createLinearGradient(0, 0, 0, botAoH);
        sharedBotAoGrad.addColorStop(0.0, "rgba(0, 0, 0, 0.14)");
        sharedBotAoGrad.addColorStop(1.0, "rgba(0, 0, 0, 0.0)");

        function drawParticle(pt) {
            var partScreenY = bScreenY + (pt.y - camY) + (pt.z || 0) * tilt;
            var partScreenX = centerX + pt.x;

            if (pt.kind === "shockwave") {
                ctx.save();
                ctx.translate(partScreenX, partScreenY);
                ctx.scale(1.0, tilt);
                ctx.beginPath();
                ctx.arc(0, 0, pt.radius, 0, Math.PI * 2.0);
                ctx.strokeStyle = pt.color;
                ctx.lineWidth = pt.thickness || units.gu(0.4);
                ctx.globalAlpha = Math.max(0, pt.alpha);
                ctx.stroke();
                ctx.restore();
            } else if (pt.kind === "dust") {
                ctx.save();
                ctx.translate(partScreenX, partScreenY);
                ctx.beginPath();
                ctx.arc(0, 0, pt.size, 0, Math.PI * 2.0);
                ctx.fillStyle = pt.color;
                ctx.globalAlpha = Math.max(0, pt.alpha * 0.45);
                ctx.fill();
                ctx.restore();
            } else if (pt.kind === "spark") {
                ctx.save();
                ctx.translate(partScreenX, partScreenY);
                ctx.beginPath();
                ctx.arc(0, 0, pt.size, 0, Math.PI * 2.0);
                ctx.fillStyle = pt.color;
                ctx.globalAlpha = Math.max(0, pt.alpha);
                ctx.fill();
                ctx.restore();
            } else if (pt.kind === "chunk" || pt.kind === "shard") {
                var cosPitch = Math.cos(pt.rotX || 0);
                var cosYaw = Math.cos(pt.rotY || 0);
                var facing = cosPitch * cosYaw;
                var pw = (pt.width || units.gu(1.8)) * Math.max(0.2, Math.abs(cosYaw));
                var ph = (pt.height || units.gu(1.4)) * Math.max(0.2, Math.abs(cosPitch));
                var pDepth = (pt.depth || units.gu(0.6));

                ctx.save();
                ctx.translate(partScreenX, partScreenY);
                ctx.rotate(pt.rotZ || 0);
                ctx.globalAlpha = Math.max(0, pt.alpha);

                ctx.fillStyle = pt.edgeColor || "#222428";
                ctx.beginPath();
                ctx.moveTo(-pw * 0.5, ph * 0.5);
                ctx.lineTo(pw * 0.5, ph * 0.5);
                ctx.lineTo(pw * 0.5, ph * 0.5 + pDepth * tilt);
                ctx.lineTo(-pw * 0.5, ph * 0.5 + pDepth * tilt);
                ctx.closePath();
                ctx.fill();

                ctx.fillStyle = facing >= 0 ? (pt.topColor || "#F5F3EF") : (pt.edgeColor || "#222428");
                ctx.beginPath();
                if (pt.kind === "chunk") {
                    ctx.moveTo(-pw * 0.5, -ph * 0.4);
                    ctx.quadraticCurveTo(0, -ph * 0.68, pw * 0.5, -ph * 0.5);
                    ctx.lineTo(pw * 0.45, ph * 0.5);
                    ctx.quadraticCurveTo(0, ph * 0.32, -pw * 0.4, ph * 0.45);
                } else {
                    ctx.moveTo(-pw * 0.5, -ph * 0.5);
                    ctx.lineTo(pw * 0.5, -ph * 0.2);
                    ctx.lineTo(0, ph * 0.5);
                }
                ctx.closePath();
                ctx.fill();

                if (pt.specular && facing > 0.25) {
                    ctx.fillStyle = "rgba(255, 255, 255, 0.55)";
                    ctx.beginPath();
                    ctx.moveTo(-pw * 0.2, -ph * 0.3);
                    ctx.lineTo(pw * 0.25, -ph * 0.1);
                    ctx.lineTo(0, ph * 0.1);
                    ctx.closePath();
                    ctx.fill();
                }

                ctx.restore();
            } else {
                ctx.save();
                ctx.translate(partScreenX, partScreenY);
                ctx.beginPath();
                ctx.arc(0, 0, pt.size || units.gu(0.4), 0, Math.PI * 2.0);
                ctx.fillStyle = pt.color;
                ctx.globalAlpha = Math.max(0, pt.alpha);
                ctx.fill();
                ctx.restore();
            }
        }

        if (game.particles && game.particles.length > 0) {
            for (var bp = 0; bp < game.particles.length; bp++) {
                var bPt = game.particles[bp];
                if ((bPt.z || 0) < 0) {
                    drawParticle(bPt);
                }
            }
        }

        function drawRadialCutWall(ringScreenY, angle, isStart, sideColor) {
            var cosA = Math.cos(angle);
            var sinA = Math.sin(angle);

            var xi = centerX + inR * cosA;
            var yit = ringScreenY + inR * sinA * tilt;
            var xo = centerX + outR * cosA;
            var yot = ringScreenY + outR * sinA * tilt;
            var yob = yot + rHeight;
            var yib = yit + rHeight;

            ctx.beginPath();
            ctx.moveTo(xi, yit);
            ctx.lineTo(xo, yot);
            ctx.lineTo(xo, yob);
            ctx.lineTo(xi, yib);
            ctx.closePath();

            ctx.fillStyle = sideColor;
            ctx.fill();

            var wallLight = isStart ? (0.75 - 0.35 * cosA + 0.25 * sinA) : (0.75 + 0.35 * cosA - 0.25 * sinA);
            wallLight = Math.max(0.40, Math.min(1.15, wallLight));
            if (wallLight < 0.85) {
                ctx.fillStyle = "rgba(0, 0, 0, " + (0.85 - wallLight).toFixed(2) + ")";
                ctx.fill();
            } else {
                ctx.fillStyle = "rgba(255, 255, 255, " + ((wallLight - 0.85) * 0.45).toFixed(2) + ")";
                ctx.fill();
            }

            ctx.strokeStyle = "rgba(0, 0, 0, 0.35)";
            ctx.lineWidth = units.gu(0.08);
            ctx.stroke();
        }

        function drawTopFace(ringScreenY, startAngle, endAngle, topColor, strokeStartRadial, strokeEndRadial) {
            ctx.save();
            ctx.translate(centerX, ringScreenY);
            ctx.scale(1.0, tilt);

            ctx.beginPath();
            ctx.arc(0, 0, outR, startAngle, endAngle, false);
            ctx.arc(0, 0, inR, endAngle, startAngle, true);
            ctx.closePath();

            ctx.fillStyle = topColor;
            ctx.fill();

            ctx.fillStyle = sharedTopGrad;
            ctx.fill();

            ctx.fillStyle = sharedInnerAo;
            ctx.fill();

            ctx.beginPath();
            ctx.arc(0, 0, outR, startAngle, endAngle, false);
            ctx.arc(0, 0, inR, endAngle, startAngle, true);
            if (strokeStartRadial !== false) {
                ctx.moveTo(inR * Math.cos(startAngle), inR * Math.sin(startAngle));
                ctx.lineTo(outR * Math.cos(startAngle), outR * Math.sin(startAngle));
            }
            if (strokeEndRadial !== false) {
                ctx.moveTo(inR * Math.cos(endAngle), inR * Math.sin(endAngle));
                ctx.lineTo(outR * Math.cos(endAngle), outR * Math.sin(endAngle));
            }
            ctx.strokeStyle = "rgba(10, 15, 20, 0.35)";
            ctx.lineWidth = units.gu(0.08);
            ctx.stroke();

            ctx.restore();
        }

        function drawSegmentTop(ringScreenY, a1, a2, topColor, wantFront) {
            var m = Math.floor(a1 / Math.PI) + 1;
            var root = m * Math.PI;
            if (root > a1 + 0.0001 && root < a2 - 0.0001) {
                var isFront1 = Math.sin((a1 + root) * 0.5) > 0;
                if (isFront1 === wantFront) {
                    drawTopFace(ringScreenY, a1, root, topColor, true, false);
                }
                var isFront2 = Math.sin((root + a2) * 0.5) > 0;
                if (isFront2 === wantFront) {
                    drawTopFace(ringScreenY, root, a2, topColor, false, true);
                }
            } else {
                var isFront = Math.sin((a1 + a2) * 0.5) > 0;
                if (isFront === wantFront) {
                    drawTopFace(ringScreenY, a1, a2, topColor, true, true);
                }
            }
        }

        function drawOuterRim(ringScreenY, startAngle, endAngle, sideColor) {
            var samples = 6;
            var startS = -1;
            var endS = -1;

            for (var s = 0; s <= samples; s++) {
                var a = startAngle + (endAngle - startAngle) * (s / samples);
                if (Math.sin(a) > -0.05) {
                    if (startS === -1) startS = s;
                    endS = s;
                }
            }

            if (startS === -1 || endS <= startS) return;

            ctx.beginPath();
            for (var sTop = startS; sTop <= endS; sTop++) {
                var aTop = startAngle + (endAngle - startAngle) * (sTop / samples);
                var pxTop = centerX + outR * Math.cos(aTop);
                var pyTop = ringScreenY + outR * Math.sin(aTop) * tilt;
                if (sTop === startS) ctx.moveTo(pxTop, pyTop);
                else ctx.lineTo(pxTop, pyTop);
            }
            for (var sBot = endS; sBot >= startS; sBot--) {
                var aBot = startAngle + (endAngle - startAngle) * (sBot / samples);
                var pxBot = centerX + outR * Math.cos(aBot);
                var pyBot = ringScreenY + outR * Math.sin(aBot) * tilt + rHeight;
                ctx.lineTo(pxBot, pyBot);
            }
            ctx.closePath();

            ctx.fillStyle = sideColor;
            ctx.fill();

            ctx.fillStyle = "rgba(0, 0, 0, 0.28)";
            ctx.fill();

            ctx.beginPath();
            for (var sStr = startS; sStr <= endS; sStr++) {
                var aStr = startAngle + (endAngle - startAngle) * (sStr / samples);
                var pxStr = centerX + outR * Math.cos(aStr);
                var pyStr = ringScreenY + outR * Math.sin(aStr) * tilt + rHeight;
                if (sStr === startS) ctx.moveTo(pxStr, pyStr);
                else ctx.lineTo(pxStr, pyStr);
            }
            ctx.strokeStyle = "rgba(0, 0, 0, 0.55)";
            ctx.lineWidth = units.gu(0.12);
            ctx.stroke();
        }

        function drawMotionIndicator(ringScreenY, midAngle, rotSpeed, isOsc) {
            ctx.save();
            ctx.translate(centerX, ringScreenY);
            ctx.scale(1.0, tilt);

            var mx = midR * Math.cos(midAngle);
            var my = midR * Math.sin(midAngle);
            var tangAngle = midAngle + Math.PI / 2.0;

            ctx.translate(mx, my);
            ctx.rotate(tangAngle);

            ctx.strokeStyle = "rgba(255, 255, 255, 0.50)";
            ctx.lineWidth = units.gu(0.20);
            ctx.lineCap = "round";
            ctx.lineJoin = "round";

            var size = units.gu(0.42);
            var wing = units.gu(0.36);

            if (isOsc) {
                ctx.beginPath();
                ctx.moveTo(-size + wing, -wing);
                ctx.lineTo(-size, 0);
                ctx.lineTo(-size + wing, wing);

                ctx.moveTo(size - wing, -wing);
                ctx.lineTo(size, 0);
                ctx.lineTo(size - wing, wing);
                ctx.stroke();
            } else {
                var dir = rotSpeed > 0 ? 1 : -1;
                ctx.beginPath();
                ctx.moveTo(-dir * wing, -wing);
                ctx.lineTo(dir * size, 0);
                ctx.lineTo(-dir * wing, wing);
                ctx.stroke();
            }

            ctx.restore();
        }

        for (var r1 = 0; r1 < game.rings.length; r1++) {
            var ring1 = game.rings[r1];
            if (ring1.broken) continue;

            var r1ScreenY = bScreenY + (ring1.y - camY) + (ring1.recoil || 0);
            if (r1ScreenY < -rSpacing || r1ScreenY > h + rSpacing) continue;

            var ring1Offset = ring1.angleOffset || 0.0;

            for (var seg1 = 0; seg1 < 8; seg1++) {
                var seg1Type = ring1.segments[seg1];
                if (seg1Type === 1) continue;

                var isFragile1 = (seg1Type === 3);
                var r1Level = Math.floor(ring1.index / (game ? game.levelRings : 20)) + 1;
                var r1Theme = (r1Level === (game ? game.currentLevel : 1)) ? theme : Themes.getTheme(game ? game.themeMode : 0, r1Level);
                var topColor1 = ring1.isGoal ? (ring1.isGrandGoal ? "#FFF275" : (r1Theme.goalTop || "#E8C872")) : ((seg1Type === 0 || isFragile1) ? r1Theme.topSafe : r1Theme.topHazard);
                var sideColor1 = ring1.isGoal ? (ring1.isGrandGoal ? "#D4AF37" : (r1Theme.goalSide || "#B09242")) : ((seg1Type === 0 || isFragile1) ? r1Theme.sideSafe : r1Theme.sideHazard);

                var startAngle1 = game.towerAngle + ring1Offset + seg1 * (Math.PI / 4.0);
                var endAngle1 = startAngle1 + (Math.PI / 4.0);

                drawSegmentTop(r1ScreenY, startAngle1, endAngle1, topColor1, false);

                var prevSeg1 = ring1.segments[(seg1 + 7) % 8];
                var nextSeg1 = ring1.segments[(seg1 + 1) % 8];

                if (prevSeg1 === 1 && Math.cos(startAngle1) < 0.02 && Math.sin(startAngle1) < 0) {
                    drawRadialCutWall(r1ScreenY, startAngle1, true, sideColor1);
                }
                if (nextSeg1 === 1 && Math.cos(endAngle1) > -0.02 && Math.sin(endAngle1) < 0) {
                    drawRadialCutWall(r1ScreenY, endAngle1, false, sideColor1);
                }
            }
        }

        var pLeft = centerX - game.poleRadius;
        var pRight = centerX + game.poleRadius;
        var pWidth = game.poleRadius * 2.0;

        var poleGrad = ctx.createLinearGradient(pLeft, 0, pRight, 0);
        poleGrad.addColorStop(0.00, pole1Clr);
        poleGrad.addColorStop(0.32, pole2Clr);
        poleGrad.addColorStop(0.72, pole2Clr);
        poleGrad.addColorStop(1.00, pole1Clr);

        ctx.fillStyle = poleGrad;
        ctx.fillRect(pLeft, 0, pWidth, h);

        // Subtle, smooth ambient shadow directly under each platform
        for (var aoR = 0; aoR < game.rings.length; aoR++) {
            var aoRing = game.rings[aoR];
            if (aoRing.broken) continue;
            var aoRingScreenY = bScreenY + (aoRing.y - camY) + (aoRing.recoil || 0);
            if (aoRingScreenY < -rSpacing || aoRingScreenY > h + rSpacing) continue;

            ctx.save();
            ctx.translate(pLeft, aoRingScreenY + rHeight);
            ctx.fillStyle = sharedBotAoGrad;
            ctx.fillRect(0, 0, pWidth, botAoH);
            ctx.restore();
        }

        for (var r2 = 0; r2 < game.rings.length; r2++) {
            var ring2 = game.rings[r2];
            if (ring2.broken) continue;

            var r2ScreenY = bScreenY + (ring2.y - camY) + (ring2.recoil || 0);
            if (r2ScreenY < -rSpacing || r2ScreenY > h + rSpacing) continue;

            var ring2Offset = ring2.angleOffset || 0.0;

            for (var seg2 = 0; seg2 < 8; seg2++) {
                var seg2Type = ring2.segments[seg2];
                if (seg2Type === 1) continue;

                var isFragile2 = (seg2Type === 3);
                var r2Level = Math.floor(ring2.index / (game ? game.levelRings : 20)) + 1;
                var r2Theme = (r2Level === (game ? game.currentLevel : 1)) ? theme : Themes.getTheme(game ? game.themeMode : 0, r2Level);
                var topColor2 = ring2.isGoal ? (ring2.isGrandGoal ? "#FFF275" : (r2Theme.goalTop || "#E8C872")) : ((seg2Type === 0 || isFragile2) ? r2Theme.topSafe : r2Theme.topHazard);
                var sideColor2 = ring2.isGoal ? (ring2.isGrandGoal ? "#D4AF37" : (r2Theme.goalSide || "#B09242")) : ((seg2Type === 0 || isFragile2) ? r2Theme.sideSafe : r2Theme.sideHazard);

                var startAngle2 = game.towerAngle + ring2Offset + seg2 * (Math.PI / 4.0);
                var endAngle2 = startAngle2 + (Math.PI / 4.0);

                var hasFront = (Math.sin(startAngle2) > -0.05 || Math.sin(endAngle2) > -0.05 || Math.sin((startAngle2 + endAngle2) * 0.5) > -0.05);

                if (hasFront) {
                    drawOuterRim(r2ScreenY, startAngle2, endAngle2, sideColor2);

                    var prevSeg2 = ring2.segments[(seg2 + 7) % 8];
                    var nextSeg2 = ring2.segments[(seg2 + 1) % 8];

                    if (prevSeg2 === 1 && Math.cos(startAngle2) < 0.02 && Math.sin(startAngle2) >= 0) {
                        drawRadialCutWall(r2ScreenY, startAngle2, true, sideColor2);
                    }
                    if (nextSeg2 === 1 && Math.cos(endAngle2) > -0.02 && Math.sin(endAngle2) >= 0) {
                        drawRadialCutWall(r2ScreenY, endAngle2, false, sideColor2);
                    }

                    drawSegmentTop(r2ScreenY, startAngle2, endAngle2, topColor2, true);

                    var midAngle2 = (startAngle2 + endAngle2) * 0.5;
                    if ((ring2.rotationSpeed !== 0 || ring2.isOscillating) && Math.sin(midAngle2) > 0.15) {
                        drawMotionIndicator(r2ScreenY, midAngle2, ring2.rotationSpeed, ring2.isOscillating);
                    }
                }
            }

            if (ring2.shockwaves && ring2.shockwaves.length > 0) {
                for (var sw = 0; sw < ring2.shockwaves.length; sw++) {
                    var wave = ring2.shockwaves[sw];
                    var waveAngle = game.towerAngle + ring2Offset + wave.angle;
                    var wx = centerX + midR * Math.cos(waveAngle);
                    var wy = r2ScreenY + midR * Math.sin(waveAngle) * tilt;

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

            if (ring2.splats && ring2.splats.length > 0) {
                for (var sp = 0; sp < ring2.splats.length; sp++) {
                    var splat = ring2.splats[sp];
                    var splatAngle = game.towerAngle + ring2Offset + splat.angle;
                    var sx = centerX + midR * Math.cos(splatAngle);
                    var sy = r2ScreenY + midR * Math.sin(splatAngle) * tilt;

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

        for (var sr = 0; sr < game.rings.length; sr++) {
            var targetRing = game.rings[sr];
            if (targetRing.broken) continue;
            if (targetRing.y >= bY) {
                var dist = targetRing.y - bY;
                if (dist < rSpacing * 1.6) {
                    var shadowY = bScreenY + (targetRing.y - camY) + (targetRing.recoil || 0) + midR * tilt;
                    var distFraction = Math.min(1.0, dist / (rSpacing * 1.6));
                    var proximity = 1.0 - distFraction;
                    var alpha = Math.max(0.06, 0.65 * Math.pow(proximity, 1.8));
                    var shadowScale = Math.max(0.40, 1.0 - distFraction * 0.50);
                    var shadowSx = (1.0 / Math.sqrt(renderSquash)) * shadowScale;
                    var shadowSy = shadowScale;

                    ctx.save();
                    ctx.translate(centerX, shadowY);
                    ctx.scale(shadowSx, shadowSy * tilt);

                    var sRadius = game.ballRadius * 1.4;
                    var sGrad = ctx.createRadialGradient(0, 0, 0, 0, 0, sRadius);
                    sGrad.addColorStop(0.0, "rgba(0, 0, 0, " + alpha.toFixed(2) + ")");
                    sGrad.addColorStop(0.5, "rgba(0, 0, 0, " + (alpha * 0.5).toFixed(2) + ")");
                    sGrad.addColorStop(1.0, "rgba(0, 0, 0, 0.0)");

                    ctx.beginPath();
                    ctx.arc(0, 0, sRadius, 0, Math.PI * 2.0);
                    ctx.fillStyle = sGrad;
                    ctx.fill();
                    ctx.restore();
                }
                break;
            }
        }

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

        ctx.save();
        ctx.translate(centerX, actualBallScreenY);
        ctx.scale(1.0 / Math.sqrt(renderSquash), renderSquash);

        var ballGrad = ctx.createRadialGradient(
            -bRadius * 0.35,
            -bRadius * 0.38,
            bRadius * 0.08,
            0,
            0,
            bRadius
        );
        ballGrad.addColorStop(0.0, "#FFFFFF");
        ballGrad.addColorStop(0.18, theme.ballLight);
        ballGrad.addColorStop(0.55, theme.ballMid);
        ballGrad.addColorStop(0.90, theme.ballDark);
        ballGrad.addColorStop(1.00, "rgba(0, 0, 0, 0.65)");

        ctx.beginPath();
        ctx.arc(0, 0, bRadius, 0, Math.PI * 2.0);
        ctx.fillStyle = ballGrad;
        ctx.fill();

        var fresnelGrad = ctx.createRadialGradient(
            bRadius * 0.25,
            bRadius * 0.35,
            0,
            bRadius * 0.25,
            bRadius * 0.35,
            bRadius * 0.65
        );
        fresnelGrad.addColorStop(0.0, "rgba(255, 255, 255, 0.25)");
        fresnelGrad.addColorStop(1.0, "rgba(255, 255, 255, 0.0)");
        ctx.beginPath();
        ctx.arc(0, 0, bRadius, 0, Math.PI * 2.0);
        ctx.fillStyle = fresnelGrad;
        ctx.fill();

        ctx.beginPath();
        ctx.arc(-bRadius * 0.35, -bRadius * 0.38, bRadius * 0.16, 0, Math.PI * 2.0);
        ctx.fillStyle = "rgba(255, 255, 255, 0.90)";
        ctx.fill();

        ctx.restore();

        if (game.particles && game.particles.length > 0) {
            for (var fp = 0; fp < game.particles.length; fp++) {
                var fPt = game.particles[fp];
                if ((fPt.z || 0) >= 0) {
                    drawParticle(fPt);
                }
            }
        }
    }
}
