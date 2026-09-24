import QtQuick 2.9
import Lomiri.Components 1.3
import "../js/Themes.js" as Themes
import "../js/Storage.js" as Storage

Item {
    id: root
    anchors.fill: parent

    property var game: null
    property var soundManager: null
    property var gameCanvas: null

    Loader {
        id: welcomeScreenLoader
        anchors.fill: parent
        z: 150
        active: root.game ? root.game.isWelcomeOpen : false
        visible: active
        sourceComponent: Component {
            WelcomeScreen {
                anchors.fill: parent
                visible: true
                bestScore: root.game ? root.game.bestScore : 0
                totalRings: root.game ? root.game.totalRings : 0
                speedMode: root.game ? root.game.speedMode : 1
                selectedCheckpoint: root.game ? root.game.selectedCheckpoint : 1
                unlockedCheckpoints: root.game ? root.game.unlockedCheckpoints : [1]
                theme: root.game ? Themes.getTheme(root.game.themeMode, root.game.selectedCheckpoint) : null
                themeName: root.game ? Themes.getThemeName(root.game.themeMode, root.game.selectedCheckpoint) : ""
                onCheckpointSelected: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.selectedCheckpoint = checkpoint;
                    Storage.saveSelectedCheckpoint(checkpoint);
                    if (root.gameCanvas) root.gameCanvas.requestPaint();
                }
                onPlayRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.startGame();
                }
                onSettingsRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.wasPausedBeforeSettings = false;
                    root.game.isSettingsOpen = true;
                }
                onThemeCycleRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.themeMode = (root.game.themeMode + 1) % Themes.themeOptions.length;
                    Storage.saveStat("themeMode", root.game.themeMode.toString());
                    if (root.gameCanvas) root.gameCanvas.requestPaint();
                }
                onSpeedCycleRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.speedMode = (root.game.speedMode + 1) % 3;
                    Storage.saveStat("speedMode", root.game.speedMode.toString());
                }
                onHowToPlayRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                }
                onCloseHowToPlayRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                }
            }
        }
    }

    Loader {
        id: pauseModalLoader
        anchors.fill: parent
        z: 200
        active: root.game ? (root.game.isPaused && !root.game.isSettingsOpen && !root.game.gameOver && !root.game.isWelcomeOpen) : false
        visible: active
        sourceComponent: Component {
            PauseModal {
                anchors.fill: parent
                visible: true
                soundEnabled: root.game ? root.game.soundEnabled : true
                hapticsEnabled: root.game ? root.game.hapticsEnabled : true
                speedMode: root.game ? root.game.speedMode : 1
                currentCheckpoint: root.game ? root.game.getNearestCheckpoint(root.game.currentLevel) : 1
                theme: root.game ? root.game.currentTheme : null
                onResumeRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.isPaused = false;
                }
                onRestartCheckpointRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.startFromCheckpoint(root.game.getNearestCheckpoint(root.game.currentLevel));
                }
                onRestartRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.startFromCheckpoint(1);
                }
                onMainMenuRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.goToMainMenu();
                }
                onToggleSoundRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.soundEnabled = !root.game.soundEnabled;
                    Storage.saveStat("soundEnabled", root.game.soundEnabled ? "1" : "0");
                }
                onToggleHapticsRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.hapticsEnabled = !root.game.hapticsEnabled;
                    Storage.saveStat("hapticsEnabled", root.game.hapticsEnabled ? "1" : "0");
                }
                onSpeedModeSelected: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.speedMode = newMode;
                    Storage.saveStat("speedMode", newMode.toString());
                }
            }
        }
    }

    Loader {
        id: settingsModalLoader
        anchors.fill: parent
        z: 250
        active: root.game ? root.game.isSettingsOpen : false
        visible: active
        sourceComponent: Component {
            SettingsModal {
                anchors.fill: parent
                visible: true
                soundEnabled: root.game ? root.game.soundEnabled : true
                soundVolume: root.game ? root.game.soundVolume : 0.85
                hapticsEnabled: root.game ? root.game.hapticsEnabled : true
                speedMode: root.game ? root.game.speedMode : 1
                themeMode: root.game ? root.game.themeMode : 0
                touchSensitivityMultiplier: root.game ? root.game.touchSensitivityMultiplier : 1.0
                bestScore: root.game ? root.game.bestScore : 0
                totalRings: root.game ? root.game.totalRings : 0
                theme: root.game ? root.game.currentTheme : null
                onCloseRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.isSettingsOpen = false;
                    if (!root.game.wasPausedBeforeSettings && !root.game.gameOver && !root.game.isWelcomeOpen) {
                        root.game.isPaused = false;
                    }
                }
                onToggleSoundRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.soundEnabled = !root.game.soundEnabled;
                    Storage.saveStat("soundEnabled", root.game.soundEnabled ? "1" : "0");
                }
                onVolumeChanged: {
                    root.game.soundVolume = newVolume;
                    Storage.saveSoundVolume(newVolume);
                }
                onToggleHapticsRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.hapticsEnabled = !root.game.hapticsEnabled;
                    Storage.saveStat("hapticsEnabled", root.game.hapticsEnabled ? "1" : "0");
                }
                onSpeedModeSelected: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.speedMode = newMode;
                    Storage.saveStat("speedMode", newMode.toString());
                }
                onTouchSensitivitySelected: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.touchSensitivityMultiplier = newSensitivity;
                    Storage.saveTouchSensitivity(newSensitivity);
                }
                onThemeModeSelected: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.themeMode = newMode;
                    Storage.saveStat("themeMode", newMode.toString());
                    if (root.gameCanvas) root.gameCanvas.requestPaint();
                }
            }
        }
    }

    Loader {
        id: gameOverModalLoader
        anchors.fill: parent
        z: 200
        active: root.game ? (root.game.gameOver && !root.game.isSettingsOpen && !root.game.isWelcomeOpen) : false
        visible: active
        sourceComponent: Component {
            GameOverModal {
                anchors.fill: parent
                visible: true
                score: root.game ? root.game.score : 0
                bestScore: root.game ? root.game.bestScore : 0
                levelReached: root.game ? root.game.currentLevel : 1
                checkpointLevel: root.game ? root.game.getNearestCheckpoint(root.game.currentLevel) : 1
                theme: root.game ? root.game.currentTheme : null
                onContinueCheckpointRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.startFromCheckpoint(root.game.getNearestCheckpoint(root.game.currentLevel));
                }
                onRestartRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.startFromCheckpoint(1);
                }
                onMainMenuRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.goToMainMenu();
                }
            }
        }
    }

    Loader {
        id: stageClearModalLoader
        anchors.fill: parent
        z: 220
        active: root.game ? (root.game.isStageClearOpen && !root.game.isSettingsOpen && !root.game.isWelcomeOpen) : false
        visible: active
        sourceComponent: Component {
            StageClearModal {
                anchors.fill: parent
                visible: true
                stageNumber: root.game ? root.game.stageClearStage : 1
                score: root.game ? root.game.score : 0
                bonusPoints: root.game ? root.game.stageClearBonus : 0
                streak: root.game ? root.game.stageClearStreak : 0
                isCheckpoint: root.game ? root.game.stageClearIsCheckpoint : false
                nextCheckpoint: root.game ? root.game.stageClearNextCheckpoint : 1
                checkpointLevel: root.game ? root.game.getNearestCheckpoint(root.game.stageClearStage) : 1
                isGrandVictory: root.game ? root.game.stageClearIsGrand : false
                theme: (root.game && root.game.stageClearIsCheckpoint)
                       ? Themes.getTheme(root.game.themeMode, root.game.stageClearNextCheckpoint)
                       : (root.game ? root.game.currentTheme : null)
                onContinueRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    if (root.game.stageClearIsGrand) {
                        root.game.goToMainMenu();
                    } else {
                        root.game.continueDescent();
                    }
                }
                onRestartRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.isStageClearOpen = false;
                    root.game.startFromCheckpoint(root.game.getNearestCheckpoint(root.game.stageClearStage));
                }
                onRestartStageOneRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.isStageClearOpen = false;
                    root.game.startFromCheckpoint(1);
                }
                onMainMenuRequested: {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.isStageClearOpen = false;
                    root.game.goToMainMenu();
                }
            }
        }
    }
}
