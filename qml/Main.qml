import QtQuick 2.9
import Lomiri.Components 1.3
import QtSystemInfo 5.0
import "components"
import "js/Themes.js" as Themes
import "js/Storage.js" as Storage
import "js/RingGenerator.js" as RingGen

MainView {
    id: root
    objectName: "mainView"
    applicationName: "tower-crash.surajyadav"
    automaticOrientation: false
    theme.name: "Lomiri.Components.Themes.SuruDark"

    width: units.gu(45)
    height: units.gu(80)

    ScreenSaver {
        id: screenSaver
        screenSaverEnabled: gameContainer.gameOver || gameContainer.isPaused || gameContainer.isWelcomeOpen || gameContainer.isStageClearOpen
    }

    SoundManager {
        id: soundManager
        soundEnabled: gameContainer.soundEnabled
        hapticsEnabled: gameContainer.hapticsEnabled
    }

    Page {
        id: mainPage
        anchors.fill: parent

        header: PageHeader {
            id: pageHeader
            title: i18n.tr("Tower Crash")
            subtitle: gameContainer.isWelcomeOpen ? i18n.tr("Arcade Edition") : i18n.tr("Level %1").arg(gameContainer.currentLevel)
            z: 100
            visible: true

            trailingActionBar.numberOfSlots: 4
            trailingActionBar.actions: [
                Action {
                    iconName: gameContainer.isPaused ? "media-playback-start" : "media-playback-pause"
                    text: gameContainer.isPaused ? i18n.tr("Resume") : i18n.tr("Pause")
                    visible: !gameContainer.isWelcomeOpen && !gameContainer.isStageClearOpen
                    onTriggered: {
                        if (!gameContainer.gameOver && !gameContainer.isStageClearOpen) {
                            soundManager.buttonHaptic();
                            gameContainer.isPaused = !gameContainer.isPaused;
                        }
                    }
                },
                Action {
                    iconName: "settings"
                    text: i18n.tr("Settings")
                    visible: true
                    onTriggered: {
                        soundManager.buttonHaptic();
                        gameContainer.wasPausedBeforeSettings = gameContainer.isPaused;
                        if (!gameContainer.gameOver && !gameContainer.isWelcomeOpen && !gameContainer.isStageClearOpen) {
                            gameContainer.isPaused = true;
                        }
                        gameContainer.isSettingsOpen = true;
                    }
                },
                Action {
                    iconName: gameContainer.soundEnabled ? "audio-volume-high" : "audio-volume-muted"
                    text: gameContainer.soundEnabled ? i18n.tr("Sound") : i18n.tr("Muted")
                    visible: !gameContainer.isWelcomeOpen
                    onTriggered: {
                        soundManager.buttonHaptic();
                        gameContainer.soundEnabled = !gameContainer.soundEnabled;
                        Storage.saveStat("soundEnabled", gameContainer.soundEnabled ? "1" : "0");
                    }
                },
                Action {
                    iconName: "view-refresh"
                    text: i18n.tr("Restart")
                    visible: !gameContainer.isWelcomeOpen
                    onTriggered: {
                        soundManager.buttonHaptic();
                        gameContainer.startGame();
                    }
                }
            ]
        }

        Item {
            id: gameContainer
            anchors {
                top: pageHeader.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            focus: true

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: units.dp(1)
                color: gameContainer.currentTheme ? gameContainer.currentTheme.cardBorder : "#2A2C30"
                z: 50
            }

            property int score: 0
            property int bestScore: 0
            property int streak: 0
            property int totalRings: 0
            property bool gameOver: false
            property bool isPaused: false
            property bool isSettingsOpen: false
            property bool wasPausedBeforeSettings: false
            property bool isWelcomeOpen: true
            property bool isStageClearOpen: false
            property int stageClearStage: 1
            property int stageClearBonus: 100
            property int stageClearStreak: 0
            property bool stageClearIsCheckpoint: false
            property int stageClearNextCheckpoint: 1
            property bool stageClearIsGrand: false

            property bool soundEnabled: true
            property bool hapticsEnabled: true
            property int themeMode: 0
            property var currentTheme: Themes.getTheme(themeMode, currentLevel)

            property real towerAngle: 0.0
            property real angularVelocity: 0.0
            property bool isDragging: false
            property real lastDragX: 0.0
            property real lastDragTime: 0.0

            property real ballY: 0.0
            property real ballVy: 0.0
            property real cameraY: 0.0
            property real squash: 1.0
            property real squashVelocity: 0.0
            property bool isSuperFall: false

            property real ringSpacing: units.gu(14)
            property real outerRadius: units.gu(15)
            property real innerRadius: units.gu(3.2)
            property real poleRadius: units.gu(2.8)
            property real ballRadius: units.gu(1.5)
            property real ringHeight: units.gu(1.2)
            property real tiltRatio: 0.36

            property int speedMode: 1
            property real speedMultiplier: {
                if (speedMode === 0) return 0.78;
                if (speedMode === 2) return 1.20;
                return 1.0;
            }

            property real baseGravity: units.gu(215)
            property real baseBounceSpeed: units.gu(50)
            property real baseMaxFallSpeed: units.gu(135)

            property real gravity: baseGravity * speedMultiplier
            property real bounceSpeed: baseBounceSpeed * Math.sqrt(speedMultiplier)
            property real maxFallSpeed: baseMaxFallSpeed * speedMultiplier
            property real lastPhysicsTime: 0.0

            property real ballScreenY: units.gu(20.0)
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
            property bool bannerIsCheckpoint: false
            property bool bannerIsZone: false
            property real bannerOpacity: 0.0

            property int highestLevelReached: 1
            property var unlockedCheckpoints: [1]
            property int selectedCheckpoint: 1
            property real activePlayTimeAccumulator: 0.0

            onCurrentLevelChanged: {
                if (currentLevel > highestLevelReached) {
                    highestLevelReached = currentLevel;
                    Storage.saveHighestLevel(highestLevelReached);
                }
                if (isCheckpointLevel(currentLevel)) {
                    unlockCheckpoint(currentLevel);
                }
            }

            function isCheckpointLevel(lvl) {
                return lvl === 1 || (lvl > 1 && (lvl - 1) % 5 === 0);
            }

            function getNearestCheckpoint(lvl) {
                var nearest = 1;
                for (var i = 0; i < unlockedCheckpoints.length; i++) {
                    var cp = unlockedCheckpoints[i];
                    if (cp <= lvl && cp > nearest) {
                        nearest = cp;
                    }
                }
                return nearest;
            }

            function unlockCheckpoint(lvl) {
                if (!isCheckpointLevel(lvl)) return;
                var list = unlockedCheckpoints.slice();
                if (list.indexOf(lvl) === -1) {
                    list.push(lvl);
                    list.sort(function(a, b) { return a - b; });
                    unlockedCheckpoints = list;
                    Storage.saveUnlockedCheckpoints(unlockedCheckpoints);
                }
            }

            function startFromCheckpoint(checkpointLevel) {
                var validCheckpoint = Math.max(1, checkpointLevel || selectedCheckpoint || 1);
                selectedCheckpoint = validCheckpoint;
                Storage.saveSelectedCheckpoint(selectedCheckpoint);
                initGame(validCheckpoint);
            }

            function spawnParticles(x, y, count, color, speedMultiplier) {
                var mult = speedMultiplier || 1.0;
                var midR = (outerRadius + innerRadius) / 2.0;
                for (var p = 0; p < count; p++) {
                    var angle = Math.random() * Math.PI * 2.0;
                    var speed = (units.gu(2) + Math.random() * units.gu(10)) * mult;
                    var rSpread = (Math.random() - 0.5) * (outerRadius - innerRadius);
                    particles.push({
                        x: x + Math.cos(angle) * rSpread,
                        y: y,
                        z: midR + Math.sin(angle) * rSpread,
                        vx: Math.cos(angle) * speed,
                        vy: -Math.random() * units.gu(16) * mult,
                        vz: Math.sin(angle) * speed,
                        color: color,
                        alpha: 1.0,
                        size: units.gu(0.4 + Math.random() * 0.6)
                    });
                }
            }

            function spawnBounceDust(y, color1, color2) {
                var midR = (outerRadius + innerRadius) / 2.0;
                var count = 9;
                for (var p = 0; p < count; p++) {
                    var angle = Math.random() * Math.PI * 2.0;
                    var speed = units.gu(4.0) + Math.random() * units.gu(8.0);
                    particles.push({
                        x: Math.cos(angle) * units.gu(0.6),
                        y: y,
                        z: midR + Math.sin(angle) * units.gu(0.6),
                        vx: Math.cos(angle) * speed,
                        vy: -units.gu(1.5) - Math.random() * units.gu(4.0),
                        vz: Math.sin(angle) * speed,
                        color: (Math.random() < 0.6) ? color1 : color2,
                        alpha: 0.85,
                        size: units.gu(0.28 + Math.random() * 0.32)
                    });
                }
            }

            function spawnShatterDebris(ringY, isGoal, isGrand, theme, isSuper) {
                var midR = (outerRadius + innerRadius) / 2.0;
                var topClr = isGoal ? (isGrand ? "#FFD700" : (theme.goalTop || "#E8C872")) : (isSuper ? theme.topSafe : theme.topSafe);
                var edgeClr = isGoal ? (isGrand ? "#B8860B" : (theme.goalSide || "#B09242")) : (isSuper ? theme.sideSafe : theme.sideSafe);

                particles.push({
                    kind: "shockwave",
                    x: 0,
                    y: ringY,
                    z: midR,
                    vx: 0,
                    vy: 0,
                    vz: 0,
                    radius: units.gu(1.5),
                    maxRadius: outerRadius * 1.5,
                    speed: units.gu(34.0),
                    thickness: units.gu(0.45),
                    color: isGoal ? (isGrand ? "#FFD700" : "#E8C872") : (isSuper ? "#FF793F" : theme.topSafe),
                    alpha: 0.95,
                    decay: 3.2
                });

                var chunkCount = isGrand ? 8 : 6;
                for (var c = 0; c < chunkCount; c++) {
                    var chunkAngle = (c / chunkCount) * Math.PI * 2.0 + (Math.random() - 0.5) * 0.35;
                    var chunkR = midR + (Math.random() - 0.5) * units.gu(1.6);
                    var radialSpeed = (units.gu(8) + Math.random() * units.gu(10)) * (isSuper ? 1.4 : 1.0);
                    var cw = units.gu(1.8 + Math.random() * 1.2);
                    var ch = units.gu(1.3 + Math.random() * 0.8);

                    particles.push({
                        kind: "chunk",
                        x: Math.cos(chunkAngle) * chunkR,
                        y: ringY,
                        z: Math.sin(chunkAngle) * chunkR,
                        vx: Math.cos(chunkAngle) * radialSpeed,
                        vy: -units.gu(4 + Math.random() * 8) * (isSuper ? 1.3 : 1.0),
                        vz: Math.sin(chunkAngle) * radialSpeed,
                        rotX: Math.random() * Math.PI * 2.0,
                        rotY: Math.random() * Math.PI * 2.0,
                        rotZ: Math.random() * Math.PI * 2.0,
                        vrotX: (Math.random() - 0.5) * 8.0,
                        vrotY: (Math.random() - 0.5) * 9.0,
                        vrotZ: (Math.random() - 0.5) * 8.0,
                        width: cw,
                        height: ch,
                        depth: units.gu(0.7),
                        topColor: topClr,
                        edgeColor: edgeClr,
                        specular: isGoal,
                        alpha: 1.0,
                        decay: 0.9
                    });
                }

                var shardCount = isGrand ? 16 : 12;
                for (var s = 0; s < shardCount; s++) {
                    var shardAngle = Math.random() * Math.PI * 2.0;
                    var shardR = innerRadius + Math.random() * (outerRadius - innerRadius);
                    var shardSpeed = (units.gu(10) + Math.random() * units.gu(14)) * (isSuper ? 1.4 : 1.0);
                    var sw = units.gu(0.9 + Math.random() * 0.8);
                    var sh = units.gu(0.8 + Math.random() * 0.7);

                    particles.push({
                        kind: "shard",
                        x: Math.cos(shardAngle) * shardR,
                        y: ringY,
                        z: Math.sin(shardAngle) * shardR,
                        vx: Math.cos(shardAngle) * shardSpeed,
                        vy: -units.gu(5 + Math.random() * 9),
                        vz: Math.sin(shardAngle) * shardSpeed,
                        rotX: Math.random() * Math.PI * 2.0,
                        rotY: Math.random() * Math.PI * 2.0,
                        rotZ: Math.random() * Math.PI * 2.0,
                        vrotX: (Math.random() - 0.5) * 14.0,
                        vrotY: (Math.random() - 0.5) * 16.0,
                        vrotZ: (Math.random() - 0.5) * 14.0,
                        width: sw,
                        height: sh,
                        depth: units.gu(0.4),
                        topColor: topClr,
                        edgeColor: edgeClr,
                        specular: isGoal,
                        alpha: 1.0,
                        decay: 1.2
                    });
                }

                var sparkCount = isGrand ? 16 : 10;
                for (var sp = 0; sp < sparkCount; sp++) {
                    var spAngle = Math.random() * Math.PI * 2.0;
                    var spSpeed = units.gu(14) + Math.random() * units.gu(18);
                    particles.push({
                        kind: "spark",
                        x: Math.cos(spAngle) * midR,
                        y: ringY,
                        z: Math.sin(spAngle) * midR,
                        vx: Math.cos(spAngle) * spSpeed,
                        vy: -units.gu(8 + Math.random() * 14),
                        vz: Math.sin(spAngle) * spSpeed,
                        size: units.gu(0.3 + Math.random() * 0.25),
                        color: isGoal ? "#FFFFFF" : (isSuper ? "#FFEAA7" : topClr),
                        alpha: 1.0,
                        decay: 2.2
                    });
                }

                for (var d = 0; d < 6; d++) {
                    var dustAngle = Math.random() * Math.PI * 2.0;
                    var dustR = midR + (Math.random() - 0.5) * units.gu(2.0);
                    particles.push({
                        kind: "dust",
                        x: Math.cos(dustAngle) * dustR,
                        y: ringY,
                        z: Math.sin(dustAngle) * dustR,
                        vx: Math.cos(dustAngle) * units.gu(3 + Math.random() * 4),
                        vy: -units.gu(1.5 + Math.random() * 3),
                        vz: Math.sin(dustAngle) * units.gu(3 + Math.random() * 4),
                        size: units.gu(0.6),
                        targetSize: units.gu(1.8 + Math.random() * 0.8),
                        color: topClr,
                        alpha: 0.65,
                        decay: 1.6
                    });
                }

                while (particles.length > 120) {
                    particles.shift();
                }
            }

            function spawnSegmentShatter(ringY, angle, topClr, edgeClr) {
                var midR = (outerRadius + innerRadius) / 2.0;
                for (var s = 0; s < 6; s++) {
                    var shardAngle = angle + (Math.random() - 0.5) * 0.45;
                    var radialSpeed = units.gu(7) + Math.random() * units.gu(10);
                    var sw = units.gu(1.0 + Math.random() * 0.6);
                    var sh = units.gu(0.8 + Math.random() * 0.6);
                    particles.push({
                        kind: "shard",
                        x: Math.cos(shardAngle) * midR,
                        y: ringY,
                        z: Math.sin(shardAngle) * midR,
                        vx: Math.cos(shardAngle) * radialSpeed,
                        vy: -units.gu(4 + Math.random() * 6),
                        vz: Math.sin(shardAngle) * radialSpeed,
                        rotX: Math.random() * Math.PI * 2.0,
                        rotY: Math.random() * Math.PI * 2.0,
                        rotZ: Math.random() * Math.PI * 2.0,
                        vrotX: (Math.random() - 0.5) * 12.0,
                        vrotY: (Math.random() - 0.5) * 14.0,
                        vrotZ: (Math.random() - 0.5) * 12.0,
                        width: sw,
                        height: sh,
                        depth: units.gu(0.4),
                        topColor: topClr,
                        edgeColor: edgeClr,
                        specular: false,
                        alpha: 1.0,
                        decay: 1.4
                    });
                }
                while (particles.length > 120) {
                    particles.shift();
                }
            }

            function generateRing() {
                var prevRing = rings.length > 0 ? rings[rings.length - 1] : null;
                rings.push(RingGen.createRing(nextRingIndex++, ringSpacing, prevRing));
            }

            function initGame(checkpointLevel) {
                var startLvl = checkpointLevel || 1;
                score = 0;
                streak = 0;
                towerAngle = 0.0;
                angularVelocity = 0.0;
                isDragging = false;
                rings = [];
                particles = [];
                ballTrail = [];
                squash = 1.0;
                squashVelocity = 0.0;
                isSuperFall = false;
                bannerText = "";
                bannerIsCheckpoint = false;
                bannerIsZone = false;
                bannerOpacity = 0.0;
                RingGen.resetGenerator();

                var startIndex = (startLvl - 1) * levelRings;
                nextRingIndex = startIndex;

                for (var i = 0; i < 14; i++) {
                    generateRing();
                }

                ballY = (startIndex + 1) * ringSpacing - units.gu(5.0);
                ballVy = 0.0;
                cameraY = (startIndex + 1) * ringSpacing;
                gameOver = false;
                isPaused = false;
                isSettingsOpen = false;
                wasPausedBeforeSettings = false;
                isStageClearOpen = false;
                lastPhysicsTime = 0.0;
                gameCanvas.requestPaint();
            }

            function continueDescent() {
                isStageClearOpen = false;
                streak = 0;
                isSuperFall = false;
                var currentDepth = Math.floor(ballY / ringSpacing);
                var speedScale = 1.0 + Math.min(0.35, currentDepth * 0.005);
                ballVy = -bounceSpeed * speedScale * 0.9;
                squash = 0.52;
                squashVelocity = (1.0 - squash) * 36.0;
                lastPhysicsTime = 0.0;
                soundManager.play("bounce");
                soundManager.buttonHaptic();
                gameCanvas.requestPaint();
            }

            function startGame() {
                startFromCheckpoint(selectedCheckpoint);
                isWelcomeOpen = false;
                soundManager.play("bounce");
                Storage.recordGamePlayed();
            }

            function goToMainMenu() {
                if (activePlayTimeAccumulator > 0.0) {
                    Storage.recordPlayTime(activePlayTimeAccumulator);
                    activePlayTimeAccumulator = 0.0;
                }
                Storage.flushPendingWrites();
                initGame(selectedCheckpoint);
                isWelcomeOpen = true;
            }

            onIsPausedChanged: {
                if (!isPaused) {
                    lastPhysicsTime = 0.0;
                } else {
                    if (activePlayTimeAccumulator > 0.0) {
                        Storage.recordPlayTime(activePlayTimeAccumulator);
                        activePlayTimeAccumulator = 0.0;
                    }
                    Storage.flushPendingWrites();
                }
            }

            Component.onCompleted: {
                var stats = Storage.loadStats();
                bestScore = stats.bestScore;
                totalRings = stats.totalRings;
                soundEnabled = stats.soundEnabled;
                hapticsEnabled = stats.hapticsEnabled;
                speedMode = stats.speedMode;
                themeMode = (stats.themeMode !== undefined) ? stats.themeMode : 0;
                highestLevelReached = stats.highestLevelReached;
                unlockedCheckpoints = stats.unlockedCheckpoints;
                selectedCheckpoint = stats.selectedCheckpoint;
                isWelcomeOpen = true;
                initGame(selectedCheckpoint);
            }

            Keys.onLeftPressed: {
                if (!gameOver && !isPaused && !isSettingsOpen && !isWelcomeOpen && !isStageClearOpen) {
                    towerAngle += 0.12;
                    gameCanvas.requestPaint();
                }
            }
            Keys.onRightPressed: {
                if (!gameOver && !isPaused && !isSettingsOpen && !isWelcomeOpen && !isStageClearOpen) {
                    towerAngle -= 0.12;
                    gameCanvas.requestPaint();
                }
            }
            Keys.onSpacePressed: {
                if (isWelcomeOpen) {
                    startGame();
                    return;
                }
                if (isSettingsOpen) {
                    return;
                }
                if (isStageClearOpen) {
                    if (stageClearIsGrand) {
                        goToMainMenu();
                    } else {
                        continueDescent();
                    }
                    return;
                }
                if (gameOver) {
                    startGame();
                } else {
                    isPaused = !isPaused;
                }
            }
            Keys.onEscapePressed: {
                if (isSettingsOpen) {
                    isSettingsOpen = false;
                    if (!wasPausedBeforeSettings && !gameOver && !isWelcomeOpen && !isStageClearOpen) {
                        isPaused = false;
                    }
                } else if (isStageClearOpen) {
                    goToMainMenu();
                } else if (!isWelcomeOpen && isPaused) {
                    isPaused = false;
                }
            }

            onIsSettingsOpenChanged: {
                if (!isSettingsOpen) {
                    lastPhysicsTime = 0.0;
                }
            }

            Timer {
                id: physicsTimer
                interval: 16
                repeat: true
                running: (!gameContainer.isPaused && !gameContainer.isSettingsOpen && !gameContainer.gameOver && !gameContainer.isStageClearOpen)

                onTriggered: {
                    if (gameContainer.isWelcomeOpen) {
                        gameContainer.towerAngle -= 0.005;
                        gameCanvas.requestPaint();
                        return;
                    }

                    if (gameContainer.gameOver || gameContainer.isPaused || gameContainer.isSettingsOpen) {
                        return;
                    }

                    var now = Date.now();
                    if (gameContainer.lastPhysicsTime <= 0) {
                        gameContainer.lastPhysicsTime = now;
                    }
                    var elapsedSec = (now - gameContainer.lastPhysicsTime) / 1000.0;
                    gameContainer.lastPhysicsTime = now;

                    var dt = Math.min(0.040, Math.max(0.008, elapsedSec));
                    var prevY = gameContainer.ballY;

                    gameContainer.activePlayTimeAccumulator += dt;
                    if (gameContainer.activePlayTimeAccumulator >= 5.0) {
                        Storage.recordPlayTime(gameContainer.activePlayTimeAccumulator);
                        gameContainer.activePlayTimeAccumulator = 0.0;
                    }

                    if (!gameContainer.isDragging && Math.abs(gameContainer.angularVelocity) > 0.0001) {
                        gameContainer.towerAngle += gameContainer.angularVelocity;
                        gameContainer.angularVelocity *= Math.pow(0.04, dt);
                    }

                    var currentDepth = Math.floor(gameContainer.ballY / gameContainer.ringSpacing);
                    var speedScale = 1.0 + Math.min(0.35, currentDepth * 0.005);
                    var effectiveGravity = gameContainer.gravity * speedScale;

                    gameContainer.ballVy += effectiveGravity * dt;
                    if (gameContainer.ballVy > gameContainer.maxFallSpeed) {
                        gameContainer.ballVy = gameContainer.maxFallSpeed;
                    }

                    gameContainer.isSuperFall = (gameContainer.streak >= 3 && gameContainer.ballVy > gameContainer.gravity * 0.35);

                    var nextY = gameContainer.ballY + gameContainer.ballVy * dt;

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
                                var effectiveAngle = gameContainer.towerAngle + (ring.angleOffset || 0.0);
                                var relAngle = ((Math.PI / 2.0 - effectiveAngle) % (2.0 * Math.PI));
                                if (relAngle < 0) {
                                    relAngle += 2.0 * Math.PI;
                                }

                                var segmentIdx = Math.floor(relAngle / (Math.PI / 4.0));
                                if (segmentIdx < 0) segmentIdx = 0;
                                if (segmentIdx > 7) segmentIdx = 7;

                                var segType = ring.segments[segmentIdx];

                                if (ring.isGoal) {
                                    ring.broken = true;
                                    var isGrand = ring.isGrandGoal || (gameContainer.currentLevel >= 100);
                                    var nextLvl = gameContainer.currentLevel + 1;
                                    var isZone = (nextLvl % 10 === 1 && nextLvl > 1);
                                    var isCp = gameContainer.isCheckpointLevel(nextLvl);

                                    gameContainer.bannerIsCheckpoint = isCp;
                                    gameContainer.bannerIsZone = isZone;

                                    if (isGrand) {
                                        gameContainer.spawnShatterDebris(ring.y, true, true, gameContainer.currentTheme, false);
                                        gameContainer.score += 1000;
                                        gameContainer.bannerText = i18n.tr("TOWER CONQUERED! 100 LEVELS COMPLETE!");
                                        Storage.saveStat("gameCleared", "1");
                                        soundManager.milestoneHaptic();
                                    } else if (isZone) {
                                        gameContainer.spawnShatterDebris(ring.y, true, false, gameContainer.currentTheme, false);
                                        gameContainer.score += 250;
                                        gameContainer.bannerText = i18n.tr("ZONE %1 ENTERED!").arg(Math.floor((nextLvl - 1) / 10) + 1);
                                        soundManager.milestoneHaptic();
                                    } else if (isCp) {
                                        gameContainer.spawnShatterDebris(ring.y, true, false, gameContainer.currentTheme, false);
                                        gameContainer.score += 150;
                                        gameContainer.bannerText = i18n.tr("CHECKPOINT STAGE %1!").arg(nextLvl);
                                        soundManager.milestoneHaptic();
                                    } else {
                                        gameContainer.spawnShatterDebris(ring.y, true, false, gameContainer.currentTheme, false);
                                        gameContainer.score += 100;
                                        gameContainer.bannerText = i18n.tr("LEVEL %1 COMPLETE!").arg(gameContainer.currentLevel);
                                        soundManager.haptic(true);
                                    }
                                    gameContainer.bannerOpacity = 1.0;
                                    soundManager.play("smash");

                                    var earned = isGrand ? 1000 : (isZone ? 250 : (isCp ? 150 : 100));
                                    var currentStreak = gameContainer.streak;
                                    gameContainer.streak = 0;
                                    gameContainer.isSuperFall = false;
                                    gameContainer.totalRings++;
                                    Storage.recordStageCompleted(earned);
                                    Storage.queueStat("totalRings", gameContainer.totalRings);
                                    Storage.queueStat("totalRingsSmashed", gameContainer.totalRings);

                                    gameContainer.ballY = ring.y;
                                    gameContainer.ballVy = 0.0;
                                    gameContainer.cameraY = ring.y;
                                    gameContainer.squash = 0.45;
                                    gameContainer.squashVelocity = (1.0 - gameContainer.squash) * 40.0;
                                    nextY = ring.y;

                                    var nextLvl = gameContainer.currentLevel + 1;
                                    if (nextLvl > gameContainer.highestLevelReached) {
                                        gameContainer.highestLevelReached = nextLvl;
                                        Storage.saveHighestLevel(nextLvl);
                                    }
                                    if (gameContainer.isCheckpointLevel(nextLvl)) {
                                        gameContainer.unlockCheckpoint(nextLvl);
                                    }

                                    if (gameContainer.score > gameContainer.bestScore) {
                                        gameContainer.bestScore = gameContainer.score;
                                        Storage.queueStat("bestScore", gameContainer.bestScore);
                                    }
                                    if (gameContainer.activePlayTimeAccumulator > 0.0) {
                                        Storage.recordPlayTime(gameContainer.activePlayTimeAccumulator);
                                        gameContainer.activePlayTimeAccumulator = 0.0;
                                    }
                                    Storage.flushPendingWrites();

                                    gameContainer.stageClearStage = gameContainer.currentLevel;
                                    gameContainer.stageClearBonus = earned;
                                    gameContainer.stageClearStreak = currentStreak;
                                    gameContainer.stageClearIsCheckpoint = isCp;
                                    gameContainer.stageClearNextCheckpoint = nextLvl;
                                    gameContainer.stageClearIsGrand = isGrand;
                                    gameContainer.isStageClearOpen = true;
                                    gameCanvas.requestPaint();
                                    break;
                                }

                                if (gameContainer.isSuperFall && segType !== 1) {
                                    ring.broken = true;
                                    gameContainer.spawnShatterDebris(ring.y, false, false, gameContainer.currentTheme, true);
                                    soundManager.play("smash");
                                    soundManager.haptic(true);

                                    gameContainer.score += 25;
                                    gameContainer.streak = 0;
                                    gameContainer.isSuperFall = false;
                                    gameContainer.totalRings++;
                                    Storage.queueStat("totalRings", gameContainer.totalRings);
                                    Storage.queueStat("totalRingsSmashed", gameContainer.totalRings);

                                    gameContainer.ballY = ring.y;
                                    gameContainer.ballVy = -gameContainer.bounceSpeed * speedScale;
                                    gameContainer.squash = 0.48;
                                    gameContainer.squashVelocity = (1.0 - gameContainer.squash) * 38.0;
                                    nextY = ring.y;

                                    if (gameContainer.score > gameContainer.bestScore) {
                                        gameContainer.bestScore = gameContainer.score;
                                        Storage.queueStat("bestScore", gameContainer.bestScore);
                                    }
                                    break;
                                }

                                if (segType === 0 || segType === 3) {
                                    gameContainer.ballY = ring.y;
                                    gameContainer.ballVy = -gameContainer.bounceSpeed * speedScale;
                                    gameContainer.streak = 0;
                                    gameContainer.isSuperFall = false;
                                    gameContainer.squash = 0.54;
                                    gameContainer.squashVelocity = (1.0 - gameContainer.squash) * 36.0;
                                    nextY = ring.y;

                                    if (segType === 3) {
                                        ring.segments[segmentIdx] = 1;
                                        gameContainer.spawnSegmentShatter(ring.y, relAngle, gameContainer.currentTheme.topSafe, gameContainer.currentTheme.sideSafe);
                                        soundManager.play("smash");
                                    } else {
                                        soundManager.play("bounce");
                                    }
                                    soundManager.haptic(false);

                                    ring.recoil = units.gu(0.42);
                                    ring.recoilVelocity = units.gu(4.2);

                                    if (!ring.shockwaves) ring.shockwaves = [];
                                    ring.shockwaves.push({
                                        angle: relAngle,
                                        radius: units.gu(0.5),
                                        maxRadius: units.gu(4.5),
                                        speed: units.gu(26.0),
                                        alpha: 0.85,
                                        maxAlpha: 0.85
                                    });

                                    if (!ring.splats) ring.splats = [];
                                    var droplets = [];
                                    var dropCount = 4 + Math.floor(Math.random() * 3);
                                    for (var d = 0; d < dropCount; d++) {
                                        var dAngle = Math.random() * Math.PI * 2.0;
                                        var dDist = units.gu(1.8 + Math.random() * 1.5);
                                        droplets.push({
                                            dx: Math.cos(dAngle) * dDist,
                                            dy: Math.sin(dAngle) * dDist,
                                            radius: units.gu(0.22 + Math.random() * 0.3)
                                        });
                                    }
                                    ring.splats.push({
                                        angle: relAngle,
                                        radius: units.gu(0.4),
                                        targetRadius: units.gu(1.6 + Math.random() * 0.7),
                                        growthSpeed: units.gu(20.0),
                                        droplets: droplets,
                                        dropletScale: 0.1
                                    });

                                    var theme = gameContainer.currentTheme;
                                    gameContainer.spawnBounceDust(ring.y, theme.ballMid, theme.ballLight);
                                    break;
                                } else if (segType === 2) {
                                    gameContainer.ballY = ring.y;
                                    gameContainer.ballVy = 0;
                                    gameContainer.gameOver = true;
                                    gameContainer.isSuperFall = false;
                                    soundManager.play("gameover");
                                    soundManager.haptic(true);
                                    gameContainer.spawnParticles(0, ring.y, 24, gameContainer.currentTheme.topHazard, 1.4);

                                    if (gameContainer.score > gameContainer.bestScore) {
                                        gameContainer.bestScore = gameContainer.score;
                                        Storage.queueStat("bestScore", gameContainer.bestScore);
                                    }
                                    if (gameContainer.activePlayTimeAccumulator > 0.0) {
                                        Storage.recordPlayTime(gameContainer.activePlayTimeAccumulator);
                                        gameContainer.activePlayTimeAccumulator = 0.0;
                                    }
                                    Storage.flushPendingWrites();
                                    gameCanvas.requestPaint();
                                    return;
                                } else if (segType === 1) {
                                    if (!ring.passed) {
                                        ring.passed = true;
                                        gameContainer.streak++;
                                        gameContainer.score += gameContainer.streak;
                                        gameContainer.totalRings++;
                                        soundManager.play("pass");

                                        if (gameContainer.streak >= 3) {
                                             soundManager.haptic(true);
                                             if (gameContainer.ballVy > gameContainer.gravity * 0.35) {
                                                 gameContainer.isSuperFall = true;
                                             }
                                        }

                                        if (gameContainer.score > gameContainer.bestScore) {
                                             gameContainer.bestScore = gameContainer.score;
                                             Storage.queueStat("bestScore", gameContainer.bestScore);
                                        }
                                        Storage.queueStat("totalRings", gameContainer.totalRings);
                                        Storage.queueStat("totalRingsSmashed", gameContainer.totalRings);
                                        Storage.recordComboStreak(gameContainer.streak);
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

                    var squashSpringK = 360.0;
                    var squashDamping = 22.0;
                    var squashForce = -squashSpringK * (gameContainer.squash - 1.0) - squashDamping * gameContainer.squashVelocity;
                    gameContainer.squashVelocity += squashForce * dt;
                    gameContainer.squash += gameContainer.squashVelocity * dt;
                    if (Math.abs(gameContainer.squash - 1.0) < 0.002 && Math.abs(gameContainer.squashVelocity) < 0.005) {
                        gameContainer.squash = 1.0;
                        gameContainer.squashVelocity = 0.0;
                    }

                    for (var rIdx = 0; rIdx < gameContainer.rings.length; rIdx++) {
                        var rObj = gameContainer.rings[rIdx];
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

                    for (var p = gameContainer.particles.length - 1; p >= 0; p--) {
                        var pt = gameContainer.particles[p];
                        pt.x += (pt.vx || 0) * dt;
                        pt.y += (pt.vy || 0) * dt;
                        pt.z += (pt.vz || 0) * dt;

                        if (pt.kind === "shockwave") {
                            pt.radius += (pt.speed || units.gu(30.0)) * dt;
                        } else if (pt.kind === "dust") {
                            if (pt.size < pt.targetSize) {
                                pt.size = Math.min(pt.targetSize, pt.size + dt * units.gu(4.0));
                            }
                        } else {
                            pt.vy += gameContainer.gravity * 0.7 * dt;
                            pt.vx *= Math.pow(0.86, dt);
                            pt.vz *= Math.pow(0.86, dt);

                            if (pt.vrotX) pt.rotX = (pt.rotX || 0) + pt.vrotX * dt;
                            if (pt.vrotY) pt.rotY = (pt.rotY || 0) + pt.vrotY * dt;
                            if (pt.vrotZ) pt.rotZ = (pt.rotZ || 0) + pt.vrotZ * dt;
                        }

                        pt.alpha -= dt * (pt.decay || 1.6);
                        if (pt.alpha <= 0.01 || (pt.kind === "shockwave" && pt.radius >= pt.maxRadius)) {
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

            GameCanvas {
                id: gameCanvas
                game: gameContainer
            }

            MouseArea {
                id: dragArea
                anchors.fill: parent
                enabled: !gameContainer.gameOver && !gameContainer.isPaused && !gameContainer.isSettingsOpen && !gameContainer.isWelcomeOpen && !gameContainer.isStageClearOpen

                onPressed: {
                    gameContainer.isDragging = true;
                    gameContainer.angularVelocity = 0.0;
                    gameContainer.lastDragX = mouse.x;
                    gameContainer.lastDragTime = Date.now();
                }

                onPositionChanged: {
                    if (pressed && !gameContainer.gameOver && !gameContainer.isPaused && !gameContainer.isSettingsOpen && !gameContainer.isWelcomeOpen && !gameContainer.isStageClearOpen) {
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

            GameHud {
                visible: !gameContainer.isWelcomeOpen
                anchors.top: parent.top
                anchors.topMargin: units.gu(1.2)
                anchors.horizontalCenter: parent.horizontalCenter
                score: gameContainer.score
                bestScore: gameContainer.bestScore
                currentLevel: gameContainer.currentLevel
                levelProgress: gameContainer.levelProgress
                streak: gameContainer.streak
                isSuperFall: gameContainer.isSuperFall
                theme: gameContainer.currentTheme
            }

            MilestoneBanner {
                text: gameContainer.bannerText
                isCheckpoint: gameContainer.bannerIsCheckpoint
                isZoneTransition: gameContainer.bannerIsZone
                bannerOpacity: gameContainer.bannerOpacity
                theme: gameContainer.currentTheme
            }

            Loader {
                id: welcomeScreenLoader
                anchors.fill: parent
                z: 150
                active: gameContainer.isWelcomeOpen
                visible: active
                sourceComponent: Component {
                    WelcomeScreen {
                        anchors.fill: parent
                        visible: true
                        bestScore: gameContainer.bestScore
                        totalRings: gameContainer.totalRings
                        speedMode: gameContainer.speedMode
                        selectedCheckpoint: gameContainer.selectedCheckpoint
                        unlockedCheckpoints: gameContainer.unlockedCheckpoints
                        theme: gameContainer.currentTheme
                        themeName: Themes.getThemeName(gameContainer.themeMode, gameContainer.currentLevel)
                        onCheckpointSelected: {
                            soundManager.buttonHaptic();
                            gameContainer.selectedCheckpoint = checkpoint;
                            Storage.saveSelectedCheckpoint(checkpoint);
                        }
                        onPlayRequested: {
                            soundManager.buttonHaptic();
                            gameContainer.startGame();
                        }
                        onSettingsRequested: {
                            soundManager.buttonHaptic();
                            gameContainer.wasPausedBeforeSettings = false;
                            gameContainer.isSettingsOpen = true;
                        }
                        onThemeCycleRequested: {
                            soundManager.buttonHaptic();
                            gameContainer.themeMode = (gameContainer.themeMode + 1) % Themes.themeOptions.length;
                            Storage.saveStat("themeMode", gameContainer.themeMode.toString());
                            gameCanvas.requestPaint();
                        }
                        onSpeedCycleRequested: {
                            soundManager.buttonHaptic();
                            gameContainer.speedMode = (gameContainer.speedMode + 1) % 3;
                            Storage.saveStat("speedMode", gameContainer.speedMode.toString());
                        }
                    }
                }
            }

            Loader {
                id: pauseModalLoader
                anchors.fill: parent
                z: 200
                active: gameContainer.isPaused && !gameContainer.isSettingsOpen && !gameContainer.gameOver && !gameContainer.isWelcomeOpen
                visible: active
                sourceComponent: Component {
                    PauseModal {
                        anchors.fill: parent
                        visible: true
                        soundEnabled: gameContainer.soundEnabled
                        hapticsEnabled: gameContainer.hapticsEnabled
                        speedMode: gameContainer.speedMode
                        currentCheckpoint: gameContainer.getNearestCheckpoint(gameContainer.currentLevel)
                        theme: gameContainer.currentTheme
                        onResumeRequested: {
                            soundManager.buttonHaptic();
                            gameContainer.isPaused = false;
                        }
                        onRestartCheckpointRequested: {
                            soundManager.buttonHaptic();
                            gameContainer.startFromCheckpoint(gameContainer.getNearestCheckpoint(gameContainer.currentLevel));
                            soundManager.play("bounce");
                        }
                        onRestartRequested: {
                            soundManager.buttonHaptic();
                            gameContainer.startFromCheckpoint(1);
                            soundManager.play("bounce");
                        }
                        onMainMenuRequested: {
                            soundManager.buttonHaptic();
                            gameContainer.goToMainMenu();
                        }
                        onToggleSoundRequested: {
                            soundManager.buttonHaptic();
                            gameContainer.soundEnabled = !gameContainer.soundEnabled;
                            Storage.saveStat("soundEnabled", gameContainer.soundEnabled ? "1" : "0");
                        }
                        onToggleHapticsRequested: {
                            soundManager.buttonHaptic();
                            gameContainer.hapticsEnabled = !gameContainer.hapticsEnabled;
                            Storage.saveStat("hapticsEnabled", gameContainer.hapticsEnabled ? "1" : "0");
                        }
                        onSpeedModeSelected: {
                            soundManager.buttonHaptic();
                            gameContainer.speedMode = newMode;
                            Storage.saveStat("speedMode", newMode.toString());
                        }
                    }
                }
            }

            Loader {
                id: settingsModalLoader
                anchors.fill: parent
                z: 250
                active: gameContainer.isSettingsOpen
                visible: active
                sourceComponent: Component {
                    SettingsModal {
                        anchors.fill: parent
                        visible: true
                        soundEnabled: gameContainer.soundEnabled
                        hapticsEnabled: gameContainer.hapticsEnabled
                        speedMode: gameContainer.speedMode
                        themeMode: gameContainer.themeMode
                        bestScore: gameContainer.bestScore
                        totalRings: gameContainer.totalRings
                        theme: gameContainer.currentTheme
                        onCloseRequested: {
                            soundManager.buttonHaptic();
                            gameContainer.isSettingsOpen = false;
                            if (!gameContainer.wasPausedBeforeSettings && !gameContainer.gameOver && !gameContainer.isWelcomeOpen) {
                                gameContainer.isPaused = false;
                            }
                        }
                        onToggleSoundRequested: {
                            soundManager.buttonHaptic();
                            gameContainer.soundEnabled = !gameContainer.soundEnabled;
                            Storage.saveStat("soundEnabled", gameContainer.soundEnabled ? "1" : "0");
                        }
                        onToggleHapticsRequested: {
                            soundManager.buttonHaptic();
                            gameContainer.hapticsEnabled = !gameContainer.hapticsEnabled;
                            Storage.saveStat("hapticsEnabled", gameContainer.hapticsEnabled ? "1" : "0");
                        }
                        onSpeedModeSelected: {
                            soundManager.buttonHaptic();
                            gameContainer.speedMode = newMode;
                            Storage.saveStat("speedMode", newMode.toString());
                        }
                        onThemeModeSelected: {
                            soundManager.buttonHaptic();
                            gameContainer.themeMode = newMode;
                            Storage.saveStat("themeMode", newMode.toString());
                            gameCanvas.requestPaint();
                        }
                    }
                }
            }

            Loader {
                id: gameOverModalLoader
                anchors.fill: parent
                z: 200
                active: gameContainer.gameOver && !gameContainer.isSettingsOpen && !gameContainer.isWelcomeOpen
                visible: active
                sourceComponent: Component {
                    GameOverModal {
                        anchors.fill: parent
                        visible: true
                        score: gameContainer.score
                        bestScore: gameContainer.bestScore
                        levelReached: gameContainer.currentLevel
                        checkpointLevel: gameContainer.getNearestCheckpoint(gameContainer.currentLevel)
                        theme: gameContainer.currentTheme
                        onContinueCheckpointRequested: {
                            soundManager.buttonHaptic();
                            gameContainer.startFromCheckpoint(gameContainer.getNearestCheckpoint(gameContainer.currentLevel));
                            soundManager.play("bounce");
                        }
                        onRestartRequested: {
                            soundManager.buttonHaptic();
                            gameContainer.startFromCheckpoint(1);
                            soundManager.play("bounce");
                        }
                        onMainMenuRequested: {
                            soundManager.buttonHaptic();
                            gameContainer.goToMainMenu();
                        }
                    }
                }
            }

            Loader {
                id: stageClearModalLoader
                anchors.fill: parent
                z: 220
                active: gameContainer.isStageClearOpen && !gameContainer.isSettingsOpen && !gameContainer.isWelcomeOpen
                visible: active
                sourceComponent: Component {
                    StageClearModal {
                        anchors.fill: parent
                        visible: true
                        stageNumber: gameContainer.stageClearStage
                        score: gameContainer.score
                        bonusPoints: gameContainer.stageClearBonus
                        streak: gameContainer.stageClearStreak
                        isCheckpoint: gameContainer.stageClearIsCheckpoint
                        nextCheckpoint: gameContainer.stageClearNextCheckpoint
                        isGrandVictory: gameContainer.stageClearIsGrand
                        theme: gameContainer.currentTheme
                        onContinueRequested: {
                            if (gameContainer.stageClearIsGrand) {
                                gameContainer.goToMainMenu();
                            } else {
                                gameContainer.continueDescent();
                            }
                        }
                        onMainMenuRequested: {
                            soundManager.buttonHaptic();
                            gameContainer.isStageClearOpen = false;
                            gameContainer.goToMainMenu();
                        }
                    }
                }
            }
        }
    }
}
