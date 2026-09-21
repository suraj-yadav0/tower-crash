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
    property var theme: null

    width: units.gu(36)
    spacing: units.gu(0.45)

    // Double-Bezel Level Progression Card
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width, units.gu(36))
        height: units.gu(3.8)
        radius: units.gu(1.9)
        color: root.theme ? root.theme.cardInner : "#D90B1015"
        border.color: root.theme ? root.theme.cardBorder : "#223142"
        border.width: units.gu(0.12)

        Row {
            anchors.centerIn: parent
            spacing: units.gu(0.9)

            // Current Level Tag
            Rectangle {
                width: units.gu(5.0)
                height: units.gu(2.6)
                radius: units.gu(1.3)
                color: root.theme ? root.theme.accentBg : "#162836"
                border.color: root.theme ? root.theme.accent : "#00D2D3"
                border.width: units.gu(0.12)
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    anchors.centerIn: parent
                    text: i18n.tr("L%1").arg(root.currentLevel)
                    font.pixelSize: units.gu(1.3)
                    font.weight: Font.Bold
                    color: root.theme ? root.theme.accent : "#00D2D3"
                }
            }

            // Recessed Progress Bar with Glowing Fill
            Rectangle {
                width: units.gu(18.5)
                height: units.gu(0.85)
                radius: units.gu(0.42)
                color: "#060A0D"
                border.color: root.theme ? root.theme.cardBorder : "#1E2A38"
                border.width: units.gu(0.08)
                anchors.verticalCenter: parent.verticalCenter
                clip: true

                Rectangle {
                    width: Math.max(parent.radius * 2, parent.width * Math.min(1.0, Math.max(0.0, root.levelProgress)))
                    height: parent.height
                    radius: parent.radius
                    color: root.theme ? root.theme.accent : "#00D2D3"

                    Behavior on width {
                        NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
                    }
                }
            }

            // Next Level Tag
            Rectangle {
                width: units.gu(5.0)
                height: units.gu(2.6)
                radius: units.gu(1.3)
                color: root.theme ? root.theme.cardOuter : "#111720"
                border.color: root.theme ? root.theme.cardBorder : "#243242"
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
        width: eyebrowLabel.width + units.gu(2.2)
        height: units.gu(1.9)
        radius: units.gu(0.95)
        color: "#800B1015"
        border.color: root.theme ? root.theme.cardBorder : "#1E2A38"
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

    // Heroic Score with drop depth
    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        width: scoreLabel.width
        height: scoreLabel.height

        Label {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: units.gu(0.12)
            text: root.score.toString()
            font.pixelSize: units.gu(5.0)
            font.weight: Font.Black
            color: "#4D000000"
        }

        Label {
            id: scoreLabel
            anchors.centerIn: parent
            text: root.score.toString()
            font.pixelSize: units.gu(5.0)
            font.weight: Font.Black
            color: "#FFFFFF"
            transformOrigin: Item.Center

            SequentialAnimation {
                id: scorePopAnim
                NumberAnimation { target: scoreLabel; property: "scale"; to: 1.18; duration: 80; easing.type: Easing.OutQuad }
                NumberAnimation { target: scoreLabel; property: "scale"; to: 1.0; duration: 150; easing.type: Easing.OutBack }
            }

            onTextChanged: {
                if (root.score > 0) {
                    scorePopAnim.restart();
                }
            }
        }
    }

    // Floating Best Score capsule
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: bestRow.width + units.gu(2.4)
        height: units.gu(2.4)
        radius: units.gu(1.2)
        color: root.theme ? root.theme.cardInner : "#D90B1015"
        border.color: root.theme ? root.theme.cardBorder : "#273546"
        border.width: units.gu(0.1)
        visible: root.bestScore > 0

        Row {
            id: bestRow
            anchors.centerIn: parent
            spacing: units.gu(0.8)

            Rectangle {
                width: units.gu(0.75)
                height: units.gu(0.75)
                radius: units.gu(0.375)
                color: root.theme ? root.theme.ballMid : "#F59E0B"
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                text: i18n.tr("BEST %1").arg(root.bestScore)
                font.pixelSize: units.gu(1.2)
                font.weight: Font.Bold
                color: root.theme ? root.theme.ballMid : "#FBBF24"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // Dynamic Streak & Fireball status pill
    Rectangle {
        id: streakPill
        anchors.horizontalCenter: parent.horizontalCenter
        width: streakText.width + units.gu(3.2)
        height: units.gu(3.2)
        radius: units.gu(1.6)
        color: root.isSuperFall ? "#E6C0392B" : (root.theme ? root.theme.accentBg : "#D91C1709")
        border.color: root.isSuperFall ? "#FF4757" : (root.theme ? root.theme.accent : "#F59E0B")
        border.width: units.gu(0.14)
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
            spacing: units.gu(0.8)

            Rectangle {
                width: units.gu(0.9)
                height: units.gu(0.9)
                radius: units.gu(0.45)
                color: root.isSuperFall ? "#FFFFFF" : (root.theme ? root.theme.accent : "#F59E0B")
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                id: streakText
                text: root.isSuperFall ? i18n.tr("FIREBALL SMASH!") : i18n.tr("COMBO x%1").arg(root.streak)
                font.pixelSize: units.gu(1.4)
                font.weight: Font.Bold
                color: root.isSuperFall ? "#FFFFFF" : (root.theme ? root.theme.accent : "#FBBF24")
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
