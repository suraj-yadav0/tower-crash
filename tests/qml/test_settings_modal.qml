import QtQuick 2.9
import Lomiri.Components 1.3
import "../../qml/components"

Item {
    id: root
    width: 480
    height: 800

    SettingsModal {
        id: settingsModal
        anchors.fill: parent
        visible: true
        soundEnabled: true
        hapticsEnabled: true
        speedMode: 1
        difficultyMode: 1
        themeMode: 0
        isWelcomeOpen: false
    }

    Timer {
        interval: 50
        running: true
        repeat: false
        onTriggered: {
            try {
                if (settingsModal.difficultyMode !== 1) throw new Error("difficultyMode mismatch");
                if (settingsModal.speedMode !== 1) throw new Error("speedMode mismatch");

                var diffReceived = -1;
                settingsModal.difficultyModeSelected.connect(function(m) { diffReceived = m; });
                settingsModal.difficultyModeSelected(3);
                if (diffReceived !== 3) throw new Error("difficultyModeSelected failed");

                var speedReceived = -1;
                settingsModal.speedModeSelected.connect(function(s) { speedReceived = s; });
                settingsModal.speedModeSelected(0);
                if (speedReceived !== 0) throw new Error("speedModeSelected failed");

                var menuRequested = false;
                settingsModal.mainMenuRequested.connect(function() { menuRequested = true; });
                settingsModal.mainMenuRequested();
                if (!menuRequested) throw new Error("mainMenuRequested failed");

                var closed = false;
                settingsModal.closeRequested.connect(function() { closed = true; });
                settingsModal.closeRequested();
                if (!closed) throw new Error("closeRequested failed");

                console.log("PASS: test_settings_modal");
                Qt.quit();
            } catch (e) {
                console.error("FAIL: test_settings_modal - " + e.message);
                Qt.exit(1);
            }
        }
    }
}
