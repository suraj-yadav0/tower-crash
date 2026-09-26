import QtQuick 2.9
import Lomiri.Components 1.3
import "../../qml/components"

Item {
    id: root
    width: 480
    height: 800

    AboutView {
        id: target
        width: parent.width - units.gu(4.0)
        anchors.centerIn: parent
    }

    Timer {
        interval: 50
        running: true
        repeat: false
        onTriggered: {
            try {
                if (target.width <= 0) throw new Error("AboutView width was not set");

                var backFired = false;
                target.backRequested.connect(function() {
                    backFired = true;
                });
                target.backRequested();
                if (!backFired) throw new Error("backRequested signal did not fire");

                console.log("PASS: test_about_view");
                Qt.quit();
            } catch (e) {
                console.error("FAIL: test_about_view - " + e.message);
                Qt.exit(1);
            }
        }
    }
}
