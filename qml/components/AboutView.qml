import QtQuick 2.9
import Lomiri.Components 1.3

Column {
    id: root
    width: parent ? parent.width : units.gu(32)
    spacing: units.gu(1.1)

    property var theme: null

    signal backRequested()

    // Eyebrow Tag
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: eyebrowLabel.width + units.gu(2.0)
        height: units.gu(2.0)
        radius: units.gu(1.0)
        color: root.theme ? root.theme.accentBg : "#261E10"
        border.color: root.theme ? root.theme.accentBorder : "#544020"
        border.width: units.gu(0.1)

        Label {
            id: eyebrowLabel
            anchors.centerIn: parent
            text: i18n.tr("SYSTEM SPEC")
            font.pixelSize: units.gu(0.95)
            font.weight: Font.Bold
            color: root.theme ? root.theme.accent : "#D99B26"
        }
    }

    // Title Block
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: units.gu(0.2)

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n.tr("TOWER CRASH")
            font.pixelSize: units.gu(2.4)
            font.weight: Font.Black
            color: "#F5F3EF"
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n.tr("TACTILE HELICAL DESCENT")
            font.pixelSize: units.gu(1.0)
            font.weight: Font.DemiBold
            color: "#848890"
        }
    }

    // App Specs Card
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: specsCol.height + units.gu(2.0)
        radius: units.gu(1.4)
        color: root.theme ? root.theme.cardOuter : "#141517"
        border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
        border.width: units.gu(0.1)

        Column {
            id: specsCol
            anchors.centerIn: parent
            width: parent.width - units.gu(2.4)
            spacing: units.gu(0.8)

            Row {
                width: parent.width
                Label {
                    text: i18n.tr("Version")
                    font.pixelSize: units.gu(1.1)
                    color: "#848890"
                    width: parent.width / 2.0
                }
                Label {
                    text: "1.0.0"
                    font.pixelSize: units.gu(1.1)
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
                    font.pixelSize: units.gu(1.1)
                    color: "#848890"
                    width: parent.width / 2.0
                }
                Label {
                    text: "Ubuntu Touch (Lomiri)"
                    font.pixelSize: units.gu(1.1)
                    font.weight: Font.Bold
                    color: root.theme ? root.theme.accent : "#D99B26"
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
                    text: i18n.tr("Framework")
                    font.pixelSize: units.gu(1.1)
                    color: "#848890"
                    width: parent.width / 2.0
                }
                Label {
                    text: "ubuntu-touch-24.04-1.x"
                    font.pixelSize: units.gu(1.1)
                    font.weight: Font.DemiBold
                    color: "#F5F3EF"
                    horizontalAlignment: Text.AlignRight
                    width: parent.width / 2.0
                }
            }
        }
    }

    // Technology and Description Card
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: descCol.height + units.gu(2.0)
        radius: units.gu(1.4)
        color: root.theme ? root.theme.cardOuter : "#141517"
        border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
        border.width: units.gu(0.1)

        Column {
            id: descCol
            anchors.centerIn: parent
            width: parent.width - units.gu(2.4)
            spacing: units.gu(0.6)

            Label {
                text: i18n.tr("ARCHITECTURE & ENGINE")
                font.pixelSize: units.gu(0.9)
                font.weight: Font.Bold
                color: root.theme ? root.theme.accent : "#D99B26"
            }

            Label {
                text: i18n.tr("Pure QML (QtQuick 2.9) helical renderer, Lomiri Components 1.3, JavaScript collision and spring mechanics, and local SQLite state persistence.")
                font.pixelSize: units.gu(1.1)
                color: "#D6D5D2"
                wrapMode: Text.WordWrap
                width: parent.width
            }
        }
    }

    // Author & License Card
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: authorCol.height + units.gu(2.0)
        radius: units.gu(1.4)
        color: root.theme ? root.theme.cardOuter : "#141517"
        border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
        border.width: units.gu(0.1)

        Column {
            id: authorCol
            anchors.centerIn: parent
            width: parent.width - units.gu(2.4)
            spacing: units.gu(0.8)

            Row {
                width: parent.width
                Label {
                    text: i18n.tr("Author")
                    font.pixelSize: units.gu(1.1)
                    color: "#848890"
                    width: parent.width / 2.0
                }
                Label {
                    text: "Suraj Yadav"
                    font.pixelSize: units.gu(1.1)
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
                    font.pixelSize: units.gu(1.1)
                    color: "#848890"
                    width: parent.width / 2.0
                }
                Label {
                    text: "GPL-3.0-or-later"
                    font.pixelSize: units.gu(1.1)
                    font.weight: Font.Bold
                    color: "#F5F3EF"
                    horizontalAlignment: Text.AlignRight
                    width: parent.width / 2.0
                }
            }
        }
    }

    // Source Code Card (Interactive)
    Rectangle {
        id: sourceCard
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: units.gu(4.6)
        radius: units.gu(1.4)
        color: sourceMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardOuter : "#141517")
        border.color: sourceMouse.pressed
                      ? (root.theme ? root.theme.accent : "#D99B26")
                      : (root.theme ? root.theme.cardBorder : "#2A2C30")
        border.width: units.gu(0.1)
        scale: sourceMouse.pressed ? 0.98 : 1.0

        Behavior on scale { NumberAnimation { duration: 100 } }

        Row {
            anchors.centerIn: parent
            spacing: units.gu(0.8)

            Label {
                text: i18n.tr("Source Repository")
                font.pixelSize: units.gu(1.15)
                font.weight: Font.Bold
                color: root.theme ? root.theme.accent : "#D99B26"
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                text: "•  GitHub"
                font.pixelSize: units.gu(1.05)
                color: "#848890"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: sourceMouse
            anchors.fill: parent
            onClicked: {
                Qt.openUrlExternally("https://github.com/suraj-yadav0/tower-crash");
            }
        }
    }

    // Back Action Button
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
            text: i18n.tr("Back")
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
