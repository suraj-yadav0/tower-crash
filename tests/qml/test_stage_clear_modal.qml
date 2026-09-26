import QtQuick 2.9
import Lomiri.Components 1.3
import "../../qml/components"

Item {
    id: root
    width: 480
    height: 800

    StageClearModal {
        id: stageClearModal
        anchors.fill: parent
        stageNumber: 5
        score: 1250
        bonusPoints: 150
        streak: 3
        isCheckpoint: true
        nextCheckpoint: 6
        checkpointLevel: 6
    }

    Timer {
        interval: 50
        running: true
        repeat: false
        onTriggered: {
            try {
                if (stageClearModal.stageNumber !== 5) throw new Error("stageNumber mismatch");
                if (stageClearModal.isCheckpoint !== true) throw new Error("isCheckpoint mismatch");
                if (stageClearModal.nextCheckpoint !== 6) throw new Error("nextCheckpoint mismatch");

                var continueFired = false;
                stageClearModal.continueRequested.connect(function() { continueFired = true; });
                stageClearModal.continueRequested();
                if (!continueFired) throw new Error("continueRequested failed");

                var restartFired = false;
                stageClearModal.restartRequested.connect(function() { restartFired = true; });
                stageClearModal.restartRequested();
                if (!restartFired) throw new Error("restartRequested failed");

                var menuFired = false;
                stageClearModal.mainMenuRequested.connect(function() { menuFired = true; });
                stageClearModal.mainMenuRequested();
                if (!menuFired) throw new Error("mainMenuRequested failed");

                console.log("PASS: test_stage_clear_modal");
                Qt.quit();
            } catch (e) {
                console.error("FAIL: test_stage_clear_modal - " + e.message);
                Qt.exit(1);
            }
        }
    }
}
