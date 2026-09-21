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
        screenSaverEnabled: gameContainer.gameOver || gameContainer.isPaused
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
            subtitle: i18n.tr("Level %1").arg(gameContainer.currentLevel)
            z: 100
            visible: true

            trailingActionBar.actions: [
                Action {
                    iconName: gameContainer.isPaused ? "media-playback-start" : "media-playback-pause"
                    text: gameContainer.isPaused ? i18n.tr("Resume") : i18n.tr("Pause")
                    onTriggered: {
                        if (!gameContainer.gameOver) {
                            soundManager.buttonHaptic();
                            gameContainer.isPaused = !gameContainer.isPaused;
                        }
                    }
                },
                Action {
                    iconName: gameContainer.soundEnabled ? "audio-volume-high" : "audio-volume-muted"
                    text: gameContainer.soundEnabled ? i18n.tr("Sound") : i18n.tr("Muted")
                    onTriggered: {
                        soundManager.buttonHaptic();
                        gameContainer.soundEnabled = !gameContainer.soundEnabled;
                        Storage.saveStat("soundEnabled", gameContainer.soundEnabled ? "1" : "0");
                    }
                },
                Action {
                    iconName: "view-refresh"
                    text: i18n.tr("Restart")
                    onTriggered: {
                        soundManager.buttonHaptic();
                        gameContainer.initGame();
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
                color: "#223142"
                z: 50
            }

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
            property real bannerOpacity: 0.0

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

            function generateRing() {
                rings.push(RingGen.createRing(nextRingIndex++, ringSpacing));
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
                squashVelocity = 0.0;
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
                lastPhysicsTime = 0.0;
                gameCanvas.requestPaint();
            }

            onIsPausedChanged: {
                if (!isPaused) {
                    lastPhysicsTime = 0.0;
                }
            }

            Component.onCompleted: {
                var stats = Storage.loadStats();
                bestScore = stats.bestScore;
                totalRings = stats.totalRings;
                soundEnabled = stats.soundEnabled;
                hapticsEnabled = stats.hapticsEnabled;
                speedMode = stats.speedMode;
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
                    var now = Date.now();
                    if (gameContainer.lastPhysicsTime <= 0) {
                        gameContainer.lastPhysicsTime = now;
                    }
                    var elapsedSec = (now - gameContainer.lastPhysicsTime) / 1000.0;
                    gameContainer.lastPhysicsTime = now;

                    var dt = Math.min(0.040, Math.max(0.008, elapsedSec));
                    var prevY = gameContainer.ballY;

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
                                    soundManager.play("smash");
                                    soundManager.haptic(true);

                                    gameContainer.score += 100;
                                    gameContainer.streak = 0;
                                    gameContainer.isSuperFall = false;
                                    gameContainer.totalRings++;
                                    Storage.saveStat("totalRings", gameContainer.totalRings);

                                    gameContainer.ballY = ring.y;
                                    gameContainer.ballVy = -gameContainer.bounceSpeed * speedScale * 1.1;
                                    gameContainer.squash = 0.45;
                                    gameContainer.squashVelocity = (1.0 - gameContainer.squash) * 40.0;
                                    nextY = ring.y;

                                    gameContainer.bannerText = i18n.tr("LEVEL %1 COMPLETE!").arg(gameContainer.currentLevel);
                                    gameContainer.bannerOpacity = 1.0;

                                    if (gameContainer.score > gameContainer.bestScore) {
                                        gameContainer.bestScore = gameContainer.score;
                                        Storage.saveStat("bestScore", gameContainer.bestScore);
                                    }
                                    break;
                                }

                                if (gameContainer.isSuperFall && segType !== 1) {
                                    ring.broken = true;
                                    gameContainer.spawnParticles(0, ring.y, 35, "#ff9f43", 2.0);
                                    gameContainer.spawnParticles(0, ring.y, 15, "#ff5252", 1.6);
                                    soundManager.play("smash");
                                    soundManager.haptic(true);

                                    gameContainer.score += 25;
                                    gameContainer.streak = 0;
                                    gameContainer.isSuperFall = false;
                                    gameContainer.totalRings++;
                                    Storage.saveStat("totalRings", gameContainer.totalRings);

                                    gameContainer.ballY = ring.y;
                                    gameContainer.ballVy = -gameContainer.bounceSpeed * speedScale;
                                    gameContainer.squash = 0.48;
                                    gameContainer.squashVelocity = (1.0 - gameContainer.squash) * 38.0;
                                    nextY = ring.y;

                                    if (gameContainer.score > gameContainer.bestScore) {
                                        gameContainer.bestScore = gameContainer.score;
                                        Storage.saveStat("bestScore", gameContainer.bestScore);
                                    }
                                    break;
                                }

                                if (segType === 0) {
                                    gameContainer.ballY = ring.y;
                                    gameContainer.ballVy = -gameContainer.bounceSpeed * speedScale;
                                    gameContainer.streak = 0;
                                    gameContainer.isSuperFall = false;
                                    gameContainer.squash = 0.54;
                                    gameContainer.squashVelocity = (1.0 - gameContainer.squash) * 36.0;
                                    nextY = ring.y;

                                    soundManager.play("bounce");
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

                                    var theme = Themes.getTheme(gameContainer.currentLevel);
                                    gameContainer.spawnBounceDust(ring.y, theme.ballMid, theme.ballLight);
                                    break;
                                } else if (segType === 2) {
                                    gameContainer.ballY = ring.y;
                                    gameContainer.ballVy = 0;
                                    gameContainer.gameOver = true;
                                    gameContainer.isSuperFall = false;
                                    soundManager.play("gameover");
                                    soundManager.haptic(true);
                                    gameContainer.spawnParticles(0, ring.y, 24, "#ff4757", 1.4);

                                    if (gameContainer.score > gameContainer.bestScore) {
                                        gameContainer.bestScore = gameContainer.score;
                                        Storage.saveStat("bestScore", gameContainer.bestScore);
                                    }
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
                                            Storage.saveStat("bestScore", gameContainer.bestScore);
                                        }
                                        Storage.saveStat("totalRings", gameContainer.totalRings);
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

            GameCanvas {
                id: gameCanvas
                game: gameContainer
            }

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

            GameHud {
                anchors.top: parent.top
                anchors.topMargin: units.gu(1.2)
                anchors.horizontalCenter: parent.horizontalCenter
                score: gameContainer.score
                bestScore: gameContainer.bestScore
                currentLevel: gameContainer.currentLevel
                levelProgress: gameContainer.levelProgress
                streak: gameContainer.streak
                isSuperFall: gameContainer.isSuperFall
            }

            MilestoneBanner {
                text: gameContainer.bannerText
                bannerOpacity: gameContainer.bannerOpacity
            }

            PauseModal {
                visible: gameContainer.isPaused && !gameContainer.gameOver
                soundEnabled: gameContainer.soundEnabled
                hapticsEnabled: gameContainer.hapticsEnabled
                speedMode: gameContainer.speedMode
                onResumeRequested: {
                    soundManager.buttonHaptic();
                    gameContainer.isPaused = false;
                }
                onRestartRequested: {
                    soundManager.buttonHaptic();
                    gameContainer.initGame();
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

            GameOverModal {
                visible: gameContainer.gameOver
                score: gameContainer.score
                bestScore: gameContainer.bestScore
                levelReached: gameContainer.currentLevel
                onRestartRequested: {
                    soundManager.buttonHaptic();
                    gameContainer.initGame();
                }
            }
        }
    }
}
