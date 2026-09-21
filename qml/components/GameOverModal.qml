import QtQuick 2.9
import Lomiri.Components 1.3

Rectangle {
    id: root

    property int score: 0
    property int bestScore: 0
    property int levelReached: 1

    signal restartRequested()

    anchors.fill: parent
    color: "#D90A0E12"

    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width - units.gu(4), units.gu(34))
        height: units.gu(30)
        radius: units.gu(1.5)
        color: "#1c2228"
        border.color: "#2f3842"
        border.width: units.gu(0.15)

        Column {
            anchors.centerIn: parent
            width: parent.width - units.gu(4)
            spacing: units.gu(1.4)

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("GAME OVER")
                font.pixelSize: units.gu(3.2)
                font.weight: Font.Bold
                color: "#ff4757"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("Score: %1").arg(root.score)
                font.pixelSize: units.gu(2.4)
                color: "#FFFFFF"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("Best: %1").arg(root.bestScore)
                font.pixelSize: units.gu(1.8)
                color: "#8fa3b5"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("Reached Level %1").arg(root.levelReached)
                font.pixelSize: units.gu(1.6)
                color: "#00d2d3"
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("Play Again")
                color: "#2ed573"
                width: units.gu(18)
                height: units.gu(4.5)
                onClicked: root.restartRequested()
            }
        }
    }
}
