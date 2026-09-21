import QtQuick 2.9
import Lomiri.Components 1.3

Column {
    id: root

    property int score: 0
    property int bestScore: 0
    property int currentLevel: 1
    property real levelProgress: 0.0
    property int streak: 0
    property bool isSuperFall: false

    anchors.top: parent.top
    anchors.topMargin: units.gu(1.5)
    anchors.horizontalCenter: parent.horizontalCenter
    width: Math.min(parent.width - units.gu(4), units.gu(36))
    spacing: units.gu(0.6)

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: units.gu(1.2)

        Label {
            text: i18n.tr("Lvl %1").arg(root.currentLevel)
            font.pixelSize: units.gu(1.6)
            font.weight: Font.DemiBold
            color: "#FFFFFF"
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: units.gu(20)
            height: units.gu(0.8)
            radius: units.gu(0.4)
            color: "#2a3440"
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                width: parent.width * Math.min(1.0, Math.max(0.0, root.levelProgress))
                height: parent.height
                radius: parent.radius
                color: "#00d2d3"
            }
        }

        Label {
            text: i18n.tr("Lvl %1").arg(root.currentLevel + 1)
            font.pixelSize: units.gu(1.6)
            color: "#8fa3b5"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.score.toString()
        font.pixelSize: units.gu(4.8)
        font.weight: Font.Bold
        color: "#FFFFFF"
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: i18n.tr("BEST: %1").arg(root.bestScore)
        font.pixelSize: units.gu(1.6)
        color: "#8fa3b5"
        visible: root.bestScore > 0
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.isSuperFall ? i18n.tr("FIREBALL SMASH!") : i18n.tr("COMBO x%1").arg(root.streak)
        font.pixelSize: units.gu(1.8)
        font.weight: Font.Bold
        color: root.isSuperFall ? "#ff9f43" : "#ffd166"
        visible: root.streak > 1 || root.isSuperFall
    }
}
