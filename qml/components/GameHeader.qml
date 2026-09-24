import QtQuick 2.9
import Lomiri.Components 1.3
import "../js/Storage.js" as Storage

PageHeader {
    id: root

    property var game: null
    property var soundManager: null

    title: i18n.tr("Tower Crash")
    subtitle: (root.game && root.game.isWelcomeOpen) ? i18n.tr("Arcade Edition") : i18n.tr("Level %1").arg(root.game ? root.game.currentLevel : 1)
    z: 100
    visible: true

    trailingActionBar.numberOfSlots: 4
    trailingActionBar.actions: [
        Action {
            iconName: (root.game && root.game.isPaused) ? "media-playback-start" : "media-playback-pause"
            text: (root.game && root.game.isPaused) ? i18n.tr("Resume") : i18n.tr("Pause")
            visible: root.game ? (!root.game.isWelcomeOpen && !root.game.isStageClearOpen && !root.game.isStageClearCelebrating) : false
            onTriggered: {
                if (root.game && !root.game.gameOver && !root.game.isStageClearOpen && !root.game.isStageClearCelebrating) {
                    if (root.soundManager) root.soundManager.buttonHaptic();
                    root.game.isPaused = !root.game.isPaused;
                }
            }
        },
        Action {
            iconName: "settings"
            text: i18n.tr("Settings")
            visible: true
            onTriggered: {
                if (root.soundManager) root.soundManager.buttonHaptic();
                if (root.game) {
                    root.game.wasPausedBeforeSettings = root.game.isPaused;
                    if (!root.game.gameOver && !root.game.isWelcomeOpen && !root.game.isStageClearOpen && !root.game.isStageClearCelebrating) {
                        root.game.isPaused = true;
                    }
                    root.game.isSettingsOpen = true;
                }
            }
        },
        Action {
            iconName: (root.game && root.game.soundEnabled) ? "audio-volume-high" : "audio-volume-muted"
            text: (root.game && root.game.soundEnabled) ? i18n.tr("Sound") : i18n.tr("Muted")
            visible: root.game ? !root.game.isWelcomeOpen : false
            onTriggered: {
                if (!root.game) return;
                if (root.soundManager) root.soundManager.buttonHaptic();
                root.game.soundEnabled = !root.game.soundEnabled;
                Storage.saveStat("soundEnabled", root.game.soundEnabled ? "1" : "0");
            }
        },
        Action {
            iconName: "view-refresh"
            text: i18n.tr("Restart")
            visible: root.game ? !root.game.isWelcomeOpen : false
            onTriggered: {
                if (!root.game) return;
                if (root.soundManager) root.soundManager.buttonHaptic();
                root.game.startGame();
            }
        }
    ]
}
