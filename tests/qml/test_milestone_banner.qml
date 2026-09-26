import QtQuick 2.9
import Lomiri.Components 1.3
import "../../qml/components"

Item {
    id: root
    width: 480
    height: 800

    MilestoneBanner {
        id: banner
        text: "ZONE 2: CLOCKWORK SHAFT"
        isZoneTransition: true
        isCheckpoint: false
        bannerOpacity: 1.0
    }

    Timer {
        interval: 50
        running: true
        repeat: false
        onTriggered: {
            try {
                if (banner.text !== "ZONE 2: CLOCKWORK SHAFT") throw new Error("text mismatch");
                if (banner.isZoneTransition !== true) throw new Error("isZoneTransition mismatch");
                if (banner.visible !== true) throw new Error("visible mismatch when opacity is 1.0");

                // Checkpoint mode
                banner.isZoneTransition = false;
                banner.isCheckpoint = true;
                banner.text = "CHECKPOINT STAGE 6!";
                if (banner.isCheckpoint !== true) throw new Error("isCheckpoint failed to set");

                console.log("PASS: test_milestone_banner");
                Qt.quit();
            } catch (e) {
                console.error("FAIL: test_milestone_banner - " + e.message);
                Qt.exit(1);
            }
        }
    }
}
