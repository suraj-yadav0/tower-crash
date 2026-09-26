import QtQuick 2.9
import Lomiri.Components 1.3
import "../../qml/components"

Item {
    id: root
    width: 480
    height: 800

    WelcomeScreen {
        id: target
        anchors.fill: parent
        bestScore: 1200
        totalRings: 45
        speedMode: 1
        difficultyMode: 1
        selectedCheckpoint: 1
        unlockedCheckpoints: [1, 6, 11]
    }

    Timer {
        interval: 50
        running: true
        repeat: false
        onTriggered: {
            try {
                if (target.difficultyMode !== 1) throw new Error("difficultyMode was not 1");
                if (target.bestScore !== 1200) throw new Error("bestScore was not 1200");
                if (target.unlockedCheckpoints.length !== 3) throw new Error("unlockedCheckpoints length mismatch");

                var diffReceived = -1;
                target.difficultySelected.connect(function(mode) {
                    diffReceived = mode;
                });
                target.difficultySelected(2);
                if (diffReceived !== 2) throw new Error("difficultySelected signal did not transmit mode");

                var cpReceived = -1;
                target.checkpointSelected.connect(function(cp) {
                    cpReceived = cp;
                });
                target.checkpointSelected(6);
                if (cpReceived !== 6) throw new Error("checkpointSelected signal failed");

                var playFired = false;
                target.playRequested.connect(function() {
                    playFired = true;
                });
                target.playRequested();
                if (!playFired) throw new Error("playRequested signal failed");

                console.log("PASS: test_welcome_screen");
                Qt.quit();
            } catch (e) {
                console.error("FAIL: test_welcome_screen - " + e.message);
                Qt.exit(1);
            }
        }
    }
}
