import QtQuick 2.9
import Lomiri.Components 1.3
import "../../qml/components"

Item {
    id: root
    width: 480
    height: 800

    PauseModal {
        id: pauseModal
        anchors.fill: parent
        currentCheckpoint: 11
        difficultyMode: 1
        speedMode: 1
        soundEnabled: true
        hapticsEnabled: true
    }

    Timer {
        interval: 50
        running: true
        repeat: false
        onTriggered: {
            try {
                if (pauseModal.currentCheckpoint !== 11) throw new Error("currentCheckpoint mismatch");
                if (pauseModal.difficultyMode !== 1) throw new Error("difficultyMode mismatch");

                var resumed = false;
                pauseModal.resumeRequested.connect(function() { resumed = true; });
                pauseModal.resumeRequested();
                if (!resumed) throw new Error("resumeRequested failed");

                var restarted = false;
                pauseModal.restartRequested.connect(function() { restarted = true; });
                pauseModal.restartRequested();
                if (!restarted) throw new Error("restartRequested failed");

                var restartCpFired = false;
                pauseModal.restartCheckpointRequested.connect(function() { restartCpFired = true; });
                pauseModal.restartCheckpointRequested();
                if (!restartCpFired) throw new Error("restartCheckpointRequested failed");

                var menuRequested = false;
                pauseModal.mainMenuRequested.connect(function() { menuRequested = true; });
                pauseModal.mainMenuRequested();
                if (!menuRequested) throw new Error("mainMenuRequested failed");

                console.log("PASS: test_pause_modal");
                Qt.quit();
            } catch (e) {
                console.error("FAIL: test_pause_modal - " + e.message);
                Qt.exit(1);
            }
        }
    }
}
