import QtQuick 2.9
import Lomiri.Components 1.3

Column {
    id: root
    z: 10

    property int score: 0
    property int bestScore: 0
    property int currentLevel: 1
    property real levelProgress: 0.0
    property int streak: 0
    property bool isSuperFall: false
    property var theme: null

    property int checkpointIndex: Math.floor((currentLevel - 1) / 5) + 1
    property int stageInCheckpoint: ((currentLevel - 1) % 5) + 1

    width: units.gu(32)
    spacing: units.gu(0.4)

    // Frosted Capsule Level Progression
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - units.gu(4.0), units.gu(25))
        height: units.gu(3.6)
        radius: height / 2
        color: "#E00E1015"
        border.color: root.theme ? (root.theme.cardBorder || "#2A2E38") : "#2A2E38"
        border.width: units.gu(0.08)

        Row {
            anchors.centerIn: parent
            width: parent.width - units.gu(1.6)
            spacing: units.gu(0.8)

            // Current Level Chip
            Rectangle {
                id: currentLevelChip
                width: Math.max(units.gu(2.8), currentLevelLabel.width + units.gu(1.4))
                height: units.gu(2.4)
                radius: height / 2
                color: root.theme ? root.theme.accent : "#D99B26"
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    id: currentLevelLabel
                    anchors.centerIn: parent
                    text: root.currentLevel.toString()
                    font.pixelSize: units.gu(1.25)
                    font.weight: Font.Black
                    color: root.theme ? root.theme.accentText : "#0B0C0D"
                }
            }

            // Embedded Progress Track
            Rectangle {
                id: progressTrack
                width: parent.width - currentLevelChip.width - nextLevelChip.width - (parent.spacing * 2)
                height: units.gu(0.85)
                radius: height / 2
                color: "#18FFFFFF"
                border.color: "#10FFFFFF"
                border.width: units.gu(0.06)
                clip: true
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    width: Math.max(parent.radius * 2, parent.width * Math.min(1.0, Math.max(0.0, root.levelProgress)))
                    height: parent.height
                    radius: parent.radius
                    color: root.theme ? root.theme.accent : "#D99B26"

                    Behavior on width {
                        NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
                    }
                }
            }

            // Next Level Chip
            Rectangle {
                id: nextLevelChip
                width: Math.max(units.gu(2.8), nextLevelLabel.width + units.gu(1.4))
                height: units.gu(2.4)
                radius: height / 2
                color: "#1FFFFFFF"
                border.color: "#28FFFFFF"
                border.width: units.gu(0.08)
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    id: nextLevelLabel
                    anchors.centerIn: parent
                    text: (root.currentLevel + 1).toString()
                    font.pixelSize: units.gu(1.2)
                    font.weight: Font.Bold
                    color: "#F3F4F6"
                }
            }
        }
    }

    // Score Display
    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        width: scoreLabel.width
        height: scoreLabel.height

        Label {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: units.gu(0.12)
            text: root.score.toString()
            font.pixelSize: units.gu(4.4)
            font.weight: Font.Black
            color: "#66000000"
            scale: scoreLabel.scale
        }

        Label {
            id: scoreLabel
            anchors.centerIn: parent
            text: root.score.toString()
            font.pixelSize: units.gu(4.4)
            font.weight: Font.Black
            color: (root.bestScore > 0 && root.score >= root.bestScore)
                   ? (root.theme ? root.theme.accent : "#FFD700")
                   : "#F5F3EF"
            transformOrigin: Item.Center

            SequentialAnimation {
                id: scorePopAnim
                NumberAnimation { target: scoreLabel; property: "scale"; to: 1.16; duration: 80; easing.type: Easing.OutQuad }
                NumberAnimation { target: scoreLabel; property: "scale"; to: 1.0; duration: 140; easing.type: Easing.OutBack }
            }

            onTextChanged: {
                if (root.score > 0) {
                    scorePopAnim.restart();
                }
            }
        }
    }

    // Streak Pill
    Rectangle {
        id: streakPill
        anchors.horizontalCenter: parent.horizontalCenter
        width: streakText.width + units.gu(2.4)
        height: units.gu(2.4)
        radius: units.gu(1.2)
        color: root.isSuperFall
               ? "#9E2B2B"
               : (root.theme ? root.theme.accentBg : "#261E10")
        border.color: root.isSuperFall
                      ? (root.theme ? root.theme.topHazard : "#BA3C3C")
                      : (root.theme ? root.theme.accent : "#D99B26")
        border.width: units.gu(0.12)
        visible: root.streak > 1 || root.isSuperFall
        opacity: visible ? 1.0 : 0.0
        scale: visible ? 1.0 : 0.85

        Behavior on opacity {
            NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
        }
        Behavior on scale {
            NumberAnimation { duration: 160; easing.type: Easing.OutBack }
        }

        SequentialAnimation on scale {
            running: root.isSuperFall
            loops: Animation.Infinite
            NumberAnimation { to: 1.06; duration: 260; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 0.96; duration: 260; easing.type: Easing.InOutQuad }
        }

        Row {
            anchors.centerIn: parent
            spacing: units.gu(0.6)

            Rectangle {
                width: units.gu(0.7)
                height: units.gu(0.7)
                radius: units.gu(0.35)
                color: root.isSuperFall ? "#FFFFFF" : (root.theme ? root.theme.accent : "#D99B26")
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                id: streakText
                text: root.isSuperFall ? i18n.tr("OVERDRIVE!") : i18n.tr("COMBO x%1").arg(root.streak)
                font.pixelSize: units.gu(1.1)
                font.weight: Font.Bold
                color: root.isSuperFall ? "#FFFFFF" : (root.theme ? root.theme.accentText : "#F5F3EF")
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
