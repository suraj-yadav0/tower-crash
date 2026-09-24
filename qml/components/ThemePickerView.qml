import QtQuick 2.9
import Lomiri.Components 1.3
import "../js/Themes.js" as Themes

Column {
    id: root
    width: parent ? parent.width : units.gu(32)
    spacing: units.gu(1.1)

    property var theme: null
    property int themeMode: 0

    signal themeModeSelected(int newMode)
    signal doneRequested()

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: pickerEyebrowLabel.width + units.gu(2.0)
        height: units.gu(2.0)
        radius: units.gu(1.0)
        color: root.theme ? root.theme.accentBg : "#261E10"
        border.color: root.theme ? root.theme.accentBorder : "#544020"
        border.width: units.gu(0.1)

        Label {
            id: pickerEyebrowLabel
            anchors.centerIn: parent
            text: i18n.tr("COLOR SCHEMES")
            font.pixelSize: units.gu(0.95)
            font.weight: Font.Bold
            color: root.theme ? root.theme.accent : "#D99B26"
        }
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: i18n.tr("MATERIAL PALETTES")
        font.pixelSize: units.gu(2.2)
        font.weight: Font.Black
        color: "#F5F3EF"
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: i18n.tr("Select a color palette for tower rings and visuals")
        font.pixelSize: units.gu(0.9)
        font.weight: Font.Medium
        color: "#848890"
        horizontalAlignment: Text.AlignHCenter
    }

    Rectangle {
        id: pickerCard
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: pickerGridCol.height + units.gu(1.8)
        radius: units.gu(1.4)
        color: root.theme ? root.theme.cardOuter : "#141517"
        border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
        border.width: units.gu(0.1)

        Column {
            id: pickerGridCol
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - units.gu(2.0)
            spacing: units.gu(0.6)

            Grid {
                id: pickerGrid
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 3
                spacing: units.gu(0.5)

                Repeater {
                    model: Themes.themeOptions
                    delegate: Rectangle {
                        width: (pickerGridCol.width - units.gu(1.0)) / 3.0
                        height: units.gu(2.8)
                        radius: units.gu(1.4)
                        color: root.themeMode === modelData.id
                               ? (root.theme ? root.theme.accentBg : "#261E10")
                               : (chipMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardInner : "#0D0E0F"))
                        border.color: root.themeMode === modelData.id
                                      ? (root.theme ? root.theme.accent : "#D99B26")
                                      : (root.theme ? root.theme.cardBorder : "#2A2C30")
                        border.width: root.themeMode === modelData.id ? units.gu(0.14) : units.gu(0.08)
                        scale: chipMouse.pressed ? 0.94 : 1.0

                        Behavior on scale { NumberAnimation { duration: 100 } }

                        Row {
                            anchors.centerIn: parent
                            spacing: units.gu(0.4)

                            Rectangle {
                                width: units.gu(0.8)
                                height: units.gu(0.8)
                                radius: width / 2
                                color: modelData.previewColor
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: modelData.name
                                font.pixelSize: units.gu(1.0)
                                font.weight: root.themeMode === modelData.id ? Font.Bold : Font.DemiBold
                                color: root.themeMode === modelData.id
                                       ? (root.theme ? root.theme.accent : "#D99B26")
                                       : "#8E929A"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: chipMouse
                            anchors.fill: parent
                            onClicked: root.themeModeSelected(modelData.id)
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: pickerDoneBtn
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: units.gu(4.4)
        radius: units.gu(2.2)
        color: pickerDoneMouse.pressed
               ? (root.theme ? root.theme.accentHover : "#BF8419")
               : (root.theme ? root.theme.accent : "#D99B26")
        scale: pickerDoneMouse.pressed ? 0.95 : 1.0

        Behavior on scale {
            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
        }

        Label {
            anchors.centerIn: parent
            text: i18n.tr("Done")
            font.pixelSize: units.gu(1.4)
            font.weight: Font.Bold
            color: root.theme ? root.theme.accentText : "#0B0C0D"
        }

        MouseArea {
            id: pickerDoneMouse
            anchors.fill: parent
            onClicked: root.doneRequested()
        }
    }

    Item {
        width: parent.width
        height: units.gu(0.4)
    }
}
