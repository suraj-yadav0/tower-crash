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

    // Sleek Level Progression Card
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width, units.gu(30))
        height: units.gu(3.2)
        radius: units.gu(1.6)
        color: root.theme ? root.theme.cardInner : "#0D0E0F"
        border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
        border.width: units.gu(0.12)

        Row {
            anchors.centerIn: parent
            spacing: units.gu(0.8)

            // Current Level Tag
            Rectangle {
                width: units.gu(4.4)
                height: units.gu(2.2)
                radius: units.gu(1.1)
                color: root.theme ? root.theme.accentBg : "#261E10"
                border.color: root.theme ? root.theme.accentBorder : "#544020"
                border.width: units.gu(0.12)
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    anchors.centerIn: parent
                    text: i18n.tr("L%1").arg(root.currentLevel)
                    font.pixelSize: units.gu(1.2)
                    font.weight: Font.Bold
                    color: root.theme ? root.theme.accent : "#D99B26"
                }
            }

            // Recessed Progress Bar with Glowing Fill
            Rectangle {
                width: units.gu(16.0)
                height: units.gu(0.7)
                radius: units.gu(0.35)
                color: "#070809"
                border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                border.width: units.gu(0.08)
                anchors.verticalCenter: parent.verticalCenter
                clip: true

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

            // Next Level Tag
            Rectangle {
                width: units.gu(4.4)
                height: units.gu(2.2)
                radius: units.gu(1.1)
                color: root.theme ? root.theme.cardOuter : "#141517"
                border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                border.width: units.gu(0.1)
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    anchors.centerIn: parent
                    text: i18n.tr("L%1").arg(root.currentLevel + 1)
                    font.pixelSize: units.gu(1.2)
                    font.weight: Font.DemiBold
                    color: "#848890"
                }
            }
        }
    }

    // Heroic Score Display
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

    // Dynamic Streak & Fireball status pill
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
                text: root.isSuperFall ? i18n.tr("IMPACT OVERDRIVE!") : i18n.tr("COMBO x%1").arg(root.streak)
                font.pixelSize: units.gu(1.1)
                font.weight: Font.Bold
                color: root.isSuperFall ? "#FFFFFF" : (root.theme ? root.theme.accentText : "#F5F3EF")
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
