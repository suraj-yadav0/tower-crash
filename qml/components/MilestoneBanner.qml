import QtQuick 2.9
import Lomiri.Components 1.3

Item {
    id: root
    z: 20

    property string text: ""
    property bool isCheckpoint: false
    property bool isZoneTransition: false
    property real bannerOpacity: 0.0
    property var theme: null

    anchors.centerIn: parent
    anchors.verticalCenterOffset: -units.gu(8.0)
    width: outerShell.width
    height: outerShell.height
    opacity: root.bannerOpacity
    visible: opacity > 0.01

    Rectangle {
        id: outerShell
        anchors.centerIn: parent
        width: Math.min(units.gu(34), contentCol.width + units.gu(4.4))
        height: contentCol.height + units.gu(2.6)
        radius: units.gu(1.8)
        color: root.isZoneTransition ? "#10161C" : (root.isCheckpoint ? "#2E2308" : (root.theme ? root.theme.cardInner : "#0D0E0F"))
        border.color: root.isZoneTransition ? "#84B6D8" : (root.isCheckpoint ? "#FFD700" : (root.theme ? root.theme.accent : "#D99B26"))
        border.width: units.gu(0.12)
        scale: Math.min(1.0, 0.85 + 0.15 * root.bannerOpacity)

        Column {
            id: contentCol
            anchors.centerIn: parent
            spacing: units.gu(0.3)

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: stageTag.width + units.gu(1.6)
                height: units.gu(1.8)
                radius: units.gu(0.9)
                color: root.isZoneTransition ? "#1A2633" : (root.isCheckpoint ? "#332608" : (root.theme ? root.theme.accentBg : "#261E10"))
                border.color: root.isZoneTransition ? "#84B6D8" : (root.isCheckpoint ? "#FFD700" : (root.theme ? root.theme.accentBorder : "#544020"))
                border.width: units.gu(0.08)

                Label {
                    id: stageTag
                    anchors.centerIn: parent
                    text: root.isZoneTransition
                          ? i18n.tr("NEW ZONE REACHED")
                          : (root.isCheckpoint ? i18n.tr("CHECKPOINT UNLOCKED") : i18n.tr("STAGE COMPLETED"))
                    font.pixelSize: units.gu(1.0)
                    font.weight: Font.Bold
                    color: root.isZoneTransition ? "#84B6D8" : (root.isCheckpoint ? "#FFD700" : (root.theme ? root.theme.accent : "#D99B26"))
                }
            }

            Label {
                id: bannerLabel
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.text
                font.pixelSize: root.isZoneTransition ? units.gu(1.9) : units.gu(2.2)
                font.weight: Font.Black
                color: "#F5F3EF"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }
        }
    }
}
