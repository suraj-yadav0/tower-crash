import QtQuick 2.9
import Lomiri.Components 1.3
import "../js/Themes.js" as Themes
import "../js/GamePhysics.js" as GamePhysics

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

        function hexToRgba(hex, alpha) {
            if (!hex || hex.charAt(0) !== "#" || hex.length < 7) {
                return "rgba(255, 255, 255, " + alpha + ")";
            }
            var r = parseInt(hex.slice(1, 3), 16) || 0;
            var g = parseInt(hex.slice(3, 5), 16) || 0;
            var b = parseInt(hex.slice(5, 7), 16) || 0;
            return "rgba(" + r + ", " + g + ", " + b + ", " + alpha + ")";
        }

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

        function drawHazardSpikes(ringScreenY, startAngle, topColor, sideColor, wantFront) {
            var layout = GamePhysics.HAZARD_SPIKE_LAYOUT;
            if (!layout || layout.length === 0) return;

            var segArc = Math.PI / 4.0;
            var rSpan = outR - inR;
            var visibleSpikes = [];

            for (var sp = 0; sp < layout.length; sp++) {
                var pat = layout[sp];
                var sTheta = startAngle + pat.v * segArc;
                var sSin = Math.sin(sTheta);
                var isFront = (sSin >= 0);
                if (isFront !== wantFront) continue;

                var sR = inR + pat.u * rSpan;
                var sX = centerX + sR * Math.cos(sTheta);
                var sY = ringScreenY + sR * sSin * tilt;

                visibleSpikes.push({
                    x: sX,
                    y: sY
                });
            }

            if (visibleSpikes.length === 0) return;

            visibleSpikes.sort(function(a, b) {
                return a.y - b.y;
            });

            var spikeHeight = units.gu(0.72);
            var baseRadius = units.gu(0.38);
            var baseRy = baseRadius * tilt;

            for (var vs = 0; vs < visibleSpikes.length; vs++) {
                var cur = visibleSpikes[vs];
                var bx = cur.x;
                var by = cur.y;

                var tipX = bx;
                var tipY = by - spikeHeight;
                var leftX = bx - baseRadius;
                var leftY = by;
                var rightX = bx + baseRadius;
                var rightY = by;
                var frontX = bx;
                var frontY = by + baseRy;

                ctx.save();
                ctx.translate(bx, by);
                ctx.scale(1.0, tilt);
                var aoGrad = ctx.createRadialGradient(0, 0, baseRadius * 0.25, 0, 0, baseRadius * 1.3);
                aoGrad.addColorStop(0.0, "rgba(0, 0, 0, 0.30)");
                aoGrad.addColorStop(0.65, "rgba(0, 0, 0, 0.10)");
                aoGrad.addColorStop(1.0, "rgba(0, 0, 0, 0.0)");
                ctx.fillStyle = aoGrad;
                ctx.beginPath();
                ctx.arc(0, 0, baseRadius * 1.3, 0, Math.PI * 2.0);
                ctx.fill();
                ctx.restore();

                ctx.save();
                ctx.translate(bx, by);
                ctx.scale(1.0, tilt);
                ctx.beginPath();
                ctx.arc(0, 0, baseRadius, 0, Math.PI * 2.0);
                ctx.fillStyle = "rgba(0, 0, 0, 0.20)";
                ctx.fill();
                ctx.strokeStyle = "rgba(0, 0, 0, 0.35)";
                ctx.lineWidth = units.gu(0.04) / tilt;
                ctx.stroke();
                ctx.restore();

                ctx.beginPath();
                ctx.moveTo(tipX, tipY);
                ctx.lineTo(leftX, leftY);
                ctx.quadraticCurveTo(leftX, frontY, frontX, frontY);
                ctx.lineTo(tipX, tipY);
                ctx.closePath();

                var leftGrad = ctx.createLinearGradient(leftX, tipY, frontX, frontY);
                leftGrad.addColorStop(0.0, "rgba(255, 255, 255, 0.88)");
                leftGrad.addColorStop(0.32, topColor);
                leftGrad.addColorStop(1.0, sideColor);
                ctx.fillStyle = leftGrad;
                ctx.fill();

                ctx.beginPath();
                ctx.moveTo(tipX, tipY);
                ctx.lineTo(frontX, frontY);
                ctx.quadraticCurveTo(rightX, frontY, rightX, rightY);
                ctx.lineTo(tipX, tipY);
                ctx.closePath();

                var rightGrad = ctx.createLinearGradient(frontX, tipY, rightX, rightY);
                rightGrad.addColorStop(0.0, topColor);
                rightGrad.addColorStop(0.40, sideColor);
                rightGrad.addColorStop(1.0, "rgba(20, 10, 10, 0.70)");
                ctx.fillStyle = rightGrad;
                ctx.fill();

                ctx.beginPath();
                ctx.moveTo(tipX, tipY);
                ctx.lineTo(frontX, frontY);
                ctx.strokeStyle = "rgba(255, 255, 255, 0.38)";
                ctx.lineWidth = units.gu(0.04);
                ctx.stroke();

                ctx.beginPath();
                ctx.moveTo(leftX, leftY);
                ctx.lineTo(tipX, tipY);
                ctx.lineTo(rightX, rightY);
                ctx.strokeStyle = "rgba(10, 15, 20, 0.28)";
                ctx.lineWidth = units.gu(0.035);
                ctx.stroke();

                ctx.beginPath();
                ctx.arc(tipX, tipY + units.gu(0.03), units.gu(0.06), 0, Math.PI * 2.0);
                ctx.fillStyle = "rgba(255, 255, 255, 0.88)";
                ctx.fill();
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

                if (seg1Type === 2 && !ring1.isGoal) {
                    drawHazardSpikes(r1ScreenY, startAngle1, topColor1, sideColor1, false);
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

                    if (seg2Type === 2 && !ring2.isGoal) {
                        drawHazardSpikes(r2ScreenY, startAngle2, topColor2, sideColor2, true);
                    }

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
        var velStretch = 1.0;
        if (game.ballVy < 0) {
            velStretch += 0.22 * Math.min(1.0, Math.abs(game.ballVy) / game.bounceSpeed);
        } else {
            var stretchFactor = game.isSuperFall ? 0.38 : 0.20;
            velStretch += stretchFactor * Math.min(1.0, game.ballVy / game.maxFallSpeed);
        }

        if (game.squash < 1.0) {
            renderSquash = game.squash;
        } else {
            renderSquash = 1.0 + (game.squash - 1.0) * 1.15 + (velStretch - 1.0);
        }

        for (var sr = 0; sr < game.rings.length; sr++) {
            var targetRing = game.rings[sr];
            if (targetRing.broken) continue;
            if (targetRing.y >= bY) {
                var hitInfo = GamePhysics.getSegmentIndex(game.towerAngle, targetRing.angleOffset);
                var segUnderBall = targetRing.segments[hitInfo.index];
                if (segUnderBall === 1 && !targetRing.isGoal) {
                    continue;
                }

                var dist = targetRing.y - bY;
                var maxShadowDist = rSpacing * 1.6;
                if (dist < maxShadowDist) {
                    var shadowY = bScreenY + (targetRing.y - camY) + (targetRing.recoil || 0) + midR * tilt;
                    var distFraction = Math.max(0.0, Math.min(1.0, dist / maxShadowDist));
                    var proximity = 1.0 - distFraction;

                    var squashHoriz = 1.0 / Math.sqrt(Math.max(0.2, renderSquash));

                    var penumbraAlpha = 0.42 * Math.pow(proximity, 1.4);
                    var penumbraRadius = game.ballRadius * (1.1 + 0.55 * distFraction);
                    var penumbraSx = squashHoriz * (0.85 + 0.25 * proximity);
                    var penumbraSy = 0.85 + 0.25 * proximity;

                    ctx.save();
                    ctx.translate(centerX, shadowY);
                    ctx.scale(penumbraSx, penumbraSy * tilt);

                    var penumbraGrad = ctx.createRadialGradient(0, 0, 0, 0, 0, penumbraRadius);
                    penumbraGrad.addColorStop(0.0, "rgba(0, 0, 0, " + penumbraAlpha.toFixed(3) + ")");
                    penumbraGrad.addColorStop(0.45, "rgba(0, 0, 0, " + (penumbraAlpha * 0.45).toFixed(3) + ")");
                    penumbraGrad.addColorStop(1.0, "rgba(0, 0, 0, 0.0)");

                    ctx.beginPath();
                    ctx.arc(0, 0, penumbraRadius, 0, Math.PI * 2.0);
                    ctx.fillStyle = penumbraGrad;
                    ctx.fill();
                    ctx.restore();

                    if (distFraction < 0.35) {
                        var contactProximity = 1.0 - (distFraction / 0.35);
                        var contactTightness = Math.pow(contactProximity, 1.6);
                        var contactAlpha = 0.88 * contactTightness;
                        var contactRadius = game.ballRadius * (0.65 + 0.25 * (1.0 - contactTightness));
                        var contactSx = squashHoriz;
                        var contactSy = 1.0;

                        ctx.save();
                        ctx.translate(centerX, shadowY);
                        ctx.scale(contactSx, contactSy * tilt);

                        var umbraGrad = ctx.createRadialGradient(0, 0, 0, 0, 0, contactRadius);
                        umbraGrad.addColorStop(0.0, "rgba(0, 0, 0, " + contactAlpha.toFixed(3) + ")");
                        umbraGrad.addColorStop(0.55, "rgba(0, 0, 0, " + (contactAlpha * 0.75).toFixed(3) + ")");
                        umbraGrad.addColorStop(0.85, "rgba(0, 0, 0, " + (contactAlpha * 0.30).toFixed(3) + ")");
                        umbraGrad.addColorStop(1.0, "rgba(0, 0, 0, 0.0)");

                        ctx.beginPath();
                        ctx.arc(0, 0, contactRadius, 0, Math.PI * 2.0);
                        ctx.fillStyle = umbraGrad;
                        ctx.fill();
                        ctx.restore();
                    }
                }
                break;
            }
        }

        var bRadius = game.ballRadius;
        var contactScreenY = bScreenY + (game.ballY - camY) + midR * tilt;
        var actualBallScreenY = contactScreenY - bRadius * renderSquash;
        var bRadiusX = bRadius / Math.sqrt(Math.max(0.2, renderSquash));

        var trailNodes = [];
        if (game.ballTrail && game.ballTrail.length > 0) {
            for (var tr = 0; tr < game.ballTrail.length; tr++) {
                var trItem = game.ballTrail[tr];
                if (!trItem || trItem.alpha <= 0.02) continue;
                var trScreenY = bScreenY + (trItem.y - camY) + midR * tilt - bRadius * renderSquash;
                if (trScreenY < actualBallScreenY - units.gu(0.25)) {
                    trailNodes.push({
                        y: trScreenY,
                        alpha: Math.max(0.0, Math.min(1.0, trItem.alpha)),
                        isSuper: trItem.isSuper
                    });
                }
            }
        }

        var normFall = (game.maxFallSpeed > 0) ? Math.min(1.0, Math.max(0.0, game.ballVy) / game.maxFallSpeed) : 0;
        if (trailNodes.length === 0 && normFall > 0.10) {
            var dynamicLength = bRadius * (1.4 + 2.6 * normFall);
            trailNodes.push({
                y: actualBallScreenY - dynamicLength,
                alpha: 0.65 * normFall,
                isSuper: game.isSuperFall
            });
        }

        if (trailNodes.length > 0) {
            trailNodes.sort(function(n1, n2) { return n1.y - n2.y; });
            var apexY = trailNodes[0].y;
            var trailHeight = actualBallScreenY - apexY;

            if (trailHeight > units.gu(0.35)) {
                var topW = bRadiusX * 0.12;
                var botW = bRadiusX * 0.86;
                var isSuper = game.isSuperFall;

                ctx.save();
                ctx.beginPath();
                ctx.arc(centerX, apexY + topW, topW, Math.PI, 0, false);

                var prevX = centerX + topW;
                var prevY = apexY + topW;
                for (var ri = 0; ri < trailNodes.length; ri++) {
                    var fracR = Math.max(0.0, Math.min(1.0, (trailNodes[ri].y - apexY) / trailHeight));
                    var wR = topW + (botW - topW) * Math.pow(fracR, 0.72);
                    var currX = centerX + wR;
                    var currY = trailNodes[ri].y;
                    var midX = (prevX + currX) * 0.5;
                    var midY = (prevY + currY) * 0.5;
                    ctx.quadraticCurveTo(prevX, prevY, midX, midY);
                    prevX = currX;
                    prevY = currY;
                }
                ctx.quadraticCurveTo(prevX, prevY, centerX + botW, actualBallScreenY);
                ctx.lineTo(centerX - botW, actualBallScreenY);

                var prevLX = centerX - botW;
                var prevLY = actualBallScreenY;
                for (var li = trailNodes.length - 1; li >= 0; li--) {
                    var fracL = Math.max(0.0, Math.min(1.0, (trailNodes[li].y - apexY) / trailHeight));
                    var wL = topW + (botW - topW) * Math.pow(fracL, 0.72);
                    var currLX = centerX - wL;
                    var currLY = trailNodes[li].y;
                    var midLX = (prevLX + currLX) * 0.5;
                    var midLY = (prevLY + currLY) * 0.5;
                    ctx.quadraticCurveTo(prevLX, prevLY, midLX, midLY);
                    prevLX = currLX;
                    prevLY = currLY;
                }
                ctx.quadraticCurveTo(prevLX, prevLY, centerX - topW, apexY + topW);
                ctx.closePath();

                var outerGrad = ctx.createLinearGradient(centerX, apexY, centerX, actualBallScreenY);
                if (isSuper) {
                    outerGrad.addColorStop(0.00, "rgba(255, 56, 56, 0.0)");
                    outerGrad.addColorStop(0.35, "rgba(255, 80, 50, 0.35)");
                    outerGrad.addColorStop(0.70, "rgba(255, 121, 63, 0.65)");
                    outerGrad.addColorStop(1.00, "rgba(255, 218, 121, 0.92)");
                } else {
                    outerGrad.addColorStop(0.00, hexToRgba(theme.ballMid, 0.0));
                    outerGrad.addColorStop(0.35, hexToRgba(theme.ballMid, 0.15));
                    outerGrad.addColorStop(0.70, hexToRgba(theme.ballMid, 0.38));
                    outerGrad.addColorStop(1.00, hexToRgba(theme.ballMid, 0.65));
                }
                ctx.fillStyle = outerGrad;
                ctx.fill();
                ctx.restore();

                var coreApexY = apexY + trailHeight * 0.20;
                var coreTopW = topW * 0.40;
                var coreBotW = botW * 0.42;

                ctx.save();
                ctx.beginPath();
                ctx.moveTo(centerX - coreTopW, coreApexY);
                ctx.quadraticCurveTo(centerX, coreApexY - coreTopW * 0.8, centerX + coreTopW, coreApexY);
                ctx.quadraticCurveTo(centerX + coreBotW * 0.70, (coreApexY + actualBallScreenY) * 0.5, centerX + coreBotW, actualBallScreenY);
                ctx.lineTo(centerX - coreBotW, actualBallScreenY);
                ctx.quadraticCurveTo(centerX - coreBotW * 0.70, (coreApexY + actualBallScreenY) * 0.5, centerX - coreTopW, coreApexY);
                ctx.closePath();

                var coreGrad = ctx.createLinearGradient(centerX, coreApexY, centerX, actualBallScreenY);
                if (isSuper) {
                    coreGrad.addColorStop(0.00, "rgba(255, 255, 255, 0.0)");
                    coreGrad.addColorStop(0.45, "rgba(255, 240, 180, 0.45)");
                    coreGrad.addColorStop(1.00, "rgba(255, 255, 255, 0.85)");
                } else {
                    coreGrad.addColorStop(0.00, "rgba(255, 255, 255, 0.0)");
                    coreGrad.addColorStop(0.45, hexToRgba(theme.ballLight, 0.25));
                    coreGrad.addColorStop(1.00, hexToRgba(theme.ballLight, 0.60));
                }
                ctx.fillStyle = coreGrad;
                ctx.fill();
                ctx.restore();

                if (normFall > 0.32) {
                    var wispAlpha = Math.min(0.38, (normFall - 0.32) * 0.55);
                    var wispLen = Math.min(trailHeight * 0.70, bRadius * (1.2 + 2.0 * normFall));
                    var wispTopY = actualBallScreenY - wispLen;
                    var wispOffset = bRadiusX * 1.08;

                    ctx.save();
                    ctx.lineWidth = units.gu(0.12);
                    ctx.lineCap = "round";

                    var wispGrad = ctx.createLinearGradient(0, wispTopY, 0, actualBallScreenY);
                    wispGrad.addColorStop(0.0, "rgba(255, 255, 255, 0.0)");
                    wispGrad.addColorStop(0.5, isSuper ? "rgba(255, 180, 100, " + (wispAlpha * 0.6).toFixed(2) + ")" : "rgba(255, 255, 255, " + (wispAlpha * 0.5).toFixed(2) + ")");
                    wispGrad.addColorStop(1.0, isSuper ? "rgba(255, 230, 150, " + wispAlpha.toFixed(2) + ")" : "rgba(255, 255, 255, " + wispAlpha.toFixed(2) + ")");
                    ctx.strokeStyle = wispGrad;

                    ctx.beginPath();
                    ctx.moveTo(centerX - wispOffset, wispTopY);
                    ctx.lineTo(centerX - wispOffset, actualBallScreenY);
                    ctx.stroke();

                    ctx.beginPath();
                    ctx.moveTo(centerX + wispOffset, wispTopY);
                    ctx.lineTo(centerX + wispOffset, actualBallScreenY);
                    ctx.stroke();

                    ctx.restore();
                }
            }
        }

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

        ctx.beginPath();
        ctx.arc(0, 0, bRadius, 0, Math.PI * 2.0);
        ctx.clip();

        ctx.fillStyle = theme.ballMid;
        ctx.fill();

        var rotX = game.ballRotationX || 0.0;
        var rotY = game.ballRotationY || 0.0;

        ctx.beginPath();
        for (var eq = 0; eq < GamePhysics.EQUATOR_COORDS.length; eq++) {
            var eq1 = GamePhysics.projectSpherePoint(GamePhysics.EQUATOR_COORDS[eq], rotX, rotY, bRadius);
            var eq2 = GamePhysics.projectSpherePoint(GamePhysics.EQUATOR_COORDS[(eq + 1) % GamePhysics.EQUATOR_COORDS.length], rotX, rotY, bRadius);
            if (eq1.z > 0 && eq2.z > 0) {
                ctx.moveTo(eq1.x, eq1.y);
                ctx.lineTo(eq2.x, eq2.y);
            } else if (eq1.z > 0 && eq2.z <= 0) {
                var fracE = eq1.z / (eq1.z - eq2.z);
                ctx.moveTo(eq1.x, eq1.y);
                ctx.lineTo(eq1.x + (eq2.x - eq1.x) * fracE, eq1.y + (eq2.y - eq1.y) * fracE);
            } else if (eq1.z <= 0 && eq2.z > 0) {
                var fracE2 = -eq1.z / (eq2.z - eq1.z);
                ctx.moveTo(eq1.x + (eq2.x - eq1.x) * fracE2, eq1.y + (eq2.y - eq1.y) * fracE2);
                ctx.lineTo(eq2.x, eq2.y);
            }
        }
        ctx.strokeStyle = "rgba(255, 255, 255, 0.16)";
        ctx.lineWidth = units.gu(0.12);
        ctx.stroke();

        ctx.beginPath();
        for (var sm = 0; sm < GamePhysics.SEAM_COORDS.length; sm++) {
            var sm1 = GamePhysics.projectSpherePoint(GamePhysics.SEAM_COORDS[sm], rotX, rotY, bRadius);
            var sm2 = GamePhysics.projectSpherePoint(GamePhysics.SEAM_COORDS[(sm + 1) % GamePhysics.SEAM_COORDS.length], rotX, rotY, bRadius);
            if (sm1.z > 0 && sm2.z > 0) {
                ctx.moveTo(sm1.x, sm1.y);
                ctx.lineTo(sm2.x, sm2.y);
            } else if (sm1.z > 0 && sm2.z <= 0) {
                var fracS = sm1.z / (sm1.z - sm2.z);
                ctx.moveTo(sm1.x, sm1.y);
                ctx.lineTo(sm1.x + (sm2.x - sm1.x) * fracS, sm1.y + (sm2.y - sm1.y) * fracS);
            } else if (sm1.z <= 0 && sm2.z > 0) {
                var fracS2 = -sm1.z / (sm2.z - sm1.z);
                ctx.moveTo(sm1.x + (sm2.x - sm1.x) * fracS2, sm1.y + (sm2.y - sm1.y) * fracS2);
                ctx.lineTo(sm2.x, sm2.y);
            }
        }
        ctx.strokeStyle = "rgba(0, 0, 0, 0.32)";
        ctx.lineWidth = units.gu(0.20);
        ctx.stroke();

        ctx.strokeStyle = "rgba(255, 255, 255, 0.30)";
        ctx.lineWidth = units.gu(0.08);
        ctx.stroke();

        var pips = [
            { x: 0, y: 1, z: 0 },
            { x: 0, y: -1, z: 0 },
            { x: 1, y: 0, z: 0 },
            { x: -1, y: 0, z: 0 }
        ];
        for (var pi = 0; pi < pips.length; pi++) {
            var pProj = GamePhysics.projectSpherePoint(pips[pi], rotX, rotY, bRadius);
            if (pProj.z > 0.08) {
                var pipR = bRadius * 0.16 * Math.sqrt(pProj.z);
                ctx.beginPath();
                ctx.arc(pProj.x, pProj.y, pipR, 0, Math.PI * 2.0);
                ctx.fillStyle = theme.ballLight;
                ctx.globalAlpha = Math.min(1.0, pProj.z * 1.3) * 0.70;
                ctx.fill();

                ctx.beginPath();
                ctx.arc(pProj.x, pProj.y, pipR * 0.45, 0, Math.PI * 2.0);
                ctx.fillStyle = theme.ballDark;
                ctx.fill();
            }
        }
        ctx.globalAlpha = 1.0;

        var lightingGrad = ctx.createRadialGradient(
            -bRadius * 0.35,
            -bRadius * 0.38,
            bRadius * 0.06,
            0,
            0,
            bRadius
        );
        lightingGrad.addColorStop(0.0, "rgba(255, 255, 255, 0.45)");
        lightingGrad.addColorStop(0.20, "rgba(255, 255, 255, 0.15)");
        lightingGrad.addColorStop(0.55, "rgba(0, 0, 0, 0.0)");
        lightingGrad.addColorStop(0.85, "rgba(0, 0, 0, 0.38)");
        lightingGrad.addColorStop(1.0, "rgba(0, 0, 0, 0.75)");

        ctx.fillStyle = lightingGrad;
        ctx.beginPath();
        ctx.arc(0, 0, bRadius, 0, Math.PI * 2.0);
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
        ctx.fillStyle = "rgba(255, 255, 255, 0.92)";
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
