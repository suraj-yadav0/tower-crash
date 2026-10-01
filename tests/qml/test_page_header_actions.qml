import QtQuick 2.9
import Lomiri.Components 1.3

Item {
    id: root
    width: 480
    height: 800

    property bool isWelcomeOpen: false
    property bool isStageClearOpen: false
    property bool isStageClearCelebrating: false
    property bool gameOver: false
    property bool isPaused: false
    property bool isSettingsOpen: false
    property bool wasPausedBeforeSettings: false
    property bool soundEnabled: true
    property var currentTheme: ({
        accent: "#D99B26",
        accentBg: "#261E10"
    })

    PageHeader {
        id: pageHeader
        title: "Tower Crash"
        trailingActionBar.numberOfSlots: 5
        trailingActionBar.delegate: Component {
            AbstractButton {
                id: actionButton
                action: modelData
                objectName: (action && action.objectName) ? (action.objectName + "_button") : "action_button"
                width: units.gu(5)
                height: parent ? parent.height : units.gu(5)
                activeFocusOnTab: true

                readonly property bool isSelected: Boolean(action && action.selected)
                readonly property bool isHighlighted: isSelected || actionButton.pressed
                readonly property var activeTheme: root.currentTheme

                Rectangle {
                    id: highlightBg
                    anchors.centerIn: parent
                    width: units.gu(4.2)
                    height: units.gu(4.2)
                    radius: units.dp(8)
                    color: actionButton.isSelected
                           ? (actionButton.activeTheme ? actionButton.activeTheme.accentBg : "#261E10")
                           : (actionButton.pressed ? theme.palette.highlighted.background : "transparent")
                    border.color: actionButton.isSelected
                                  ? (actionButton.activeTheme ? actionButton.activeTheme.accent : "#D99B26")
                                  : (actionButton.pressed ? "#5D5D5D" : "transparent")
                    border.width: actionButton.isSelected ? units.dp(1.5) : (actionButton.pressed ? units.dp(1) : 0)
                    opacity: actionButton.isHighlighted ? 1.0 : 0.0
                }

                Icon {
                    id: actionIcon
                    anchors.centerIn: parent
                    width: units.gu(2.4)
                    height: units.gu(2.4)
                    name: action ? (action.iconName || "") : ""
                    source: action ? (action.iconSource || "") : ""
                    color: actionButton.isSelected
                           ? (actionButton.activeTheme ? actionButton.activeTheme.accent : "#D99B26")
                           : (actionButton.pressed
                              ? theme.palette.highlighted.backgroundText
                              : (actionButton.enabled ? theme.palette.normal.backgroundText : theme.palette.disabled.backgroundText))
                }
            }
        }

        trailingActionBar.actions: [
            Action {
                id: mainMenuAction
                objectName: "action_main_menu"
                iconName: "go-home"
                text: "Main Menu"
                visible: !root.isWelcomeOpen && !root.isStageClearOpen && !root.isStageClearCelebrating
            },
            Action {
                id: pauseAction
                objectName: "action_pause"
                iconName: root.isPaused ? "media-playback-start" : "media-playback-pause"
                text: root.isPaused ? "Resume" : "Pause"
                property bool selected: root.isPaused && !root.isSettingsOpen && !root.gameOver && !root.isWelcomeOpen && !root.isStageClearOpen
                visible: !root.isWelcomeOpen && !root.isStageClearOpen && !root.isStageClearCelebrating
                onTriggered: {
                    if (!root.gameOver && !root.isStageClearOpen && !root.isStageClearCelebrating) {
                        root.isPaused = !root.isPaused;
                    }
                }
            },
            Action {
                id: settingsAction
                objectName: "action_settings"
                iconName: "settings"
                text: "Settings"
                property bool selected: root.isSettingsOpen
                visible: true
                onTriggered: {
                    if (root.isSettingsOpen) {
                        root.isSettingsOpen = false;
                        if (!root.wasPausedBeforeSettings && !root.gameOver && !root.isWelcomeOpen && !root.isStageClearOpen) {
                            root.isPaused = false;
                        }
                        return;
                    }
                    root.wasPausedBeforeSettings = root.isPaused;
                    if (!root.gameOver && !root.isWelcomeOpen && !root.isStageClearOpen && !root.isStageClearCelebrating) {
                        root.isPaused = true;
                    }
                    root.isSettingsOpen = true;
                }
            },
            Action {
                id: soundAction
                objectName: "action_sound"
                iconName: root.soundEnabled ? "audio-volume-high" : "audio-volume-muted"
                text: root.soundEnabled ? "Sound" : "Muted"
                property bool selected: !root.soundEnabled
                visible: !root.isWelcomeOpen
                onTriggered: {
                    root.soundEnabled = !root.soundEnabled;
                }
            },
            Action {
                id: restartAction
                objectName: "action_restart"
                iconName: "view-refresh"
                text: "Restart"
                visible: !root.isWelcomeOpen
            }
        ]
    }

    Timer {
        interval: 50
        running: true
        repeat: false
        onTriggered: {
            try {
                // Initial state checks
                if (settingsAction.selected !== false) throw new Error("settings should not be selected initially");
                if (pauseAction.selected !== false) throw new Error("pause should not be selected initially");
                if (soundAction.selected !== false) throw new Error("sound should not be selected initially");

                // Trigger Settings action: opens settings and becomes selected
                settingsAction.trigger();
                if (!root.isSettingsOpen) throw new Error("settings should be open after trigger");
                if (!settingsAction.selected) throw new Error("settings action should be selected when open");
                if (!root.isPaused) throw new Error("game should pause when opening settings");

                // Trigger Settings again: closes settings and deselects
                settingsAction.trigger();
                if (root.isSettingsOpen) throw new Error("settings should be closed after second trigger");
                if (settingsAction.selected) throw new Error("settings action should not be selected after closing");
                if (root.isPaused) throw new Error("game should resume when closing settings");

                // Trigger Pause action: pause game and becomes selected
                pauseAction.trigger();
                if (!root.isPaused) throw new Error("game should be paused after pause trigger");
                if (!pauseAction.selected) throw new Error("pause action should be selected when paused");

                // Resume via pause action
                pauseAction.trigger();
                if (root.isPaused) throw new Error("game should not be paused after resume trigger");
                if (pauseAction.selected) throw new Error("pause action should not be selected after resume");

                // Toggle sound to muted: sound action becomes selected
                soundAction.trigger();
                if (root.soundEnabled) throw new Error("sound should be muted after toggle");
                if (!soundAction.selected) throw new Error("sound action should be selected when muted");

                // Toggle sound back on
                soundAction.trigger();
                if (!root.soundEnabled) throw new Error("sound should be enabled after second toggle");
                if (soundAction.selected) throw new Error("sound action should not be selected when unmuted");

                console.log("PASS: test_page_header_actions");
                Qt.quit();
            } catch (e) {
                console.error("FAIL: test_page_header_actions - " + e.message);
                Qt.exit(1);
            }
        }
    }
}
