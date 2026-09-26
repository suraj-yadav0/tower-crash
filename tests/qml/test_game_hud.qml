import QtQuick 2.9
import Lomiri.Components 1.3
import "../../qml/components"

Item {
    id: root
    width: 480
    height: 800

    GameHud {
        id: hud
        score: 450
        bestScore: 1200
        currentLevel: 7
        levelProgress: 0.65
        streak: 2
        isSuperFall: false
    }

    Timer {
        interval: 50
        running: true
        repeat: false
        onTriggered: {
            try {
                if (hud.score !== 450) throw new Error("score mismatch");
                if (hud.currentLevel !== 7) throw new Error("currentLevel mismatch");
                if (hud.stageInCheckpoint !== 2) throw new Error("stageInCheckpoint mismatch");
                if (hud.checkpointIndex !== 2) throw new Error("checkpointIndex mismatch");

                // Test combo overdrive mode
                hud.streak = 4;
                hud.isSuperFall = true;
                if (hud.isSuperFall !== true) throw new Error("isSuperFall failed to set");

                console.log("PASS: test_game_hud");
                Qt.quit();
            } catch (e) {
                console.error("FAIL: test_game_hud - " + e.message);
                Qt.exit(1);
            }
        }
    }
}
