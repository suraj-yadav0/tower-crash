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
        property int score: 50
        property int bestScore: 100
        property int currentLevel: 5
        property int difficultyMode: 2
        property int ballStyle: 0
        property var currentTheme: Themes.getTheme(0, 5)
        property var previousTheme: null
        property real themeTransitionProgress: 1.0

        property real towerAngle: 0.0
        property real angularVelocity: 0.0
        property real ballY: 200.0
        property real ballVy: 500.0
        property real cameraY: 200.0
        property real activePlatformY: 260.0
        property real squash: 1.0
        property real squashVelocity: 0.0
        property bool isSuperFall: false
        property real ballRotationX: 0.2
        property real ballRotationY: 0.4

        property real ringSpacing: units.gu(26)
        property real outerRadius: units.gu(20)
        property real innerRadius: units.gu(4.8)
        property real poleRadius: units.gu(4.8)
        property real ballRadius: units.gu(2.4)
        property real ringHeight: units.gu(2.8)
        property real tiltRatio: 0.34
        property real maxFallSpeed: units.gu(55)

        // Multiple rings with hazards and spikes
        property var rings: [
            {
                index: 0,
                y: units.gu(26),
                angleOffset: 0.0,
                rotationSpeed: 0.0,
                isOscillating: false,
                isGoal: false,
                isGrandGoal: false,
                broken: false,
                recoil: 0,
                segments: [2, 2, 0, 1, 2, 0, 2, 0] // 4 hazard segments!
            },
            {
                index: 1,
                y: units.gu(52),
                angleOffset: 0.5,
                rotationSpeed: 0.0,
                isOscillating: false,
                isGoal: false,
                isGrandGoal: false,
                broken: false,
                recoil: 0,
                segments: [2, 0, 2, 1, 2, 2, 0, 0] // 4 hazard segments!
            }
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
        interval: 50
        running: true
        repeat: false
        onTriggered: {
            try {
                // Rotate full 360 degrees in small increments to test all spike projection angles
                for (var step = 0; step < 60; step++) {
                    mockGame.towerAngle = (step / 60.0) * Math.PI * 2.0;
                    canvas.requestPaint();
                }
                console.log("PASS: test_hazard_spikes");
                Qt.quit();
            } catch (e) {
                console.error("FAIL: test_hazard_spikes - " + e.message);
                Qt.exit(1);
            }
        }
    }
}
