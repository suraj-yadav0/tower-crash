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

    width: units.gu(34)
    spacing: units.gu(0.5)

    // Double-Bezel Level Progression Card
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width, units.gu(34))
        height: units.gu(3.6)
        radius: units.gu(1.8)
        color: "#D90B1015"
        border.color: "#223142"
        border.width: units.gu(0.12)

        Row {
            anchors.centerIn: parent
            spacing: units.gu(0.8)

            // Current Level Tag
            Rectangle {
                width: units.gu(4.8)
                height: units.gu(2.4)
                radius: units.gu(1.2)
                color: "#162836"
                border.color: "#00D2D3"
                border.width: units.gu(0.12)
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    anchors.centerIn: parent
                    text: i18n.tr("L%1").arg(root.currentLevel)
                    font.pixelSize: units.gu(1.3)
                    font.weight: Font.Bold
                    color: "#00D2D3"
                }
            }

            // Recessed Progress Bar
            Rectangle {
                width: units.gu(18)
                height: units.gu(0.8)
                radius: units.gu(0.4)
                color: "#060A0D"
                border.color: "#1E2A38"
                border.width: units.gu(0.08)
                anchors.verticalCenter: parent.verticalCenter
                clip: true

                Rectangle {
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
                width: units.gu(4.8)
                height: units.gu(2.4)
                radius: units.gu(1.2)
                color: "#111720"
                border.color: "#243242"
                border.width: units.gu(0.1)
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    anchors.centerIn: parent
                    text: i18n.tr("L%1").arg(root.currentLevel + 1)
                    font.pixelSize: units.gu(1.3)
                    font.weight: Font.DemiBold
                    color: "#64748B"
                }
            }
        }
    }

    // Eyebrow tag
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: eyebrowLabel.width + units.gu(2.0)
        height: units.gu(1.8)
        radius: units.gu(0.9)
        color: "#800B1015"
        border.color: "#1E2A38"
        border.width: units.gu(0.08)

        Label {
            id: eyebrowLabel
            anchors.centerIn: parent
            text: i18n.tr("SCORE")
            font.pixelSize: units.gu(0.95)
            font.weight: Font.Bold
            color: "#64748B"
        }
    }

    // Heroic Score Readout with micro-scale bounce on change
    Label {
        id: scoreLabel
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.score.toString()
        font.pixelSize: units.gu(4.8)
        font.weight: Font.Black
        color: "#FFFFFF"
        transformOrigin: Item.Center

        SequentialAnimation {
            id: scorePopAnim
            NumberAnimation { target: scoreLabel; property: "scale"; to: 1.16; duration: 80; easing.type: Easing.OutQuad }
            NumberAnimation { target: scoreLabel; property: "scale"; to: 1.0; duration: 150; easing.type: Easing.OutBack }
        }

        onTextChanged: {
            if (root.score > 0) {
                scorePopAnim.restart();
            }
        }
    }

    // Floating Best Score capsule
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: bestRow.width + units.gu(2.4)
        height: units.gu(2.4)
        radius: units.gu(1.2)
        color: "#D90B1015"
        border.color: "#273546"
        border.width: units.gu(0.1)
        visible: root.bestScore > 0

        Row {
            id: bestRow
            anchors.centerIn: parent
            spacing: units.gu(0.8)

            Rectangle {
                width: units.gu(0.7)
                height: units.gu(0.7)
                radius: units.gu(0.35)
                color: "#F59E0B"
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                text: i18n.tr("BEST %1").arg(root.bestScore)
                font.pixelSize: units.gu(1.2)
                font.weight: Font.Bold
                color: "#FBBF24"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // Streak / Fireball dynamic status pill
    Rectangle {
        id: streakPill
        anchors.horizontalCenter: parent.horizontalCenter
        width: streakText.width + units.gu(3.0)
        height: units.gu(3.0)
        radius: units.gu(1.5)
        color: root.isSuperFall ? "#E6C0392B" : "#D91C1709"
        border.color: root.isSuperFall ? "#FF4757" : "#F59E0B"
        border.width: units.gu(0.14)
        visible: root.streak > 1 || root.isSuperFall
        opacity: visible ? 1.0 : 0.0
        scale: visible ? 1.0 : 0.8

        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
        }
        Behavior on scale {
            NumberAnimation { duration: 150; easing.type: Easing.OutBack }
        }

        Row {
            anchors.centerIn: parent
            spacing: units.gu(0.8)

            Rectangle {
                width: units.gu(0.9)
                height: units.gu(0.9)
                radius: units.gu(0.45)
                color: root.isSuperFall ? "#FFFFFF" : "#F59E0B"
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                id: streakText
                text: root.isSuperFall ? i18n.tr("FIREBALL SMASH!") : i18n.tr("COMBO x%1").arg(root.streak)
                font.pixelSize: units.gu(1.4)
                font.weight: Font.Bold
                color: root.isSuperFall ? "#FFFFFF" : "#FBBF24"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
