import QtQuick 2.9
import Lomiri.Components 1.3
import "../../qml/components"
import "../../qml/js/Themes.js" as Themes
import "../../qml/js/Progression.js" as Progression
import "../../qml/js/RingGenerator.js" as RingGen

Item {
    id: root
    width: 480
    height: 800

    Item {
        id: mockGame
        property int score: 0
        property int bestScore: 0
        property int currentLevel: 1
        property int difficultyMode: 1
        property int ballStyle: 0
        property var currentTheme: Themes.getTheme(0, 1)
        property var previousTheme: null
        property real themeTransitionProgress: 1.0

        property real towerAngle: 0.0
        property real angularVelocity: 0.0
        property real ballY: 100.0
        property real ballVy: 0.0
        property real cameraY: 100.0
        property real activePlatformY: 120.0
        property real squash: 1.0
        property real squashVelocity: 0.0
        property bool isSuperFall: false
        property real ballRotationX: 0.0
        property real ballRotationY: 0.0

        property real ringSpacing: units.gu(26)
        property real outerRadius: units.gu(20)
        property real innerRadius: units.gu(4.8)
        property real poleRadius: units.gu(4.8)
        property real ballRadius: units.gu(2.4)
        property real ringHeight: units.gu(2.8)
        property real tiltRatio: 0.34

        property var rings: [
            RingGen.createRing(0, units.gu(26), null, 1),
            RingGen.createRing(1, units.gu(26), null, 1)
        ]
        property var particles: []
        property var ballTrail: []
    }

    GameCanvas {
        id: canvas
        anchors.fill: parent
        game: mockGame
    }

    Timer {
        interval: 80
        running: true
        repeat: false
        onTriggered: {
            try {
                canvas.requestPaint();

                // Test auto ball style progression lookup
                mockGame.currentLevel = 15;
                mockGame.ballStyle = 0;
                canvas.requestPaint();

                // Test specific ball style
                mockGame.ballStyle = 2;
                canvas.requestPaint();

                console.log("PASS: test_game_canvas");
                Qt.quit();
            } catch (e) {
                console.error("FAIL: test_game_canvas - " + e.message);
                Qt.exit(1);
            }
        }
    }
}
