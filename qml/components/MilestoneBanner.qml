import QtQuick 2.9
import Lomiri.Components 1.3

Item {
    id: root

    property string text: ""
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
        width: innerCore.width + units.gu(1.2)
        height: innerCore.height + units.gu(1.2)
        radius: units.gu(2.4)
        color: root.theme ? root.theme.accentBg : "#261E10"
        border.color: root.theme ? root.theme.accent : "#D99B26"
        border.width: units.gu(0.15)
        scale: Math.min(1.0, 0.85 + 0.15 * root.bannerOpacity)

        Rectangle {
            id: innerCore
            anchors.centerIn: parent
            width: contentCol.width + units.gu(3.6)
            height: contentCol.height + units.gu(2.0)
            radius: units.gu(1.8)
            color: root.theme ? root.theme.cardInner : "#0D0E0F"
            border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
            border.width: units.gu(0.08)

            Column {
                id: contentCol
                anchors.centerIn: parent
                spacing: units.gu(0.3)

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: stageTag.width + units.gu(1.6)
                    height: units.gu(1.8)
                    radius: units.gu(0.9)
                    color: root.theme ? root.theme.accentBg : "#261E10"

                    Label {
                        id: stageTag
                        anchors.centerIn: parent
                        text: i18n.tr("STAGE COMPLETED")
                        font.pixelSize: units.gu(1.0)
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accent : "#D99B26"
                    }
                }

                Label {
                    id: bannerLabel
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.text
                    font.pixelSize: units.gu(2.2)
                    font.weight: Font.Black
                    color: "#F5F3EF"
                }
            }
        }
    }
}
