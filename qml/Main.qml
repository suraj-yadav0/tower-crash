// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Suraj Yadav <surajyadav200701@gmail.com>

import QtQuick 2.9
import Lomiri.Components 1.3

MainView {
    id: root
    objectName: "mainView"
    applicationName: "tower-crash.surajyadav"
    automaticOrientation: false


    width: units.gu(45)
    height: units.gu(80)

    Page {
        id: gamePage
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr("Tower Crash")
        }

        Item {
            id: gameContainer
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            focus: true

            property int score: 0
            property int bestScore: 0
            property int streak: 0
            property bool gameOver: false

            property real towerAngle: 0.0
            property real ballY: 0.0
            property real ballVy: 0.0
            property real cameraY: 0.0
            property real squash: 1.0

            property real ringSpacing: units.gu(14)
            property real outerRadius: units.gu(15)
            property real innerRadius: units.gu(3.2)
            property real poleRadius: units.gu(2.8)
            property real ballRadius: units.gu(1.5)
            property real ringHeight: units.gu(1.2)
            property real tiltRatio: 0.36

            property real gravity: units.gu(90)
            property real bounceSpeed: units.gu(34)
            property real maxFallSpeed: units.gu(65)

            property real ballScreenY: height * 0.35
            property var rings: []
            property int nextRingIndex: 0

            function generateRing() {
                var index = nextRingIndex++;
                var ringY = (index + 1) * ringSpacing;
                var segments = [0, 0, 0, 0, 0, 0, 0, 0];

                if (index === 0) {
                    // Safe front landing on initial spawn
                    segments[2] = 0;
                    segments[6] = 1;
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
                    for (var s = slots.length - 1; s > 0; s--) {
                        var randIdx = Math.floor(Math.random() * (s + 1));
                        var temp = slots[s];
                        slots[s] = slots[randIdx];
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

                rings.push({
                    index: index,
                    y: ringY,
                    segments: segments,
                    passed: false
                });
            }

            function initGame() {
                score = 0;
                streak = 0;
                towerAngle = 0.0;
                rings = [];
                nextRingIndex = 0;
                squash = 1.0;

                for (var i = 0; i < 12; i++) {
                    generateRing();
                }

                ballY = ringSpacing - units.gu(5.0);
                ballVy = 0.0;
                cameraY = ringSpacing;
                gameOver = false;
                gameCanvas.requestPaint();
            }

            Component.onCompleted: {
                initGame();
            }

            // Keyboard navigation: left rotates left, right rotates right
            Keys.onLeftPressed: {
                if (!gameOver) {
                    towerAngle += 0.12;
                    gameCanvas.requestPaint();
                }
            }
            Keys.onRightPressed: {
                if (!gameOver) {
                    towerAngle -= 0.12;
                    gameCanvas.requestPaint();
                }
            }

            // Continuous physics and collision timer
            Timer {
                id: physicsTimer
                interval: 16
                repeat: true
                running: !gameContainer.gameOver

                onTriggered: {
                    var dt = 0.016;
                    var prevY = gameContainer.ballY;

                    var currentDepth = Math.floor(gameContainer.ballY / gameContainer.ringSpacing);
                    var speedScale = 1.0 + Math.min(0.35, currentDepth * 0.005);
                    var effectiveGravity = gameContainer.gravity * speedScale;

                    gameContainer.ballVy += effectiveGravity * dt;
                    if (gameContainer.ballVy > gameContainer.maxFallSpeed) {
                        gameContainer.ballVy = gameContainer.maxFallSpeed;
                    }

                    var nextY = gameContainer.ballY + gameContainer.ballVy * dt;

                    if (gameContainer.ballVy > 0) {
                        for (var i = 0; i < gameContainer.rings.length; i++) {
                            var ring = gameContainer.rings[i];

                            if (prevY <= ring.y && nextY >= ring.y) {
                                // Front of the tower facing the viewer corresponds to angle pi/2
                                var relAngle = ((Math.PI / 2.0 - gameContainer.towerAngle) % (2.0 * Math.PI));
                                if (relAngle < 0) {
                                    relAngle += 2.0 * Math.PI;
                                }

                                var segmentIdx = Math.floor(relAngle / (Math.PI / 4.0));
                                if (segmentIdx < 0) segmentIdx = 0;
                                if (segmentIdx > 7) segmentIdx = 7;

                                var segType = ring.segments[segmentIdx];

                                if (segType === 0) {
                                    gameContainer.ballY = ring.y;
                                    gameContainer.ballVy = -gameContainer.bounceSpeed * speedScale;
                                    gameContainer.streak = 0;
                                    gameContainer.squash = 0.65;
                                    nextY = ring.y;
                                    break;
                                } else if (segType === 2) {
                                    gameContainer.ballY = ring.y;
                                    gameContainer.ballVy = 0;
                                    gameContainer.gameOver = true;
                                    if (gameContainer.score > gameContainer.bestScore) {
                                        gameContainer.bestScore = gameContainer.score;
                                    }
                                    gameCanvas.requestPaint();
                                    return;
                                } else if (segType === 1) {
                                    if (!ring.passed) {
                                        ring.passed = true;
                                        gameContainer.streak++;
                                        gameContainer.score += gameContainer.streak;
                                        if (gameContainer.score > gameContainer.bestScore) {
                                            gameContainer.bestScore = gameContainer.score;
                                        }
                                    }
                                }
                            }
                        }
                    }

                    gameContainer.ballY = nextY;

                    // Keep camera anchored near platform during bounce, accelerate downward tracking during fall
                    var targetCamera = gameContainer.ballY;
                    if (gameContainer.ballVy < 0) {
                        gameContainer.cameraY += (targetCamera - gameContainer.cameraY) * 0.08;
                    } else {
                        gameContainer.cameraY += (targetCamera - gameContainer.cameraY) * 0.22;
                    }

                    gameContainer.squash += (1.0 - gameContainer.squash) * 0.18;

                    var lastRing = gameContainer.rings[gameContainer.rings.length - 1];
                    if (lastRing.y < gameContainer.ballY + gameContainer.height + gameContainer.ringSpacing * 3) {
                        gameContainer.generateRing();
                    }

                    // Prune off-screen rings to prevent unbounded array growth
                    while (gameContainer.rings.length > 0 &&
                           gameContainer.rings[0].y < gameContainer.ballY - gameContainer.height - gameContainer.ringSpacing) {
                        gameContainer.rings.shift();
                    }

                    gameCanvas.requestPaint();
                }
            }

            // Pseudo-3D Canvas rendering
            Canvas {
                id: gameCanvas
                anchors.fill: parent

                onPaint: {
                    var ctx = getContext("2d");
                    var w = width;
                    var h = height;
                    var centerX = w / 2.0;

                    ctx.clearRect(0, 0, w, h);

                    var bgGrad = ctx.createLinearGradient(0, 0, 0, h);
                    bgGrad.addColorStop(0.0, "#192026");
                    bgGrad.addColorStop(1.0, "#0e1317");
                    ctx.fillStyle = bgGrad;
                    ctx.fillRect(0, 0, w, h);

                    var poleGrad = ctx.createLinearGradient(
                        centerX - gameContainer.poleRadius, 0,
                        centerX + gameContainer.poleRadius, 0
                    );
                    poleGrad.addColorStop(0.0, "#2c3440");
                    poleGrad.addColorStop(0.35, "#525f6e");
                    poleGrad.addColorStop(0.7, "#3b444f");
                    poleGrad.addColorStop(1.0, "#1c2128");
                    ctx.fillStyle = poleGrad;
                    ctx.fillRect(
                        centerX - gameContainer.poleRadius,
                        0,
                        gameContainer.poleRadius * 2,
                        h
                    );

                    var rSpacing = gameContainer.ringSpacing;
                    var bY = gameContainer.ballY;
                    var camY = gameContainer.cameraY;
                    var bScreenY = gameContainer.ballScreenY;
                    var outR = gameContainer.outerRadius;
                    var inR = gameContainer.innerRadius;
                    var tilt = gameContainer.tiltRatio;
                    var rHeight = gameContainer.ringHeight;

                    for (var r = 0; r < gameContainer.rings.length; r++) {
                        var ring = gameContainer.rings[r];
                        var ringScreenY = bScreenY + (ring.y - camY);

                        if (ringScreenY < -rSpacing || ringScreenY > h + rSpacing) {
                            continue;
                        }

                        for (var seg = 0; seg < 8; seg++) {
                            var segType = ring.segments[seg];
                            if (segType === 1) {
                                continue;
                            }

                            var topColor = (segType === 0) ? "#00b4d8" : "#ff4757";
                            var sideColor = (segType === 0) ? "#0077b6" : "#b71523";

                            var startAngle = gameContainer.towerAngle + seg * (Math.PI / 4.0);
                            var endAngle = startAngle + (Math.PI / 4.0);

                            // Extrude 3D rim for front-facing segments (sin > 0)
                            ctx.beginPath();
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
                    }

                    for (var sr = 0; sr < gameContainer.rings.length; sr++) {
                        var targetRing = gameContainer.rings[sr];
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
                                ctx.arc(0, 0, gameContainer.ballRadius * shadowScale, 0, Math.PI * 2.0);
                                ctx.fillStyle = "rgba(0, 0, 0, " + alpha.toFixed(2) + ")";
                                ctx.fill();
                                ctx.restore();
                            }
                            break;
                        }
                    }

                    var bRadius = gameContainer.ballRadius;
                    var actualBallScreenY = bScreenY + (gameContainer.ballY - camY);

                    ctx.save();
                    ctx.translate(centerX, actualBallScreenY);
                    ctx.scale(1.0 / Math.sqrt(gameContainer.squash), gameContainer.squash);

                    var ballGrad = ctx.createRadialGradient(
                        -bRadius * 0.32,
                        -bRadius * 0.35,
                        bRadius * 0.1,
                        0,
                        0,
                        bRadius
                    );
                    ballGrad.addColorStop(0.0, "#fff5cc");
                    ballGrad.addColorStop(0.3, "#ffd166");
                    ballGrad.addColorStop(0.75, "#f77f00");
                    ballGrad.addColorStop(1.0, "#d62828");

                    ctx.beginPath();
                    ctx.arc(0, 0, bRadius, 0, Math.PI * 2.0);
                    ctx.fillStyle = ballGrad;
                    ctx.fill();
                    ctx.restore();
                }
            }

            MouseArea {
                id: dragArea
                anchors.fill: parent
                property real lastX: 0

                onPressed: {
                    lastX = mouse.x;
                }

                onPositionChanged: {
                    if (pressed && !gameContainer.gameOver) {
                        var dx = mouse.x - lastX;
                        // Dragging right rotates the cylinder face to the right
                        gameContainer.towerAngle -= dx * 0.012;
                        lastX = mouse.x;
                        gameCanvas.requestPaint();
                    }
                }
            }

            Column {
                anchors.top: parent.top
                anchors.topMargin: units.gu(2)
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: units.gu(0.3)

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: gameContainer.score.toString()
                    font.pixelSize: units.gu(5)
                    font.weight: Font.Bold
                    color: "#FFFFFF"
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: i18n.tr("BEST: %1").arg(gameContainer.bestScore)
                    font.pixelSize: units.gu(1.8)
                    color: "#8fa3b5"
                    visible: gameContainer.bestScore > 0
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: i18n.tr("COMBO x%1").arg(gameContainer.streak)
                    font.pixelSize: units.gu(1.8)
                    font.weight: Font.DemiBold
                    color: "#ffd166"
                    visible: gameContainer.streak > 1
                }
            }

            Rectangle {
                id: gameOverModal
                anchors.fill: parent
                color: "#D90A0E12"
                visible: gameContainer.gameOver

                MouseArea {
                    anchors.fill: parent
                    // Intercept touches from game canvas
                    onClicked: {}
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: Math.min(parent.width - units.gu(4), units.gu(34))
                    height: units.gu(26)
                    radius: units.gu(1.5)
                    color: "#1c2228"
                    border.color: "#2f3842"
                    border.width: units.gu(0.15)

                    Column {
                        anchors.centerIn: parent
                        width: parent.width - units.gu(4)
                        spacing: units.gu(1.6)

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("GAME OVER")
                            font.pixelSize: units.gu(3.2)
                            font.weight: Font.Bold
                            color: "#ff4757"
                        }

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("Score: %1").arg(gameContainer.score)
                            font.pixelSize: units.gu(2.4)
                            color: "#FFFFFF"
                        }

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("Best: %1").arg(gameContainer.bestScore)
                            font.pixelSize: units.gu(1.8)
                            color: "#8fa3b5"
                        }

                        Button {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("Play Again")
                            color: "#2ed573"
                            width: units.gu(18)
                            height: units.gu(4.5)
                            onClicked: {
                                gameContainer.initGame();
                            }
                        }
                    }
                }
            }
        }
    }
}
