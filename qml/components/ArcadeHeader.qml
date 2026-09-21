import QtQuick 2.9
import Lomiri.Components 1.3

Item {
    id: root

    property int currentLevel: 1
    property real levelProgress: 0.0
    property bool soundEnabled: true
    property bool isPaused: false

    signal pauseToggled()
    signal soundToggled()
    signal restartRequested()

    width: Math.min(parent ? parent.width - units.gu(3.2) : units.gu(42), units.gu(42))
    height: units.gu(4.6)

    // Left Action: Sound toggle button
    Rectangle {
        id: soundButton
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: units.gu(4.4)
        height: units.gu(4.4)
        radius: units.gu(2.2)
        color: soundMouse.pressed ? "#223244" : "#D90B1015"
        border.color: soundMouse.pressed ? "#00D2D3" : "#223142"
        border.width: units.gu(0.12)
        scale: soundMouse.pressed ? 0.92 : 1.0

        Behavior on scale {
            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
        }

        Canvas {
            id: soundIcon
            anchors.centerIn: parent
            width: units.gu(2.2)
            height: units.gu(2.2)

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                var active = root.soundEnabled;
                ctx.fillStyle = active ? "#00D2D3" : "#64748B";
                ctx.strokeStyle = active ? "#00D2D3" : "#64748B";
                ctx.lineWidth = 1.6;

                // Speaker body
                ctx.beginPath();
                ctx.moveTo(width * 0.15, height * 0.35);
                ctx.lineTo(width * 0.38, height * 0.35);
                ctx.lineTo(width * 0.65, height * 0.15);
                ctx.lineTo(width * 0.65, height * 0.85);
                ctx.lineTo(width * 0.38, height * 0.65);
                ctx.lineTo(width * 0.15, height * 0.65);
                ctx.closePath();
                ctx.fill();

                if (active) {
                    // Sound waves
                    ctx.beginPath();
                    ctx.arc(width * 0.55, height * 0.5, width * 0.28, -Math.PI * 0.28, Math.PI * 0.28, false);
                    ctx.stroke();

                    ctx.beginPath();
                    ctx.arc(width * 0.55, height * 0.5, width * 0.42, -Math.PI * 0.30, Math.PI * 0.30, false);
                    ctx.stroke();
                } else {
                    // Mute diagonal slash
                    ctx.beginPath();
                    ctx.strokeStyle = "#FF4757";
                    ctx.lineWidth = 2.0;
                    ctx.moveTo(width * 0.2, height * 0.2);
                    ctx.lineTo(width * 0.8, height * 0.8);
                    ctx.stroke();
                }
            }

            Connections {
                target: root
                onSoundEnabledChanged: soundIcon.requestPaint()
            }
        }

        MouseArea {
            id: soundMouse
            anchors.fill: parent
            onClicked: root.soundToggled()
        }
    }

    // Center Island: Double-Bezel Level Progression Card
    Rectangle {
        id: levelIsland
        anchors.left: soundButton.right
        anchors.leftMargin: units.gu(1.0)
        anchors.right: pauseButton.left
        anchors.rightMargin: units.gu(1.0)
        anchors.verticalCenter: parent.verticalCenter
        height: units.gu(4.4)
        radius: units.gu(2.2)
        color: "#D90B1015"
        border.color: "#223142"
        border.width: units.gu(0.12)

        Row {
            anchors.centerIn: parent
            spacing: units.gu(0.9)

            // Current Level Tag
            Rectangle {
                width: units.gu(5.0)
                height: units.gu(2.8)
                radius: units.gu(1.4)
                color: "#162836"
                border.color: "#00D2D3"
                border.width: units.gu(0.12)
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    anchors.centerIn: parent
                    text: i18n.tr("L%1").arg(root.currentLevel)
                    font.pixelSize: units.gu(1.4)
                    font.weight: Font.Bold
                    color: "#00D2D3"
                }
            }

            // Recessed Progress Bar
            Rectangle {
                id: progressTrack
                width: levelIsland.width - units.gu(13.6)
                height: units.gu(0.9)
                radius: units.gu(0.45)
                color: "#060A0D"
                border.color: "#1E2A38"
                border.width: units.gu(0.08)
                anchors.verticalCenter: parent.verticalCenter
                clip: true

                Rectangle {
                    id: progressFill
                    width: Math.max(parent.radius * 2, parent.width * Math.min(1.0, Math.max(0.0, root.levelProgress)))
                    height: parent.height
                    radius: parent.radius
                    color: "#00D2D3"

                    Behavior on width {
                        NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
                    }
                }
            }

            // Next Level Tag
            Rectangle {
                width: units.gu(5.0)
                height: units.gu(2.8)
                radius: units.gu(1.4)
                color: "#111720"
                border.color: "#243242"
                border.width: units.gu(0.1)
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    anchors.centerIn: parent
                    text: i18n.tr("L%1").arg(root.currentLevel + 1)
                    font.pixelSize: units.gu(1.4)
                    font.weight: Font.DemiBold
                    color: "#64748B"
                }
            }
        }
    }

    // Right Action: Pause toggle button
    Rectangle {
        id: pauseButton
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: units.gu(4.4)
        height: units.gu(4.4)
        radius: units.gu(2.2)
        color: pauseMouse.pressed ? "#223244" : "#D90B1015"
        border.color: pauseMouse.pressed ? "#00D2D3" : "#223142"
        border.width: units.gu(0.12)
        scale: pauseMouse.pressed ? 0.92 : 1.0

        Behavior on scale {
            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
        }

        Canvas {
            id: pauseIcon
            anchors.centerIn: parent
            width: units.gu(2.0)
            height: units.gu(2.0)

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.fillStyle = "#FFFFFF";

                if (root.isPaused) {
                    // Play triangle
                    ctx.beginPath();
                    ctx.moveTo(width * 0.28, height * 0.18);
                    ctx.lineTo(width * 0.82, height * 0.50);
                    ctx.lineTo(width * 0.28, height * 0.82);
                    ctx.closePath();
                    ctx.fill();
                } else {
                    // Pause two bars
                    var barW = width * 0.24;
                    var barH = height * 0.68;
                    var topY = (height - barH) / 2.0;

                    ctx.fillRect(width * 0.20, topY, barW, barH);
                    ctx.fillRect(width * 0.56, topY, barW, barH);
                }
            }

            Connections {
                target: root
                onIsPausedChanged: pauseIcon.requestPaint()
            }
        }

        MouseArea {
            id: pauseMouse
            anchors.fill: parent
            onClicked: root.pauseToggled()
        }
    }
}
