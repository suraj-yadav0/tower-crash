// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Suraj Yadav <surajyadav200701@gmail.com>

import QtQuick 2.9
import Lomiri.Components 1.3
import QtSystemInfo 5.0
import QtMultimedia 5.0
import QtFeedback 5.0
import QtQuick.LocalStorage 2.0

MainView {
    id: root
    objectName: "mainView"
    applicationName: "tower-crash.surajyadav"
    automaticOrientation: false

    width: units.gu(45)
    height: units.gu(80)

    // Audio effects
    SoundEffect {
        id: sfxBounce
        source: "../assets/sounds/bounce.wav"
        muted: !gameContainer.soundEnabled
    }
    SoundEffect {
        id: sfxPass
        source: "../assets/sounds/pass.wav"
        muted: !gameContainer.soundEnabled
    }
    SoundEffect {
        id: sfxSmash
        source: "../assets/sounds/smash.wav"
        muted: !gameContainer.soundEnabled
    }
    SoundEffect {
        id: sfxGameOver
        source: "../assets/sounds/gameover.wav"
        muted: !gameContainer.soundEnabled
    }

    // Tactile haptic feedback
    HapticsEffect {
        id: hapticLight
        duration: 25
        intensity: 0.6
    }
    HapticsEffect {
        id: hapticHeavy
        duration: 70
        intensity: 1.0
    }
    ThemeEffect {
        id: themeHaptic
        effect: ThemeEffect.Press
    }

    function playSound(type) {
        if (!gameContainer.soundEnabled) return;
        try {
            if (type === "bounce") {
                sfxBounce.play();
            } else if (type === "pass") {
                sfxPass.play();
            } else if (type === "smash") {
                sfxSmash.play();
            } else if (type === "gameover") {
                sfxGameOver.play();
            }
        } catch (err) {}
    }

    function triggerHaptic(strong) {
        if (!gameContainer.hapticsEnabled) return;
        try {
            if (strong) {
                hapticHeavy.start();
            } else {
                hapticLight.start();
            }
        } catch (err) {
            themeHaptic.play();
        }
    }

    // Auto-pause when app is unfocused or minimized
    Connections {
        target: Qt.application
        function onActiveChanged() {
            if (!Qt.application.active && !gameContainer.gameOver) {
                gameContainer.isPaused = true;
            }
        }
    }

    ScreenSaver {
        id: screenSaver
        screenSaverEnabled: !Qt.application.active || gameContainer.isPaused || gameContainer.gameOver
    }

    Page {
        id: gamePage
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr("Tower Crash")
            trailingActionBar.actions: [
                Action {
                    iconName: gameContainer.isPaused ? "media-playback-start" : "media-playback-pause"
                    text: gameContainer.isPaused ? i18n.tr("Resume") : i18n.tr("Pause")
                    onTriggered: {
                        if (!gameContainer.gameOver) {
                            gameContainer.isPaused = !gameContainer.isPaused;
                        }
                    }
                }
            ]
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
            property int totalRings: 0
            property bool gameOver: false
            property bool isPaused: false

            property bool soundEnabled: true
            property bool hapticsEnabled: true

            property real towerAngle: 0.0
            property real angularVelocity: 0.0
            property bool isDragging: false
            property real lastDragX: 0.0
            property real lastDragTime: 0.0

            property real ballY: 0.0
            property real ballVy: 0.0
            property real cameraY: 0.0
            property real squash: 1.0
            property bool isSuperFall: false

            property real ringSpacing: units.gu(14)
            property real outerRadius: units.gu(15)
            property real innerRadius: units.gu(3.2)
            property real poleRadius: units.gu(2.8)
            property real ballRadius: units.gu(1.5)
            property real ringHeight: units.gu(1.2)
            property real tiltRatio: 0.36

            property real gravity: units.gu(185)
            property real bounceSpeed: units.gu(48)
            property real maxFallSpeed: units.gu(120)

            property real ballScreenY: height * 0.35
            property var rings: []
            property int nextRingIndex: 0
            property var particles: []
            property var ballTrail: []

            property int levelRings: 20
            property int currentLevel: Math.floor(Math.max(0, ballY - units.gu(2)) / (ringSpacing * levelRings)) + 1
            property real levelProgress: {
                var depthInLevel = (Math.max(0, ballY) / ringSpacing) - (currentLevel - 1) * levelRings;
                return Math.min(1.0, Math.max(0.0, depthInLevel / levelRings));
            }
            property string bannerText: ""
            property real bannerOpacity: 0.0

            function getDatabase() {
                return LocalStorage.openDatabaseSync("TowerCrashDB", "1.0", "Tower Crash Persistence", 100000);
            }

            function loadPersistence() {
                try {
                    var db = getDatabase();
                    db.transaction(function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS kv (k TEXT UNIQUE, v TEXT)');
                        var rs = tx.executeSql('SELECT v FROM kv WHERE k = "bestScore"');
                        if (rs.rows.length > 0) bestScore = parseInt(rs.rows.item(0).v) || 0;
                        rs = tx.executeSql('SELECT v FROM kv WHERE k = "soundEnabled"');
                        if (rs.rows.length > 0) soundEnabled = (rs.rows.item(0).v === "1");
                        rs = tx.executeSql('SELECT v FROM kv WHERE k = "hapticsEnabled"');
                        if (rs.rows.length > 0) hapticsEnabled = (rs.rows.item(0).v === "1");
                        rs = tx.executeSql('SELECT v FROM kv WHERE k = "totalRings"');
                        if (rs.rows.length > 0) totalRings = parseInt(rs.rows.item(0).v) || 0;
                    });
                } catch (e) {
                    // LocalStorage unavailable, fall back to default in-memory state
                }
            }

            function saveStat(k, v) {
                try {
                    var db = getDatabase();
                    db.transaction(function(tx) {
                        tx.executeSql('INSERT OR REPLACE INTO kv VALUES(?, ?)', [k, v.toString()]);
                    });
                } catch (e) {}
            }

            function getTheme(levelNum) {
                var themeIdx = (levelNum - 1) % 4;
                if (themeIdx === 0) {
                    return {
                        topSafe: "#00b4d8",
                        sideSafe: "#0077b6",
                        topHazard: "#ff4757",
                        sideHazard: "#b71523",
                        ballLight: "#fff5cc",
                        ballMid: "#ffd166",
                        ballDark: "#d62828",
                        bgTop: "#192026",
                        bgBottom: "#0e1317",
                        pole1: "#2c3440",
                        pole2: "#525f6e",
                        pole3: "#1c2128"
                    };
                } else if (themeIdx === 1) {
                    return {
                        topSafe: "#a29bfe",
                        sideSafe: "#6c5ce7",
                        topHazard: "#ff6b6b",
                        sideHazard: "#ee5253",
                        ballLight: "#e0fcfc",
                        ballMid: "#00d2d3",
                        ballDark: "#01a3a4",
                        bgTop: "#1a1224",
                        bgBottom: "#0f0b15",
                        pole1: "#382952",
                        pole2: "#624b87",
                        pole3: "#1f1430"
                    };
                } else if (themeIdx === 2) {
                    return {
                        topSafe: "#ffeaa7",
                        sideSafe: "#fdcb6e",
                        topHazard: "#eb2f06",
                        sideHazard: "#b71540",
                        ballLight: "#ffe6f9",
                        ballMid: "#ff9ff3",
                        ballDark: "#f368e0",
                        bgTop: "#1c1c14",
                        bgBottom: "#10100a",
                        pole1: "#47402c",
                        pole2: "#786d4e",
                        pole3: "#262215"
                    };
                } else {
                    return {
                        topSafe: "#ff9f43",
                        sideSafe: "#ee5253",
                        topHazard: "#ff3838",
                        sideHazard: "#c0392b",
                        ballLight: "#dff9fb",
                        ballMid: "#54a0ff",
                        ballDark: "#2e86de",
                        bgTop: "#22120e",
                        bgBottom: "#130a08",
                        pole1: "#47241b",
                        pole2: "#784133",
                        pole3: "#26110c"
                    };
                }
            }

            function spawnParticles(x, y, count, color, speedMultiplier) {
                if (particles.length > 80) {
                    particles.splice(0, particles.length - 80);
                }
                for (var i = 0; i < count; i++) {
                    var angle = Math.random() * Math.PI * 2.0;
                    var speed = (units.gu(8) + Math.random() * units.gu(18)) * speedMultiplier;
                    particles.push({
                        x: x + (Math.random() - 0.5) * units.gu(3),
                        y: y,
                        z: (Math.random() - 0.5) * units.gu(3),
                        vx: Math.cos(angle) * speed,
                        vy: -Math.random() * units.gu(16) * speedMultiplier,
                        vz: Math.sin(angle) * speed,
                        color: color,
                        alpha: 1.0,
                        size: units.gu(0.4 + Math.random() * 0.6)
                    });
                }
            }

            function generateRing() {
                var index = nextRingIndex++;
                var ringY = (index + 1) * ringSpacing;
                var segments = [0, 0, 0, 0, 0, 0, 0, 0];
                var isGoal = (index > 0 && (index + 1) % 20 === 0);

                if (index === 0) {
                    segments[2] = 0;
                    segments[6] = 1;
                } else if (isGoal) {
                    // Golden stage milestone platform: safe landing across all sectors
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

                rings.push({
                    index: index,
                    y: ringY,
                    segments: segments,
                    passed: false,
                    broken: false,
                    isGoal: isGoal,
                    goalAwarded: false,
                    splats: []
                });
            }

            function initGame() {
                score = 0;
                streak = 0;
                towerAngle = 0.0;
                angularVelocity = 0.0;
                isDragging = false;
                rings = [];
                particles = [];
                ballTrail = [];
                nextRingIndex = 0;
                squash = 1.0;
                isSuperFall = false;
                bannerText = "";
                bannerOpacity = 0.0;

                for (var i = 0; i < 14; i++) {
                    generateRing();
                }

                ballY = ringSpacing - units.gu(5.0);
                ballVy = 0.0;
                cameraY = ringSpacing;
                gameOver = false;
                isPaused = false;
                gameCanvas.requestPaint();
            }

            Component.onCompleted: {
                loadPersistence();
                initGame();
            }

            Keys.onLeftPressed: {
                if (!gameOver && !isPaused) {
                    towerAngle += 0.12;
                    gameCanvas.requestPaint();
                }
            }
            Keys.onRightPressed: {
                if (!gameOver && !isPaused) {
                    towerAngle -= 0.12;
                    gameCanvas.requestPaint();
                }
            }
            Keys.onSpacePressed: {
                if (gameOver) {
                    initGame();
                } else {
                    isPaused = !isPaused;
                }
            }

            Timer {
                id: physicsTimer
                interval: 16
                repeat: true
                running: !gameContainer.gameOver && !gameContainer.isPaused

                onTriggered: {
                    var dt = 0.016;
                    var prevY = gameContainer.ballY;

                    // Apply inertial tower rotation friction
                    if (!gameContainer.isDragging && Math.abs(gameContainer.angularVelocity) > 0.0001) {
                        gameContainer.towerAngle += gameContainer.angularVelocity;
                        gameContainer.angularVelocity *= 0.88;
                    }

                    var currentDepth = Math.floor(gameContainer.ballY / gameContainer.ringSpacing);
                    var speedScale = 1.0 + Math.min(0.35, currentDepth * 0.005);
                    var effectiveGravity = gameContainer.gravity * speedScale;

                    gameContainer.ballVy += effectiveGravity * dt;
                    if (gameContainer.ballVy > gameContainer.maxFallSpeed) {
                        gameContainer.ballVy = gameContainer.maxFallSpeed;
                    }

                    // Super fall triggers when dropping through 3 or more rings at terminal descent
                    gameContainer.isSuperFall = (gameContainer.streak >= 3 && gameContainer.ballVy > gameContainer.gravity * 0.35);

                    var nextY = gameContainer.ballY + gameContainer.ballVy * dt;

                    // Update motion trail
                    if (gameContainer.ballVy > 0) {
                        gameContainer.ballTrail.push({
                            y: gameContainer.ballY,
                            isSuper: gameContainer.isSuperFall,
                            alpha: 0.7
                        });
                        if (gameContainer.ballTrail.length > 5) {
                            gameContainer.ballTrail.shift();
                        }
                    } else if (gameContainer.ballTrail.length > 0) {
                        gameContainer.ballTrail.shift();
                    }
                    for (var t = 0; t < gameContainer.ballTrail.length; t++) {
                        gameContainer.ballTrail[t].alpha -= dt * 3.5;
                    }

                    if (gameContainer.bannerOpacity > 0) {
                        gameContainer.bannerOpacity = Math.max(0.0, gameContainer.bannerOpacity - dt * 0.6);
                    }

                    if (gameContainer.ballVy > 0) {
                        for (var i = 0; i < gameContainer.rings.length; i++) {
                            var ring = gameContainer.rings[i];
                            if (ring.broken) continue;

                            if (prevY <= ring.y && nextY >= ring.y) {
                                var relAngle = ((Math.PI / 2.0 - gameContainer.towerAngle) % (2.0 * Math.PI));
                                if (relAngle < 0) {
                                    relAngle += 2.0 * Math.PI;
                                }

                                var segmentIdx = Math.floor(relAngle / (Math.PI / 4.0));
                                if (segmentIdx < 0) segmentIdx = 0;
                                if (segmentIdx > 7) segmentIdx = 7;

                                var segType = ring.segments[segmentIdx];

                                if (ring.isGoal) {
                                    ring.broken = true;
                                    gameContainer.spawnParticles(0, ring.y, 45, "#ffd700", 2.2);
                                    gameContainer.spawnParticles(0, ring.y, 25, "#ffffff", 1.8);
                                    root.playSound("smash");
                                    root.triggerHaptic(true);

                                    gameContainer.score += 100;
                                    gameContainer.streak = 0;
                                    gameContainer.isSuperFall = false;
                                    gameContainer.totalRings++;
                                    gameContainer.saveStat("totalRings", gameContainer.totalRings);

                                    gameContainer.ballY = ring.y;
                                    gameContainer.ballVy = -gameContainer.bounceSpeed * speedScale * 1.1;
                                    gameContainer.squash = 0.5;
                                    nextY = ring.y;

                                    gameContainer.bannerText = i18n.tr("LEVEL %1 COMPLETE!").arg(gameContainer.currentLevel);
                                    gameContainer.bannerOpacity = 1.0;

                                    if (gameContainer.score > gameContainer.bestScore) {
                                        gameContainer.bestScore = gameContainer.score;
                                        gameContainer.saveStat("bestScore", gameContainer.bestScore);
                                    }
                                    break;
                                }

                                if (gameContainer.isSuperFall && segType !== 1) {
                                    ring.broken = true;
                                    gameContainer.spawnParticles(0, ring.y, 35, "#ff9f43", 2.0);
                                    gameContainer.spawnParticles(0, ring.y, 15, "#ff5252", 1.6);
                                    root.playSound("smash");
                                    root.triggerHaptic(true);

                                    gameContainer.score += 25;
                                    gameContainer.streak = 0;
                                    gameContainer.isSuperFall = false;
                                    gameContainer.totalRings++;
                                    gameContainer.saveStat("totalRings", gameContainer.totalRings);

                                    gameContainer.ballY = ring.y;
                                    gameContainer.ballVy = -gameContainer.bounceSpeed * speedScale;
                                    gameContainer.squash = 0.55;
                                    nextY = ring.y;

                                    if (gameContainer.score > gameContainer.bestScore) {
                                        gameContainer.bestScore = gameContainer.score;
                                        gameContainer.saveStat("bestScore", gameContainer.bestScore);
                                    }
                                    break;
                                }

                                if (segType === 0) {
                                    gameContainer.ballY = ring.y;
                                    gameContainer.ballVy = -gameContainer.bounceSpeed * speedScale;
                                    gameContainer.streak = 0;
                                    gameContainer.isSuperFall = false;
                                    gameContainer.squash = 0.65;
                                    nextY = ring.y;

                                    root.playSound("bounce");
                                    root.triggerHaptic(false);

                                    ring.splats.push({
                                        angle: relAngle,
                                        radius: units.gu(1.5 + Math.random() * 0.8)
                                    });

                                    var theme = gameContainer.getTheme(gameContainer.currentLevel);
                                    gameContainer.spawnParticles(0, ring.y, 7, theme.ballMid, 0.7);
                                    break;
                                } else if (segType === 2) {
                                    gameContainer.ballY = ring.y;
                                    gameContainer.ballVy = 0;
                                    gameContainer.gameOver = true;
                                    gameContainer.isSuperFall = false;
                                    root.playSound("gameover");
                                    root.triggerHaptic(true);
                                    gameContainer.spawnParticles(0, ring.y, 24, "#ff4757", 1.4);

                                    if (gameContainer.score > gameContainer.bestScore) {
                                        gameContainer.bestScore = gameContainer.score;
                                        gameContainer.saveStat("bestScore", gameContainer.bestScore);
                                    }
                                    gameCanvas.requestPaint();
                                    return;
                                } else if (segType === 1) {
                                    if (!ring.passed) {
                                        ring.passed = true;
                                        gameContainer.streak++;
                                        gameContainer.score += gameContainer.streak;
                                        gameContainer.totalRings++;
                                        root.playSound("pass");

                                        if (gameContainer.streak >= 3) {
                                            root.triggerHaptic(true);
                                            if (gameContainer.ballVy > gameContainer.gravity * 0.35) {
                                                gameContainer.isSuperFall = true;
                                            }
                                        }

                                        if (gameContainer.score > gameContainer.bestScore) {
                                            gameContainer.bestScore = gameContainer.score;
                                            gameContainer.saveStat("bestScore", gameContainer.bestScore);
                                        }
                                        gameContainer.saveStat("totalRings", gameContainer.totalRings);
                                    }
                                }
                            }
                        }
                    }

                    gameContainer.ballY = nextY;

                    var targetCamera = gameContainer.ballY;
                    if (gameContainer.ballVy < 0) {
                        gameContainer.cameraY += (targetCamera - gameContainer.cameraY) * 0.12;
                    } else {
                        gameContainer.cameraY += (targetCamera - gameContainer.cameraY) * 0.32;
                        if (gameContainer.ballY - gameContainer.cameraY > units.gu(5)) {
                            gameContainer.cameraY = gameContainer.ballY - units.gu(5);
                        }
                    }

                    gameContainer.squash += (1.0 - gameContainer.squash) * 0.28;

                    // Update particle physics
                    for (var p = gameContainer.particles.length - 1; p >= 0; p--) {
                        var pt = gameContainer.particles[p];
                        pt.x += pt.vx * dt;
                        pt.y += pt.vy * dt;
                        pt.z += pt.vz * dt;
                        pt.vy += gameContainer.gravity * 0.45 * dt;
                        pt.alpha -= dt * 1.5;
                        if (pt.alpha <= 0) {
                            gameContainer.particles.splice(p, 1);
                        }
                    }

                    var lastRing = gameContainer.rings[gameContainer.rings.length - 1];
                    while (lastRing && lastRing.y < gameContainer.cameraY + gameContainer.ringSpacing * 8) {
                        gameContainer.generateRing();
                        lastRing = gameContainer.rings[gameContainer.rings.length - 1];
                    }

                    while (gameContainer.rings.length > 0 &&
                           gameContainer.rings[0].y < gameContainer.cameraY - gameContainer.ringSpacing * 3) {
                        gameContainer.rings.shift();
                    }

                    gameCanvas.requestPaint();
                }
            }

            Canvas {
                id: gameCanvas
                anchors.fill: parent

                onPaint: {
                    var ctx = getContext("2d");
                    var w = width;
                    var h = height;
                    var centerX = w / 2.0;

                    ctx.clearRect(0, 0, w, h);

                    var theme = gameContainer.getTheme(gameContainer.currentLevel);

                    // Dynamic background
                    var bgGrad = ctx.createLinearGradient(0, 0, 0, h);
                    bgGrad.addColorStop(0.0, theme.bgTop);
                    bgGrad.addColorStop(1.0, theme.bgBottom);
                    ctx.fillStyle = bgGrad;
                    ctx.fillRect(0, 0, w, h);

                    // Central column cylinder
                    var poleGrad = ctx.createLinearGradient(
                        centerX - gameContainer.poleRadius, 0,
                        centerX + gameContainer.poleRadius, 0
                    );
                    poleGrad.addColorStop(0.0, theme.pole1);
                    poleGrad.addColorStop(0.35, theme.pole2);
                    poleGrad.addColorStop(1.0, theme.pole3);
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

                    // Render rings
                    for (var r = 0; r < gameContainer.rings.length; r++) {
                        var ring = gameContainer.rings[r];
                        if (ring.broken) continue;

                        var ringScreenY = bScreenY + (ring.y - camY);

                        if (ringScreenY < -rSpacing || ringScreenY > h + rSpacing) {
                            continue;
                        }

                        for (var seg = 0; seg < 8; seg++) {
                            var segType = ring.segments[seg];
                            if (segType === 1) {
                                continue;
                            }

                            var topColor = ring.isGoal ? "#ffd700" : ((segType === 0) ? theme.topSafe : theme.topHazard);
                            var sideColor = ring.isGoal ? "#cca300" : ((segType === 0) ? theme.sideSafe : theme.sideHazard);

                            var startAngle = gameContainer.towerAngle + seg * (Math.PI / 4.0);
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
                                var splatAngle = gameContainer.towerAngle + splat.angle;
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
                    for (var sr = 0; sr < gameContainer.rings.length; sr++) {
                        var targetRing = gameContainer.rings[sr];
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
                                ctx.arc(0, 0, gameContainer.ballRadius * shadowScale, 0, Math.PI * 2.0);
                                ctx.fillStyle = "rgba(0, 0, 0, " + alpha.toFixed(2) + ")";
                                ctx.fill();
                                ctx.restore();
                            }
                            break;
                        }
                    }

                    // Motion trail behind the ball
                    var bRadius = gameContainer.ballRadius;
                    for (var tr = 0; tr < gameContainer.ballTrail.length; tr++) {
                        var trItem = gameContainer.ballTrail[tr];
                        if (trItem.alpha <= 0) continue;
                        var trailScreenY = bScreenY + (trItem.y - camY);
                        var trailRadius = bRadius * (0.4 + 0.5 * (tr / gameContainer.ballTrail.length));

                        ctx.save();
                        ctx.translate(centerX, trailScreenY);
                        ctx.beginPath();
                        ctx.arc(0, 0, trailRadius, 0, Math.PI * 2.0);
                        ctx.fillStyle = trItem.isSuper ? "#ff793f" : theme.ballMid;
                        ctx.globalAlpha = trItem.alpha * 0.5;
                        ctx.fill();
                        ctx.restore();
                    }

                    var actualBallScreenY = bScreenY + (gameContainer.ballY - camY);

                    // Super fall flame aura
                    if (gameContainer.isSuperFall) {
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
                    ctx.scale(1.0 / Math.sqrt(gameContainer.squash), gameContainer.squash);

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
                    ctx.restore();

                    // Render active 3D particles
                    for (var ptIdx = 0; ptIdx < gameContainer.particles.length; ptIdx++) {
                        var particle = gameContainer.particles[ptIdx];
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

            // Touch & Drag handler with velocity tracking for inertial fling
            MouseArea {
                id: dragArea
                anchors.fill: parent

                onPressed: {
                    gameContainer.isDragging = true;
                    gameContainer.angularVelocity = 0.0;
                    gameContainer.lastDragX = mouse.x;
                    gameContainer.lastDragTime = Date.now();
                }

                onPositionChanged: {
                    if (pressed && !gameContainer.gameOver && !gameContainer.isPaused) {
                        var now = Date.now();
                        var elapsed = Math.max(1, now - gameContainer.lastDragTime);
                        var dx = mouse.x - gameContainer.lastDragX;

                        gameContainer.towerAngle -= dx * 0.014;
                        var fling = -(dx / elapsed) * 0.12;
                        gameContainer.angularVelocity = Math.max(-0.25, Math.min(0.25, fling));

                        gameContainer.lastDragX = mouse.x;
                        gameContainer.lastDragTime = now;
                        gameCanvas.requestPaint();
                    }
                }

                onReleased: {
                    gameContainer.isDragging = false;
                }
                onCanceled: {
                    gameContainer.isDragging = false;
                }
            }

            // HUD: Level progress, Score, and Combos
            Column {
                anchors.top: parent.top
                anchors.topMargin: units.gu(1.5)
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(parent.width - units.gu(4), units.gu(36))
                spacing: units.gu(0.6)

                // Level progression bar
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: units.gu(1.2)

                    Label {
                        text: i18n.tr("Lvl %1").arg(gameContainer.currentLevel)
                        font.pixelSize: units.gu(1.6)
                        font.weight: Font.DemiBold
                        color: "#FFFFFF"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        width: units.gu(20)
                        height: units.gu(0.8)
                        radius: units.gu(0.4)
                        color: "#2a3440"
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            width: parent.width * Math.min(1.0, Math.max(0.0, gameContainer.levelProgress))
                            height: parent.height
                            radius: parent.radius
                            color: "#00d2d3"
                        }
                    }

                    Label {
                        text: i18n.tr("Lvl %1").arg(gameContainer.currentLevel + 1)
                        font.pixelSize: units.gu(1.6)
                        color: "#8fa3b5"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: gameContainer.score.toString()
                    font.pixelSize: units.gu(4.8)
                    font.weight: Font.Bold
                    color: "#FFFFFF"
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: i18n.tr("BEST: %1").arg(gameContainer.bestScore)
                    font.pixelSize: units.gu(1.6)
                    color: "#8fa3b5"
                    visible: gameContainer.bestScore > 0
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: gameContainer.isSuperFall ? i18n.tr("FIREBALL SMASH!") : i18n.tr("COMBO x%1").arg(gameContainer.streak)
                    font.pixelSize: units.gu(1.8)
                    font.weight: Font.Bold
                    color: gameContainer.isSuperFall ? "#ff9f43" : "#ffd166"
                    visible: gameContainer.streak > 1 || gameContainer.isSuperFall
                }
            }

            // Milestone alert banner
            Rectangle {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -units.gu(8)
                width: bannerLabel.width + units.gu(4)
                height: units.gu(5)
                radius: units.gu(2.5)
                color: "#E6000000"
                border.color: "#FFD700"
                border.width: units.gu(0.2)
                opacity: gameContainer.bannerOpacity
                visible: opacity > 0

                Label {
                    id: bannerLabel
                    anchors.centerIn: parent
                    text: gameContainer.bannerText
                    font.pixelSize: units.gu(2.2)
                    font.weight: Font.Bold
                    color: "#FFD700"
                }
            }

            // In-Game Pause Overlay
            Rectangle {
                id: pauseModal
                anchors.fill: parent
                color: "#D90A0E12"
                visible: gameContainer.isPaused && !gameContainer.gameOver

                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: Math.min(parent.width - units.gu(4), units.gu(32))
                    height: units.gu(30)
                    radius: units.gu(1.5)
                    color: "#1c2228"
                    border.color: "#2f3842"
                    border.width: units.gu(0.15)

                    Column {
                        anchors.centerIn: parent
                        width: parent.width - units.gu(4)
                        spacing: units.gu(1.4)

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("PAUSED")
                            font.pixelSize: units.gu(3.0)
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                        }

                        Button {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("Resume")
                            color: "#00b4d8"
                            width: units.gu(20)
                            height: units.gu(4.2)
                            onClicked: {
                                gameContainer.isPaused = false;
                            }
                        }

                        Button {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("Restart")
                            color: "#3b444f"
                            width: units.gu(20)
                            height: units.gu(4.2)
                            onClicked: {
                                gameContainer.initGame();
                            }
                        }

                        Button {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: gameContainer.soundEnabled ? i18n.tr("Sound: ON") : i18n.tr("Sound: OFF")
                            color: gameContainer.soundEnabled ? "#2ed573" : "#57606f"
                            width: units.gu(20)
                            height: units.gu(3.8)
                            onClicked: {
                                gameContainer.soundEnabled = !gameContainer.soundEnabled;
                                gameContainer.saveStat("soundEnabled", gameContainer.soundEnabled ? "1" : "0");
                            }
                        }

                        Button {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: gameContainer.hapticsEnabled ? i18n.tr("Vibration: ON") : i18n.tr("Vibration: OFF")
                            color: gameContainer.hapticsEnabled ? "#2ed573" : "#57606f"
                            width: units.gu(20)
                            height: units.gu(3.8)
                            onClicked: {
                                gameContainer.hapticsEnabled = !gameContainer.hapticsEnabled;
                                gameContainer.saveStat("hapticsEnabled", gameContainer.hapticsEnabled ? "1" : "0");
                            }
                        }
                    }
                }
            }

            // Game Over Overlay
            Rectangle {
                id: gameOverModal
                anchors.fill: parent
                color: "#D90A0E12"
                visible: gameContainer.gameOver

                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: Math.min(parent.width - units.gu(4), units.gu(34))
                    height: units.gu(30)
                    radius: units.gu(1.5)
                    color: "#1c2228"
                    border.color: "#2f3842"
                    border.width: units.gu(0.15)

                    Column {
                        anchors.centerIn: parent
                        width: parent.width - units.gu(4)
                        spacing: units.gu(1.4)

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

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("Reached Level %1").arg(gameContainer.currentLevel)
                            font.pixelSize: units.gu(1.6)
                            color: "#00d2d3"
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
