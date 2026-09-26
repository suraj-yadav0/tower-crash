import QtQuick 2.9
import Lomiri.Components 1.3

Column {
    id: root
    width: parent ? parent.width : units.gu(32)
    spacing: units.gu(1.2)

    property var theme: null

    signal backRequested()

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: i18n.tr("FLIGHT MANUAL")
        font.pixelSize: units.gu(2.0)
        font.weight: Font.Black
        color: root.theme ? root.theme.accent : "#D99B26"
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: instructionsCol.height + units.gu(2.4)
        radius: units.gu(1.4)
        color: root.theme ? root.theme.cardOuter : "#141517"
        border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
        border.width: units.gu(0.1)

        Column {
            id: instructionsCol
            anchors.centerIn: parent
            width: parent.width - units.gu(2.4)
            spacing: units.gu(0.9)

            Row {
                spacing: units.gu(1.0)
                width: parent.width

                Rectangle {
                    width: units.gu(2.0)
                    height: units.gu(2.0)
                    radius: units.gu(1.0)
                    color: root.theme ? root.theme.accent : "#D99B26"
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        anchors.centerIn: parent
                        text: "1"
                        font.pixelSize: units.gu(1.1)
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accentText : "#0B0C0D"
                    }
                }

                Label {
                    text: i18n.tr("Drag horizontally to rotate the helical tower.")
                    font.pixelSize: units.gu(1.2)
                    color: "#D6D5D2"
                    wrapMode: Text.WordWrap
                    width: parent.width - units.gu(3.0)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: units.gu(1.0)
                width: parent.width

                Rectangle {
                    width: units.gu(2.0)
                    height: units.gu(2.0)
                    radius: units.gu(1.0)
                    color: root.theme ? root.theme.accent : "#D99B26"
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        anchors.centerIn: parent
                        text: "2"
                        font.pixelSize: units.gu(1.1)
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accentText : "#0B0C0D"
                    }
                }

                Label {
                    text: i18n.tr("Drop through ring gaps to gain gravity momentum.")
                    font.pixelSize: units.gu(1.2)
                    color: "#D6D5D2"
                    wrapMode: Text.WordWrap
                    width: parent.width - units.gu(3.0)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: units.gu(1.0)
                width: parent.width

                Rectangle {
                    width: units.gu(2.0)
                    height: units.gu(2.0)
                    radius: units.gu(1.0)
                    color: root.theme ? root.theme.topHazard : "#BA3C3C"
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        anchors.centerIn: parent
                        text: "!"
                        font.pixelSize: units.gu(1.1)
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }
                }

                Label {
                    text: i18n.tr("Avoid landing directly on hazard zones.")
                    font.pixelSize: units.gu(1.2)
                    color: root.theme ? root.theme.topHazard : "#BA3C3C"
                    wrapMode: Text.WordWrap
                    width: parent.width - units.gu(3.0)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: units.gu(1.0)
                width: parent.width

                Rectangle {
                    width: units.gu(2.0)
                    height: units.gu(2.0)
                    radius: units.gu(1.0)
                    color: root.theme ? root.theme.ballMid : "#E6D7BA"
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        anchors.centerIn: parent
                        text: "3"
                        font.pixelSize: units.gu(1.1)
                        font.weight: Font.Bold
                        color: "#0B0C0D"
                    }
                }

                Label {
                    text: i18n.tr("Drop past 3 continuous rings to smash platforms!")
                    font.pixelSize: units.gu(1.2)
                    color: root.theme ? root.theme.ballMid : "#E6D7BA"
                    wrapMode: Text.WordWrap
                    width: parent.width - units.gu(3.0)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: units.gu(1.0)
                width: parent.width

                Rectangle {
                    width: units.gu(2.0)
                    height: units.gu(2.0)
                    radius: units.gu(1.0)
                    color: root.theme ? root.theme.accent : "#D99B26"
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        anchors.centerIn: parent
                        text: "10"
                        font.pixelSize: units.gu(0.9)
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accentText : "#0B0C0D"
                    }
                }

                Label {
                    text: i18n.tr("Descend through 10 thematic zones across 100 tower levels.")
                    font.pixelSize: units.gu(1.2)
                    color: "#D6D5D2"
                    wrapMode: Text.WordWrap
                    width: parent.width - units.gu(3.0)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    Rectangle {
        id: backBtn
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: units.gu(4.4)
        radius: units.gu(2.2)
        color: backMouse.pressed
               ? (root.theme ? root.theme.accentHover : "#BF8419")
               : (root.theme ? root.theme.accent : "#D99B26")
        scale: backMouse.pressed ? 0.95 : 1.0

        Behavior on scale {
            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
        }

        Label {
            anchors.centerIn: parent
            text: i18n.tr("Back to Main")
            font.pixelSize: units.gu(1.5)
            font.weight: Font.Bold
            color: root.theme ? root.theme.accentText : "#0B0C0D"
        }

        MouseArea {
            id: backMouse
            anchors.fill: parent
            onClicked: root.backRequested()
        }
    }
}
