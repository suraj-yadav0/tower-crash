import QtQuick 2.9
import Lomiri.Components 1.3

Column {
    id: root
    width: parent ? parent.width : units.gu(32)
    spacing: units.gu(1.2)

    property var theme: null

    signal backRequested()

    // Title Block
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: units.gu(0.4)

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n.tr("Tower Crash")
            font.pixelSize: units.gu(2.6)
            font.weight: Font.Black
            color: "#F5F3EF"
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n.tr("Spiral ball jump game for Ubuntu Touch")
            textSize: Label.Medium
            font.weight: Font.Normal
            color: "#848890"
        }
    }

    // App Info Card
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: specsCol.height + units.gu(2.4)
        radius: units.gu(1.6)
        color: root.theme ? root.theme.cardOuter : "#141517"
        border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
        border.width: units.gu(0.1)

        Column {
            id: specsCol
            anchors.centerIn: parent
            width: parent.width - units.gu(2.4)
            spacing: units.gu(1.0)

            Row {
                width: parent.width
                Label {
                    text: i18n.tr("Version")
                    font.pixelSize: units.gu(1.2)
                    color: "#848890"
                    width: parent.width / 2.0
                }
                Label {
                    text: "1.0.0"
                    font.pixelSize: units.gu(1.2)
                    font.weight: Font.Bold
                    color: "#F5F3EF"
                    horizontalAlignment: Text.AlignRight
                    width: parent.width / 2.0
                }
            }

            Rectangle {
                width: parent.width
                height: units.dp(1)
                color: root.theme ? root.theme.cardBorder : "#2A2C30"
            }

            Row {
                width: parent.width
                Label {
                    text: i18n.tr("Author")
                    font.pixelSize: units.gu(1.2)
                    color: "#848890"
                    width: parent.width / 2.0
                }
                Label {
                    text: "Suraj Yadav"
                    font.pixelSize: units.gu(1.2)
                    font.weight: Font.Bold
                    color: "#F5F3EF"
                    horizontalAlignment: Text.AlignRight
                    width: parent.width / 2.0
                }
            }

            Rectangle {
                width: parent.width
                height: units.dp(1)
                color: root.theme ? root.theme.cardBorder : "#2A2C30"
            }

            Row {
                width: parent.width
                Label {
                    text: i18n.tr("License")
                    font.pixelSize: units.gu(1.2)
                    color: "#848890"
                    width: parent.width / 2.0
                }
                Label {
                    text: "GPL-3.0-or-later"
                    font.pixelSize: units.gu(1.2)
                    font.weight: Font.Bold
                    color: "#F5F3EF"
                    horizontalAlignment: Text.AlignRight
                    width: parent.width / 2.0
                }
            }

            Rectangle {
                width: parent.width
                height: units.dp(1)
                color: root.theme ? root.theme.cardBorder : "#2A2C30"
            }

            Row {
                width: parent.width
                Label {
                    text: i18n.tr("Platform")
                    font.pixelSize: units.gu(1.2)
                    color: "#848890"
                    width: parent.width / 2.0
                }
                Label {
                    text: "Ubuntu Touch (Lomiri)"
                    font.pixelSize: units.gu(1.2)
                    font.weight: Font.Bold
                    color: root.theme ? root.theme.accent : "#D99B26"
                    horizontalAlignment: Text.AlignRight
                    width: parent.width / 2.0
                }
            }
        }
    }

    // GitHub Star Support Card
    Rectangle {
        id: starCard
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: starCol.height + units.gu(2.6)
        radius: units.gu(1.6)
        color: root.theme ? root.theme.cardOuter : "#141517"
        border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
        border.width: units.gu(0.1)

        Column {
            id: starCol
            anchors.centerIn: parent
            width: parent.width - units.gu(2.4)
            spacing: units.gu(1.0)

            Label {
                text: i18n.tr("If you enjoy playing Tower Crash, consider giving it a star on GitHub. It helps other Ubuntu Touch users find the game and supports independent open-source development.")
                font.pixelSize: units.gu(1.15)
                color: "#D6D5D2"
                wrapMode: Text.WordWrap
                width: parent.width
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: units.gu(4.4)
                radius: units.gu(2.2)
                color: starMouse.pressed ? "#1E2024" : (root.theme ? root.theme.accentBg : "#261E10")
                border.color: starMouse.pressed
                              ? (root.theme ? root.theme.accent : "#D99B26")
                              : (root.theme ? root.theme.accentBorder : "#544020")
                border.width: units.gu(0.1)
                scale: starMouse.pressed ? 0.97 : 1.0

                Behavior on scale { NumberAnimation { duration: 100 } }

                Row {
                    anchors.centerIn: parent
                    spacing: units.gu(0.8)

                    Label {
                        text: i18n.tr("Star on GitHub")
                        font.pixelSize: units.gu(1.25)
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accent : "#D99B26"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Label {
                        text: "•  github.com/suraj-yadav0/tower-crash"
                        textSize: Label.Small
                        color: "#848890"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: starMouse
                    anchors.fill: parent
                    onClicked: {
                        Qt.openUrlExternally("https://github.com/suraj-yadav0/tower-crash");
                    }
                }
            }
        }
    }

    // Back Action Button
    Rectangle {
        id: backBtn
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: units.gu(5.0)
        radius: units.gu(2.5)
        color: backMouse.pressed
               ? (root.theme ? root.theme.accentHover : "#BF8419")
               : (root.theme ? root.theme.accent : "#D99B26")
        scale: backMouse.pressed ? 0.95 : 1.0

        Behavior on scale {
            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
        }

        Label {
            anchors.centerIn: parent
            text: i18n.tr("Back")
            font.pixelSize: units.gu(1.55)
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
