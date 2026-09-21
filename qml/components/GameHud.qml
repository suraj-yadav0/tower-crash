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

    width: Math.min(parent ? parent.width - units.gu(4) : units.gu(36), units.gu(36))
    spacing: units.gu(0.8)

    // Level progression card
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: units.gu(4.2)
        radius: units.gu(2.1)
        color: "#D90B1015"
        border.color: "#222D3B"
        border.width: units.gu(0.12)

        Row {
            anchors.centerIn: parent
            spacing: units.gu(1.0)

            Rectangle {
                width: units.gu(5.6)
                height: units.gu(2.6)
                radius: units.gu(1.3)
                color: "#162B37"
                border.color: "#00d2d3"
                border.width: units.gu(0.1)
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    anchors.centerIn: parent
                    text: i18n.tr("Lvl %1").arg(root.currentLevel)
                    font.pixelSize: units.gu(1.4)
                    font.weight: Font.Bold
                    color: "#00d2d3"
                }
            }

            Rectangle {
                width: root.width - units.gu(15.2)
                height: units.gu(1.0)
                radius: units.gu(0.5)
                color: "#070B0E"
                border.color: "#1C2633"
                border.width: units.gu(0.1)
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    width: parent.width * Math.min(1.0, Math.max(0.0, root.levelProgress))
                    height: parent.height
                    radius: parent.radius
                    color: "#00d2d3"
                }
            }

            Rectangle {
                width: units.gu(5.6)
                height: units.gu(2.6)
                radius: units.gu(1.3)
                color: "#12171E"
                border.color: "#283442"
                border.width: units.gu(0.1)
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    anchors.centerIn: parent
                    text: i18n.tr("Lvl %1").arg(root.currentLevel + 1)
                    font.pixelSize: units.gu(1.4)
                    font.weight: Font.DemiBold
                    color: "#7E90A3"
                }
            }
        }
    }

    // Score readout
    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.score.toString()
        font.pixelSize: units.gu(5.2)
        font.weight: Font.Bold
        color: "#FFFFFF"
    }

    // Best score capsule
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: bestScoreLabel.width + units.gu(2.4)
        height: units.gu(2.6)
        radius: units.gu(1.3)
        color: "#BF0F161E"
        border.color: "#334455"
        border.width: units.gu(0.1)
        visible: root.bestScore > 0

        Label {
            id: bestScoreLabel
            anchors.centerIn: parent
            text: i18n.tr("BEST %1").arg(root.bestScore)
            font.pixelSize: units.gu(1.4)
            font.weight: Font.Bold
            color: "#FBBF24"
        }
    }

    // Streak and Fireball status pill
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: streakLabel.width + units.gu(2.8)
        height: units.gu(3.0)
        radius: units.gu(1.5)
        color: root.isSuperFall ? "#E6C0392B" : "#D91C1709"
        border.color: root.isSuperFall ? "#FF793F" : "#FFD166"
        border.width: units.gu(0.15)
        visible: root.streak > 1 || root.isSuperFall

        Label {
            id: streakLabel
            anchors.centerIn: parent
            text: root.isSuperFall ? i18n.tr("FIREBALL SMASH!") : i18n.tr("COMBO x%1").arg(root.streak)
            font.pixelSize: units.gu(1.6)
            font.weight: Font.Bold
            color: root.isSuperFall ? "#FFFFFF" : "#FFD166"
        }
    }
}
