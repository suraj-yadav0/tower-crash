import QtQuick 2.9
import Lomiri.Components 1.3
import "../../qml/components"

Item {
    id: root
    width: 480
    height: 800

    GameOverModal {
        id: gameOverModal
        anchors.fill: parent
        score: 1500
        bestScore: 3200
        levelReached: 18
        checkpointLevel: 16
        difficultyMode: 1
    }

    Timer {
        interval: 50
        running: true
        repeat: false
        onTriggered: {
            try {
                if (gameOverModal.levelReached !== 18) throw new Error("levelReached mismatch");
                if (gameOverModal.checkpointLevel !== 16) throw new Error("checkpointLevel mismatch");

                var restarted = false;
                gameOverModal.restartRequested.connect(function() { restarted = true; });
                gameOverModal.restartRequested();
                if (!restarted) throw new Error("restartRequested failed");

                var continueFired = false;
                gameOverModal.continueCheckpointRequested.connect(function() { continueFired = true; });
                gameOverModal.continueCheckpointRequested();
                if (!continueFired) throw new Error("continueCheckpointRequested failed");

                var menuFired = false;
                gameOverModal.mainMenuRequested.connect(function() { menuFired = true; });
                gameOverModal.mainMenuRequested();
                if (!menuFired) throw new Error("mainMenuRequested failed");

                console.log("PASS: test_game_over_modal");
                Qt.quit();
            } catch (e) {
                console.error("FAIL: test_game_over_modal - " + e.message);
                Qt.exit(1);
            }
        }
    }
}
