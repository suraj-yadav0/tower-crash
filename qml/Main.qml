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

        header: PageHeader {
            id: pageHeader
            title: i18n.tr("Tower Crash")
            subtitle: {
                if (gameContainer.isWelcomeOpen) return i18n.tr("Arcade Edition");
                var diffName = Progression.getDifficultyName(gameContainer.difficultyMode);
                var zoneName = Progression.getZoneName(gameContainer.currentLevel);
                if (gameContainer.difficultyMode === 3) {
                    if (gameContainer.bestScore > 0) {
                        return i18n.tr("Level %1 • %2 • %3 (Permadeath) • Best: %4")
                            .arg(gameContainer.currentLevel)
                            .arg(zoneName)
                            .arg(diffName)
                            .arg(gameContainer.bestScore);
                    }
                    return i18n.tr("Level %1 • %2 • %3 (Permadeath)")
                        .arg(gameContainer.currentLevel)
                        .arg(zoneName)
                        .arg(diffName);
                }
                var stage = ((gameContainer.currentLevel - 1) % 5) + 1;
                if (gameContainer.bestScore > 0) {
                    return i18n.tr("Level %1 • %2 • %3 (%4/5) • Best: %5")
                        .arg(gameContainer.currentLevel)
                        .arg(zoneName)
                        .arg(diffName)
                        .arg(stage)
                        .arg(gameContainer.bestScore);
                }
                return i18n.tr("Level %1 • %2 • %3 (%4/5)")
                    .arg(gameContainer.currentLevel)
                    .arg(zoneName)
                    .arg(diffName)
                    .arg(stage);
            }
            z: 100
            visible: true

            trailingActionBar.numberOfSlots: 5
            trailingActionBar.actions: [
                Action {
                    iconName: "go-home"
                    text: i18n.tr("Main Menu")
                    visible: !gameContainer.isWelcomeOpen && !gameContainer.isStageClearOpen && !gameContainer.isStageClearCelebrating
                    onTriggered: {
                        soundManager.buttonHaptic();
                        gameContainer.goToMainMenu();
                    }
                },
                Action {
                    iconName: gameContainer.isPaused ? "media-playback-start" : "media-playback-pause"
                    text: gameContainer.isPaused ? i18n.tr("Resume") : i18n.tr("Pause")
                    visible: !gameContainer.isWelcomeOpen && !gameContainer.isStageClearOpen && !gameContainer.isStageClearCelebrating
                    onTriggered: {
                        if (!gameContainer.gameOver && !gameContainer.isStageClearOpen && !gameContainer.isStageClearCelebrating) {
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
                        if (!gameContainer.gameOver && !gameContainer.isWelcomeOpen && !gameContainer.isStageClearOpen && !gameContainer.isStageClearCelebrating) {
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

            GameBackground {
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

            property int difficultyMode: 1
            property real difficultySpeedMultiplier: Progression.getDifficultySpeedMultiplier ? Progression.getDifficultySpeedMultiplier(difficultyMode) : 1.0

            property int speedMode: 1
            property real speedMultiplier: {
                if (speedMode === 0) return 0.78;
                if (speedMode === 2) return 1.20;
                return 1.0;
            }

            property real baseGravity: units.gu(260)
            property real baseBounceSpeed: units.gu(77)
            property real baseMaxFallSpeed: units.gu(180)

            property real gravity: baseGravity * speedMultiplier * difficultySpeedMultiplier
            property real bounceSpeed: baseBounceSpeed * Math.sqrt(speedMultiplier * difficultySpeedMultiplier)
            property real maxFallSpeed: baseMaxFallSpeed * speedMultiplier * difficultySpeedMultiplier
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
                    if (Storage.saveHighestLevelForMode) {
                        Storage.saveHighestLevelForMode(highestLevelReached, difficultyMode);
                    } else {
                        Storage.saveHighestLevel(highestLevelReached);
                    }
                }
                if (Progression.isCheckpointLevel(currentLevel, difficultyMode)) {
                    unlockCheckpoint(currentLevel);
                }
            }

            function unlockCheckpoint(lvl) {
                if (!Progression.hasCheckpoints(difficultyMode)) return;
                var updated = Progression.unlockCheckpoint(lvl, unlockedCheckpoints, difficultyMode);
                var isNew = (updated.length !== unlockedCheckpoints.length);
                if (isNew) {
                    unlockedCheckpoints = updated;
                    selectedCheckpoint = lvl;
                    if (Storage.saveUnlockedCheckpointsForMode) {
                        Storage.saveUnlockedCheckpointsForMode(unlockedCheckpoints, difficultyMode);
                        Storage.saveSelectedCheckpointForMode(selectedCheckpoint, difficultyMode);
                    } else {
                        Storage.saveUnlockedCheckpoints(unlockedCheckpoints);
                        Storage.saveSelectedCheckpoint(selectedCheckpoint);
                    }
                } else if (lvl > selectedCheckpoint) {
                    selectedCheckpoint = lvl;
                    if (Storage.saveSelectedCheckpointForMode) {
                        Storage.saveSelectedCheckpointForMode(selectedCheckpoint, difficultyMode);
                    } else {
                        Storage.saveSelectedCheckpoint(selectedCheckpoint);
                    }
                }
            }

            function startFromCheckpoint(checkpointLevel) {
                if (difficultyMode === 3) {
                    selectedCheckpoint = 1;
                    initGame(1);
                    return;
                }
                var validCheckpoint = Math.max(1, checkpointLevel || selectedCheckpoint || 1);
                selectedCheckpoint = validCheckpoint;
                if (Storage.saveSelectedCheckpointForMode) {
                    Storage.saveSelectedCheckpointForMode(selectedCheckpoint, difficultyMode);
                } else {
                    Storage.saveSelectedCheckpoint(selectedCheckpoint);
                }
                initGame(validCheckpoint);
            }

            function switchDifficultyMode(newMode) {
                var m = Math.max(0, Math.min(3, parseInt(newMode) || 0));
                if (m === difficultyMode) return;
                difficultyMode = m;
                if (Storage.saveDifficultyMode) {
                    Storage.saveDifficultyMode(m);
                }
                var diffStats = Storage.getDifficultyStats ? Storage.getDifficultyStats(m) : { bestScore: 0, highestLevelReached: 1, unlockedCheckpoints: [1], selectedCheckpoint: 1 };
                bestScore = diffStats.bestScore || 0;
                highestLevelReached = diffStats.highestLevelReached || 1;
                unlockedCheckpoints = (m === 3) ? [1] : (diffStats.unlockedCheckpoints || [1]);
                selectedCheckpoint = (m === 3) ? 1 : (diffStats.selectedCheckpoint || 1);
                var keepSettings = isSettingsOpen;
                initGame(selectedCheckpoint);
                if (keepSettings) {
                    isSettingsOpen = true;
                }
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
                rings.push(RingGen.createRing(nextRingIndex++, ringSpacing, prevRing, difficultyMode));
            }

            function initGame(checkpointLevel) {
                var startLvl = (difficultyMode === 3) ? 1 : (checkpointLevel || 1);
                score = Progression.getCheckpointBaseScore(startLvl, difficultyMode);
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
                if (!isWelcomeOpen) {
                    isSettingsOpen = false;
                    wasPausedBeforeSettings = false;
                }
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
                if (difficultyMode !== 3) {
                    var nearest = Progression.getNearestCheckpoint(currentLevel, unlockedCheckpoints, difficultyMode);
                    if (nearest > selectedCheckpoint) {
                        selectedCheckpoint = nearest;
                        if (Storage.saveSelectedCheckpointForMode) {
                            Storage.saveSelectedCheckpointForMode(selectedCheckpoint, difficultyMode);
                        } else {
                            Storage.saveSelectedCheckpoint(selectedCheckpoint);
                        }
                    }
                } else {
                    selectedCheckpoint = 1;
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
                difficultyMode = (stats.difficultyMode !== undefined) ? stats.difficultyMode : 1;
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
                unlockedCheckpoints = (difficultyMode === 3) ? [1] : stats.unlockedCheckpoints;
                selectedCheckpoint = (difficultyMode === 3) ? 1 : stats.selectedCheckpoint;
                isWelcomeOpen = true;
                initGame(selectedCheckpoint);
            }

            Keys.onPressed: {
                if (event.key === Qt.Key_A) {
                    if (!gameOver && !isPaused && !isSettingsOpen && !isWelcomeOpen && !isStageClearOpen && !isStageClearCelebrating) {
                        towerAngle += 0.12;
                        gameCanvas.requestPaint();
                        event.accepted = true;
                    }
                } else if (event.key === Qt.Key_D) {
                    if (!gameOver && !isPaused && !isSettingsOpen && !isWelcomeOpen && !isStageClearOpen && !isStageClearCelebrating) {
                        towerAngle -= 0.12;
                        gameCanvas.requestPaint();
                        event.accepted = true;
                    }
                }
            }
            Keys.onLeftPressed: {
                if (!gameOver && !isPaused && !isSettingsOpen && !isWelcomeOpen && !isStageClearOpen && !isStageClearCelebrating) {
                    towerAngle += 0.12;
                    gameCanvas.requestPaint();
                    event.accepted = true;
                }
            }
            Keys.onRightPressed: {
                if (!gameOver && !isPaused && !isSettingsOpen && !isWelcomeOpen && !isStageClearOpen && !isStageClearCelebrating) {
                    towerAngle -= 0.12;
                    gameCanvas.requestPaint();
                    event.accepted = true;
                }
            }
            Keys.onReturnPressed: {
                if (isWelcomeOpen) {
                    startGame();
                    event.accepted = true;
                } else if (isStageClearOpen) {
                    if (stageClearIsGrand) {
                        goToMainMenu();
                    } else {
                        continueDescent();
                    }
                    event.accepted = true;
                } else if (gameOver) {
                    startGame();
                    event.accepted = true;
                }
            }
            Keys.onEnterPressed: {
                if (isWelcomeOpen) {
                    startGame();
                    event.accepted = true;
                } else if (isStageClearOpen) {
                    if (stageClearIsGrand) {
                        goToMainMenu();
                    } else {
                        continueDescent();
                    }
                    event.accepted = true;
                } else if (gameOver) {
                    startGame();
                    event.accepted = true;
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
                if (isStageClearCelebrating) {
                    stageClearIntermissionTimer.stop();
                    isStageClearCelebrating = false;
                    ballY = milestoneRingY;
                    ballVy = 0.0;
                    cameraY = milestoneRingY;
                    activePlatformY = milestoneRingY;
                    isStageClearOpen = true;
                    gameCanvas.requestPaint();
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
                    event.accepted = true;
                } else if (isStageClearOpen) {
                    goToMainMenu();
                    event.accepted = true;
                } else if (gameOver) {
                    goToMainMenu();
                    event.accepted = true;
                } else if (!isWelcomeOpen && isPaused) {
                    isPaused = false;
                    event.accepted = true;
                } else if (!isWelcomeOpen && !gameOver && !isStageClearCelebrating) {
                    isPaused = true;
                    event.accepted = true;
                }
            }

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

            MouseArea {
                id: dragArea
                anchors.fill: parent
                z: 2
                enabled: !gameContainer.gameOver && !gameContainer.isPaused && !gameContainer.isSettingsOpen && !gameContainer.isWelcomeOpen && !gameContainer.isStageClearOpen && !gameContainer.isStageClearCelebrating

                onPressed: {
                    gameContainer.isDragging = true;
                    gameContainer.angularVelocity = 0.0;
                    gameContainer.lastDragX = mouse.x;
                    gameContainer.lastDragTime = Date.now();
                }

                onPositionChanged: {
                    if (pressed && !gameContainer.gameOver && !gameContainer.isPaused && !gameContainer.isSettingsOpen && !gameContainer.isWelcomeOpen && !gameContainer.isStageClearOpen && !gameContainer.isStageClearCelebrating) {
                        var now = Date.now();
                        var elapsed = Math.max(1, now - gameContainer.lastDragTime);
                        var dx = mouse.x - gameContainer.lastDragX;

                        var sens = gameContainer.touchSensitivityMultiplier;
                        gameContainer.towerAngle -= dx * 0.014 * sens;
                        var fling = -(dx / elapsed) * 0.12 * sens;
                        gameContainer.angularVelocity = Math.max(-0.25, Math.min(0.25, fling));

                        gameContainer.lastDragX = mouse.x;
                        gameContainer.lastDragTime = now;
                        gameCanvas.requestPaint();
                    }
                }

                onReleased: {
                    gameContainer.isDragging = false;
                    if (Date.now() - gameContainer.lastDragTime > 80) {
                        gameContainer.angularVelocity = 0.0;
                    }
                }
                onCanceled: {
                    gameContainer.isDragging = false;
                    gameContainer.angularVelocity = 0.0;
                }
            }

            GameHud {
                z: 10
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
                z: 20
                text: gameContainer.bannerText
                isCheckpoint: gameContainer.bannerIsCheckpoint
                isZoneTransition: gameContainer.bannerIsZone
                bannerOpacity: gameContainer.bannerOpacity
                theme: gameContainer.currentTheme
            }

            ModalLayer {
                id: modalLayer
                anchors.fill: parent
                z: 150

                isWelcomeOpen: gameContainer.isWelcomeOpen
                isPaused: gameContainer.isPaused
                isSettingsOpen: gameContainer.isSettingsOpen
                wasPausedBeforeSettings: gameContainer.wasPausedBeforeSettings
                gameOver: gameContainer.gameOver
                isStageClearOpen: gameContainer.isStageClearOpen

                score: gameContainer.score
                bestScore: gameContainer.bestScore
                totalRings: gameContainer.totalRings
                speedMode: gameContainer.speedMode
                themeMode: gameContainer.themeMode
                difficultyMode: gameContainer.difficultyMode
                currentLevel: gameContainer.currentLevel
                selectedCheckpoint: gameContainer.selectedCheckpoint
                unlockedCheckpoints: gameContainer.unlockedCheckpoints
                currentTheme: gameContainer.currentTheme

                soundEnabled: gameContainer.soundEnabled
                soundVolume: gameContainer.soundVolume
                hapticsEnabled: gameContainer.hapticsEnabled
                touchSensitivityMultiplier: gameContainer.touchSensitivityMultiplier

                stageClearStage: gameContainer.stageClearStage
                stageClearBonus: gameContainer.stageClearBonus
                stageClearStreak: gameContainer.stageClearStreak
                stageClearIsCheckpoint: gameContainer.stageClearIsCheckpoint
                stageClearNextCheckpoint: gameContainer.stageClearNextCheckpoint
                stageClearIsGrand: gameContainer.stageClearIsGrand

                soundManager: soundManager

                onPlayRequested: {
                    soundManager.buttonHaptic();
                    gameContainer.startGame();
                }
                onCheckpointSelected: {
                    soundManager.buttonHaptic();
                    if (gameContainer.difficultyMode === 3) {
                        gameContainer.selectedCheckpoint = 1;
                        return;
                    }
                    gameContainer.selectedCheckpoint = checkpoint;
                    if (Storage.saveSelectedCheckpointForMode) {
                        Storage.saveSelectedCheckpointForMode(checkpoint, gameContainer.difficultyMode);
                    } else {
                        Storage.saveSelectedCheckpoint(checkpoint);
                    }
                    gameCanvas.requestPaint();
                }
                onSettingsRequested: {
                    soundManager.buttonHaptic();
                    gameContainer.wasPausedBeforeSettings = false;
                    gameContainer.isSettingsOpen = true;
                }
                onResumeRequested: {
                    soundManager.buttonHaptic();
                    gameContainer.isPaused = false;
                }
                onRestartCheckpointRequested: {
                    soundManager.buttonHaptic();
                    gameContainer.startFromCheckpoint(checkpoint);
                }
                onRestartRequested: {
                    soundManager.buttonHaptic();
                    gameContainer.startFromCheckpoint(1);
                }
                onRestartStageOneRequested: {
                    soundManager.buttonHaptic();
                    gameContainer.isStageClearOpen = false;
                    gameContainer.startFromCheckpoint(1);
                }
                onMainMenuRequested: {
                    soundManager.buttonHaptic();
                    gameContainer.isStageClearOpen = false;
                    gameContainer.goToMainMenu();
                }
                onContinueRequested: {
                    soundManager.buttonHaptic();
                    if (gameContainer.stageClearIsGrand) {
                        gameContainer.goToMainMenu();
                    } else {
                        gameContainer.continueDescent();
                    }
                }
                onSettingsClosed: {
                    soundManager.buttonHaptic();
                    gameContainer.isSettingsOpen = false;
                    if (!gameContainer.wasPausedBeforeSettings && !gameContainer.gameOver && !gameContainer.isWelcomeOpen) {
                        gameContainer.isPaused = false;
                    }
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
                onSpeedModeSelected: {
                    soundManager.buttonHaptic();
                    gameContainer.speedMode = mode;
                    Storage.saveStat("speedMode", mode.toString());
                }
                onDifficultyModeSelected: {
                    soundManager.buttonHaptic();
                    gameContainer.switchDifficultyMode(mode);
                }
                onThemeModeSelected: {
                    soundManager.buttonHaptic();
                    gameContainer.themeMode = mode;
                    Storage.saveStat("themeMode", mode.toString());
                    gameCanvas.requestPaint();
                }
                onTouchSensitivitySelected: {
                    soundManager.buttonHaptic();
                    gameContainer.touchSensitivityMultiplier = sensitivity;
                    Storage.saveTouchSensitivity(sensitivity);
                }
                onVolumeChanged: {
                    gameContainer.soundVolume = volume;
                    Storage.saveSoundVolume(volume);
                }
                onSoundToggled: {
                    soundManager.buttonHaptic();
                    gameContainer.soundEnabled = !gameContainer.soundEnabled;
                    Storage.saveStat("soundEnabled", gameContainer.soundEnabled ? "1" : "0");
                }
                onHapticsToggled: {
                    soundManager.buttonHaptic();
                    gameContainer.hapticsEnabled = !gameContainer.hapticsEnabled;
                    Storage.saveStat("hapticsEnabled", gameContainer.hapticsEnabled ? "1" : "0");
                }
            }
        }
    }
}
