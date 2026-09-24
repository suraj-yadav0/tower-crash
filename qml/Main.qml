import QtQuick 2.9
import Lomiri.Components 1.3
import QtSystemInfo 5.0
import "components"
import "js/Themes.js" as Themes
import "js/Storage.js" as Storage
import "js/RingGenerator.js" as RingGen
import "js/ParticleSystem.js" as Particles
import "js/Progression.js" as Progression
import "js/GamePhysics.js" as GamePhysics

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
        volume: gameContainer.soundVolume
        hapticsEnabled: gameContainer.hapticsEnabled
    }

    Page {
        id: mainPage
        anchors.fill: parent

        header: GameHeader {
            id: pageHeader
            game: gameContainer
            soundManager: soundManager
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

            GameBackground {
                id: gameBackground
                currentTheme: gameContainer.currentTheme
                previousTheme: gameContainer.previousTheme
                themeTransitionProgress: gameContainer.themeTransitionProgress
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
            property bool isStageClearCelebrating: false
            property real milestoneRingY: 0.0
            property int stageClearStage: 1
            property int stageClearBonus: 100
            property int stageClearStreak: 0
            property bool stageClearIsCheckpoint: false
            property int stageClearNextCheckpoint: 1
            property bool stageClearIsGrand: false

            property bool soundEnabled: true
            property real soundVolume: 0.85
            property bool hapticsEnabled: true
            property real touchSensitivityMultiplier: 1.0
            property int themeMode: 0
            property var previousTheme: null
            property real themeTransitionProgress: 1.0
            property var currentTheme: Themes.getTheme(themeMode, currentLevel)
            onCurrentThemeChanged: {
                if (previousTheme && previousTheme.id !== currentTheme.id) {
                    themeTransitionProgress = 0.0;
                    themeTransitionAnim.restart();
                } else {
                    themeTransitionProgress = 1.0;
                }
                previousTheme = currentTheme;
                gameCanvas.requestPaint();
            }

            NumberAnimation {
                id: themeTransitionAnim
                target: gameContainer
                property: "themeTransitionProgress"
                from: 0.0
                to: 1.0
                duration: 450
                easing.type: Easing.InOutQuad
            }

            property real towerAngle: 0.0
            property real angularVelocity: 0.0
            property bool isDragging: false
            property real lastDragX: 0.0
            property real lastDragTime: 0.0

            property real ballY: 0.0
            property real ballVy: 0.0
            property real cameraY: 0.0
            property real activePlatformY: 0.0
            property real squash: 1.0
            property real squashVelocity: 0.0
            property bool isSuperFall: false

            property real ringSpacing: units.gu(26)
            property real outerRadius: units.gu(20)
            property real innerRadius: units.gu(4.8)
            property real poleRadius: units.gu(4.8)
            property real ballRadius: units.gu(2.4)
            property real ringHeight: units.gu(2.8)
            property real tiltRatio: 0.34

            property int speedMode: 1
            property real speedMultiplier: {
                if (speedMode === 0) return 0.78;
                if (speedMode === 2) return 1.20;
                return 1.0;
            }

            property real baseGravity: units.gu(260)
            property real baseBounceSpeed: units.gu(77)
            property real baseMaxFallSpeed: units.gu(180)

            property real gravity: baseGravity * speedMultiplier
            property real bounceSpeed: baseBounceSpeed * Math.sqrt(speedMultiplier)
            property real maxFallSpeed: baseMaxFallSpeed * speedMultiplier
            property real lastPhysicsTime: 0.0

            property real ballScreenY: units.gu(28.0)
            property var rings: []
            property int nextRingIndex: 0
            property var particles: []
            property var ballTrail: []

            property int levelRings: 20
            property int currentLevel: Progression.calculateLevel(ballY, ringSpacing, levelRings, units.gu(2))
            property real levelProgress: Progression.calculateLevelProgress(ballY, currentLevel, ringSpacing, levelRings)
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
                return Progression.isCheckpointLevel(lvl);
            }

            function getNearestCheckpoint(lvl) {
                return Progression.getNearestCheckpoint(lvl, unlockedCheckpoints);
            }

            function unlockCheckpoint(lvl) {
                var updated = Progression.unlockCheckpoint(lvl, unlockedCheckpoints);
                if (updated.length !== unlockedCheckpoints.length) {
                    unlockedCheckpoints = updated;
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
                Particles.spawnParticles(particles, units, outerRadius, innerRadius, x, y, count, color, speedMultiplier);
            }

            function spawnBounceDust(y, color1, color2) {
                Particles.spawnBounceDust(particles, units, outerRadius, innerRadius, y, color1, color2);
            }

            function spawnShatterDebris(ringY, isGoal, isGrand, theme, isSuper) {
                Particles.spawnShatterDebris(particles, units, outerRadius, innerRadius, ringY, isGoal, isGrand, theme, isSuper);
            }

            function spawnSegmentShatter(ringY, angle, topClr, edgeClr) {
                Particles.spawnSegmentShatter(particles, units, outerRadius, innerRadius, ringY, angle, topClr, edgeClr);
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

                ballY = (startIndex + 1) * ringSpacing - units.gu(7.0);
                ballVy = 0.0;
                cameraY = (startIndex + 1) * ringSpacing;
                activePlatformY = (startIndex + 1) * ringSpacing;
                gameOver = false;
                isPaused = false;
                isSettingsOpen = false;
                wasPausedBeforeSettings = false;
                isStageClearOpen = false;
                isStageClearCelebrating = false;
                stageClearIntermissionTimer.stop();
                lastPhysicsTime = 0.0;
                gameCanvas.requestPaint();
            }

            function continueDescent() {
                stageClearIntermissionTimer.stop();
                isStageClearCelebrating = false;
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
                stageClearIntermissionTimer.stop();
                isStageClearCelebrating = false;
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

            Connections {
                target: Qt.application
                function onStateChanged() {
                    if (Qt.application.state !== Qt.ApplicationActive) {
                        if (!gameContainer.isWelcomeOpen && !gameContainer.gameOver && !gameContainer.isStageClearOpen && !gameContainer.isStageClearCelebrating) {
                            gameContainer.isPaused = true;
                        } else {
                            if (gameContainer.activePlayTimeAccumulator > 0.0) {
                                Storage.recordPlayTime(gameContainer.activePlayTimeAccumulator);
                                gameContainer.activePlayTimeAccumulator = 0.0;
                            }
                            Storage.flushPendingWrites();
                        }
                    }
                }
            }

            Component.onCompleted: {
                var stats = Storage.loadStats();
                bestScore = stats.bestScore;
                totalRings = stats.totalRings;
                soundEnabled = stats.soundEnabled;
                soundVolume = (stats.soundVolume !== undefined) ? stats.soundVolume : 0.85;
                hapticsEnabled = stats.hapticsEnabled;
                touchSensitivityMultiplier = (stats.touchSensitivityMultiplier !== undefined) ? stats.touchSensitivityMultiplier : 1.0;
                speedMode = stats.speedMode;
                themeMode = (stats.themeMode !== undefined) ? stats.themeMode : 0;
                previousTheme = currentTheme;
                highestLevelReached = stats.highestLevelReached;
                unlockedCheckpoints = stats.unlockedCheckpoints;
                selectedCheckpoint = stats.selectedCheckpoint;
                isWelcomeOpen = true;
                initGame(selectedCheckpoint);
            }

            Keys.forwardTo: [gameController]

            onIsSettingsOpenChanged: {
                if (!isSettingsOpen) {
                    lastPhysicsTime = 0.0;
                }
            }

            Timer {
                id: stageClearIntermissionTimer
                interval: 1000
                repeat: false
                onTriggered: {
                    if (!gameContainer.gameOver && !gameContainer.isWelcomeOpen && !gameContainer.isPaused) {
                        gameContainer.isStageClearCelebrating = false;
                        gameContainer.ballY = gameContainer.milestoneRingY;
                        gameContainer.ballVy = 0.0;
                        gameContainer.cameraY = gameContainer.milestoneRingY;
                        gameContainer.activePlatformY = gameContainer.milestoneRingY;
                        gameContainer.isStageClearOpen = true;
                        gameCanvas.requestPaint();
                    }
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
                    if (gameContainer.isStageClearCelebrating) {
                        dt *= 0.38;
                    }
                    GamePhysics.updatePhysicsStep(
                        gameContainer,
                        dt,
                        soundManager,
                        stageClearIntermissionTimer,
                        units,
                        Storage,
                        Progression,
                        i18n,
                        Particles
                    );

                    gameCanvas.requestPaint();
                }
            }

            GameCanvas {
                id: gameCanvas
                game: gameContainer
                z: 1
            }

            GameController {
                id: gameController
                game: gameContainer
                gameCanvas: gameCanvas
                stageClearTimer: stageClearIntermissionTimer
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

            ModalLayer {
                id: modalLayer
                game: gameContainer
                soundManager: soundManager
                gameCanvas: gameCanvas
            }
        }
    }
}
