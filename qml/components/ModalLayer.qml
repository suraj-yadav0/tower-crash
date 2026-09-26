import QtQuick 2.9
import Lomiri.Components 1.3
import "../js/Themes.js" as Themes
import "../js/Progression.js" as Progression

Item {
    id: root
    anchors.fill: parent
    z: 150

    property bool isWelcomeOpen: false
    property bool isPaused: false
    property bool isSettingsOpen: false
    property bool wasPausedBeforeSettings: false
    property bool gameOver: false
    property bool isStageClearOpen: false

    property int score: 0
    property int bestScore: 0
    property int totalRings: 0
    property int speedMode: 1
    property int themeMode: 0
    property int difficultyMode: 1
    property int currentLevel: 1
    property int selectedCheckpoint: 1
    property var unlockedCheckpoints: [1]
    property var currentTheme: null

    property bool soundEnabled: true
    property real soundVolume: 0.85
    property bool hapticsEnabled: true
    property real touchSensitivityMultiplier: 1.0

    property int stageClearStage: 1
    property int stageClearBonus: 0
    property int stageClearStreak: 0
    property bool stageClearIsCheckpoint: false
    property int stageClearNextCheckpoint: 1
    property bool stageClearIsGrand: false

    property var soundManager: null

    signal checkpointSelected(int checkpoint)
    signal playRequested()
    signal settingsRequested()
    signal themeCycleRequested()
    signal speedCycleRequested()
    signal difficultyModeSelected(int mode)
    signal resumeRequested()
    signal restartCheckpointRequested(int checkpoint)
    signal restartRequested()
    signal restartStageOneRequested()
    signal mainMenuRequested()
    signal soundToggled()
    signal hapticsToggled()
    signal speedModeSelected(int mode)
    signal volumeChanged(real volume)
    signal touchSensitivitySelected(real sensitivity)
    signal themeModeSelected(int mode)
    signal settingsClosed()
    signal continueRequested()

    Loader {
        id: welcomeScreenLoader
        anchors.fill: parent
        z: 150
        active: root.isWelcomeOpen
        visible: active
        sourceComponent: Component {
            WelcomeScreen {
                anchors.fill: parent
                visible: true
                bestScore: root.bestScore
                totalRings: root.totalRings
                speedMode: root.speedMode
                difficultyMode: root.difficultyMode
                selectedCheckpoint: root.selectedCheckpoint
                unlockedCheckpoints: root.unlockedCheckpoints
                theme: Themes.getTheme(root.themeMode, root.selectedCheckpoint)
                themeName: Themes.getThemeName(root.themeMode, root.selectedCheckpoint)
                onCheckpointSelected: root.checkpointSelected(checkpoint)
                onDifficultySelected: root.difficultyModeSelected(mode)
                onPlayRequested: root.playRequested()
                onSettingsRequested: root.settingsRequested()
                onThemeCycleRequested: root.themeCycleRequested()
                onSpeedCycleRequested: root.speedCycleRequested()
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
        active: root.isPaused && !root.isSettingsOpen && !root.gameOver && !root.isWelcomeOpen
        visible: active
        sourceComponent: Component {
            PauseModal {
                anchors.fill: parent
                visible: true
                soundEnabled: root.soundEnabled
                hapticsEnabled: root.hapticsEnabled
                speedMode: root.speedMode
                difficultyMode: root.difficultyMode
                currentCheckpoint: Progression.getNearestCheckpoint(root.currentLevel, root.unlockedCheckpoints, root.difficultyMode)
                theme: root.currentTheme
                onResumeRequested: root.resumeRequested()
                onRestartCheckpointRequested: root.restartCheckpointRequested(Progression.getNearestCheckpoint(root.currentLevel, root.unlockedCheckpoints, root.difficultyMode))
                onRestartRequested: root.restartRequested()
                onMainMenuRequested: root.mainMenuRequested()
                onToggleSoundRequested: root.soundToggled()
                onToggleHapticsRequested: root.hapticsToggled()
                onSpeedModeSelected: root.speedModeSelected(newMode)
            }
        }
    }

    Loader {
        id: settingsModalLoader
        anchors.fill: parent
        z: 250
        active: root.isSettingsOpen
        visible: active
        sourceComponent: Component {
            SettingsModal {
                anchors.fill: parent
                visible: true
                soundEnabled: root.soundEnabled
                soundVolume: root.soundVolume
                hapticsEnabled: root.hapticsEnabled
                speedMode: root.speedMode
                themeMode: root.themeMode
                difficultyMode: root.difficultyMode
                touchSensitivityMultiplier: root.touchSensitivityMultiplier
                bestScore: root.bestScore
                totalRings: root.totalRings
                theme: root.currentTheme
                isWelcomeOpen: root.isWelcomeOpen
                onCloseRequested: root.settingsClosed()
                onMainMenuRequested: root.mainMenuRequested()
                onToggleSoundRequested: root.soundToggled()
                onVolumeChanged: root.volumeChanged(newVolume)
                onToggleHapticsRequested: root.hapticsToggled()
                onSpeedModeSelected: root.speedModeSelected(newMode)
                onDifficultyModeSelected: root.difficultyModeSelected(newMode)
                onTouchSensitivitySelected: root.touchSensitivitySelected(newSensitivity)
                onThemeModeSelected: root.themeModeSelected(newMode)
            }
        }
    }

    Loader {
        id: gameOverModalLoader
        anchors.fill: parent
        z: 200
        active: root.gameOver && !root.isSettingsOpen && !root.isWelcomeOpen
        visible: active
        sourceComponent: Component {
            GameOverModal {
                anchors.fill: parent
                visible: true
                score: root.score
                bestScore: root.bestScore
                levelReached: root.currentLevel
                difficultyMode: root.difficultyMode
                checkpointLevel: Progression.getNearestCheckpoint(root.currentLevel, root.unlockedCheckpoints, root.difficultyMode)
                theme: root.currentTheme
                onContinueCheckpointRequested: root.restartCheckpointRequested(Progression.getNearestCheckpoint(root.currentLevel, root.unlockedCheckpoints, root.difficultyMode))
                onRestartRequested: root.restartRequested()
                onMainMenuRequested: root.mainMenuRequested()
            }
        }
    }

    Loader {
        id: stageClearModalLoader
        anchors.fill: parent
        z: 220
        active: root.isStageClearOpen && !root.isSettingsOpen && !root.isWelcomeOpen
        visible: active
        sourceComponent: Component {
            StageClearModal {
                anchors.fill: parent
                visible: true
                stageNumber: root.stageClearStage
                score: root.score
                bonusPoints: root.stageClearBonus
                streak: root.stageClearStreak
                isCheckpoint: root.stageClearIsCheckpoint
                nextCheckpoint: root.stageClearNextCheckpoint
                checkpointLevel: Progression.getNearestCheckpoint(root.stageClearStage, root.unlockedCheckpoints, root.difficultyMode)
                isGrandVictory: root.stageClearIsGrand
                theme: root.stageClearIsCheckpoint
                       ? Themes.getTheme(root.themeMode, root.stageClearNextCheckpoint)
                       : root.currentTheme
                onContinueRequested: root.continueRequested()
                onRestartRequested: root.restartCheckpointRequested(Progression.getNearestCheckpoint(root.stageClearStage, root.unlockedCheckpoints, root.difficultyMode))
                onRestartStageOneRequested: root.restartStageOneRequested()
                onMainMenuRequested: root.mainMenuRequested()
            }
        }
    }
}
