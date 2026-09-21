import QtQuick 2.9
import Lomiri.Components 1.3

Column {
    id: root

    property int score: 0
    property int bestScore: 0
    property int streak: 0
    property bool isSuperFall: false

    width: units.gu(32)
    spacing: units.gu(0.4)

    // Eyebrow tag
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: eyebrowLabel.width + units.gu(2.0)
        height: units.gu(2.0)
        radius: units.gu(1.0)
        color: "#800B1015"
        border.color: "#1E2A38"
        border.width: units.gu(0.08)

        Label {
            id: eyebrowLabel
            anchors.centerIn: parent
            text: i18n.tr("SCORE")
            font.pixelSize: units.gu(1.0)
            font.weight: Font.Bold
            color: "#64748B"
        }
    }

    // Heroic Score Readout with micro-scale bounce on change
    Label {
        id: scoreLabel
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.score.toString()
        font.pixelSize: units.gu(5.0)
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
        height: units.gu(2.6)
        radius: units.gu(1.3)
        color: "#D90B1015"
        border.color: "#273546"
        border.width: units.gu(0.1)
        visible: root.bestScore > 0

        Row {
            id: bestRow
            anchors.centerIn: parent
            spacing: units.gu(0.8)

            Rectangle {
                width: units.gu(0.8)
                height: units.gu(0.8)
                radius: units.gu(0.4)
                color: "#F59E0B"
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                text: i18n.tr("BEST %1").arg(root.bestScore)
                font.pixelSize: units.gu(1.3)
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
        height: units.gu(3.2)
        radius: units.gu(1.6)
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
                width: units.gu(1.0)
                height: units.gu(1.0)
                radius: units.gu(0.5)
                color: root.isSuperFall ? "#FFFFFF" : "#F59E0B"
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                id: streakText
                text: root.isSuperFall ? i18n.tr("FIREBALL SMASH!") : i18n.tr("COMBO x%1").arg(root.streak)
                font.pixelSize: units.gu(1.5)
                font.weight: Font.Bold
                color: root.isSuperFall ? "#FFFFFF" : "#FBBF24"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
