import QtQuick 2.9
import Lomiri.Components 1.3

Rectangle {
    id: root

    property int bestScore: 0
    property int totalRings: 0
    property int speedMode: 1
    property bool showingHowToPlay: false
    property var theme: null
    property string themeName: ""

    signal playRequested()
    signal settingsRequested()
    signal themeCycleRequested()
    signal speedCycleRequested()

    anchors.fill: parent
    color: "#D904070A"
    visible: false
    z: 150

    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    Rectangle {
        id: outerShell
        anchors.centerIn: parent
        width: Math.min(parent.width - units.gu(4.0), units.gu(36))
        height: innerCore.height + units.gu(2.0)
        radius: units.gu(2.4)
        color: root.theme ? root.theme.cardOuter : "#0E141C"
        border.color: root.theme ? root.theme.cardBorder : "#223142"
        border.width: units.gu(0.15)
        scale: root.visible ? 1.0 : 0.88
        opacity: root.visible ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation { duration: 220; easing.type: Easing.OutBack }
        }
        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
        }

        Rectangle {
            id: innerCore
            anchors.centerIn: parent
            width: outerShell.width - units.gu(1.6)
            height: root.showingHowToPlay ? (howToPlayContent.height + units.gu(3.6)) : (menuContent.height + units.gu(3.6))
            radius: units.gu(1.8)
            color: root.theme ? root.theme.cardInner : "#080C10"
            border.color: root.theme ? root.theme.cardBorder : "#16202C"
            border.width: units.gu(0.1)

            Behavior on height {
                NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
            }

            // Main Menu View
            Column {
                id: menuContent
                anchors.centerIn: parent
                width: parent.width - units.gu(4.0)
                spacing: units.gu(1.3)
                visible: !root.showingHowToPlay

                // Arcade Badge
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: arcadeBadgeLabel.width + units.gu(2.2)
                    height: units.gu(2.2)
                    radius: units.gu(1.1)
                    color: root.theme ? root.theme.accentBg : "#162230"
                    border.color: root.theme ? root.theme.accentBorder : "#243447"
                    border.width: units.gu(0.1)

                    Label {
                        id: arcadeBadgeLabel
                        anchors.centerIn: parent
                        text: i18n.tr("UBUNTU TOUCH EDITION")
                        font.pixelSize: units.gu(0.95)
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accent : "#00D2D3"
                    }
                }

                // Title Banner
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: units.gu(0.2)

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: i18n.tr("TOWER CRASH")
                        font.pixelSize: units.gu(3.0)
                        font.weight: Font.Black
                        color: "#FFFFFF"
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: i18n.tr("SPIRAL BALL JUMP")
                        font.pixelSize: units.gu(1.1)
                        font.weight: Font.DemiBold
                        color: "#64748B"
                    }
                }

                // Primary CTA: Play Game
                Rectangle {
                    id: playBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(5.4)
                    radius: units.gu(2.7)
                    color: playMouse.pressed
                           ? (root.theme ? root.theme.accentHover : "#00B4B5")
                           : (root.theme ? root.theme.accent : "#00D2D3")
                    scale: playMouse.pressed ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: units.gu(1.2)

                        // Play Triangle Icon
                        Canvas {
                            id: playIconCanvas
                            width: units.gu(1.6)
                            height: units.gu(1.6)
                            anchors.verticalCenter: parent.verticalCenter
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);
                                ctx.fillStyle = root.theme ? root.theme.accentText : "#04070A";
                                ctx.beginPath();
                                ctx.moveTo(width * 0.15, height * 0.05);
                                ctx.lineTo(width * 0.9, height * 0.5);
                                ctx.lineTo(width * 0.15, height * 0.95);
                                ctx.closePath();
                                ctx.fill();
                            }
                            Connections {
                                target: root
                                onThemeChanged: playIconCanvas.requestPaint()
                            }
                        }

                        Label {
                            text: i18n.tr("START GAME")
                            font.pixelSize: units.gu(1.8)
                            font.weight: Font.Black
                            color: root.theme ? root.theme.accentText : "#04070A"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: playMouse
                        anchors.fill: parent
                        onClicked: root.playRequested()
                    }
                }

                // Secondary Action Row: Settings & How to Play
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    spacing: units.gu(1.0)

                    // Settings Button
                    Rectangle {
                        id: settingsBtn
                        width: (parent.width - units.gu(1.0)) / 2.0
                        height: units.gu(4.4)
                        radius: units.gu(2.2)
                        color: settingsMouse.pressed ? "#1E2A3A" : "#121A24"
                        border.color: root.theme ? root.theme.cardBorder : "#223142"
                        border.width: units.gu(0.12)
                        scale: settingsMouse.pressed ? 0.94 : 1.0

                        Behavior on scale {
                            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                        }

                        Label {
                            anchors.centerIn: parent
                            text: i18n.tr("Settings")
                            font.pixelSize: units.gu(1.4)
                            font.weight: Font.Bold
                            color: "#E2E8F0"
                        }

                        MouseArea {
                            id: settingsMouse
                            anchors.fill: parent
                            onClicked: root.settingsRequested()
                        }
                    }

                    // How to Play Button
                    Rectangle {
                        id: guideBtn
                        width: (parent.width - units.gu(1.0)) / 2.0
                        height: units.gu(4.4)
                        radius: units.gu(2.2)
                        color: guideMouse.pressed ? "#1E2A3A" : "#121A24"
                        border.color: root.theme ? root.theme.cardBorder : "#223142"
                        border.width: units.gu(0.12)
                        scale: guideMouse.pressed ? 0.94 : 1.0

                        Behavior on scale {
                            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                        }

                        Label {
                            anchors.centerIn: parent
                            text: i18n.tr("How to Play")
                            font.pixelSize: units.gu(1.4)
                            font.weight: Font.Bold
                            color: "#E2E8F0"
                        }

                        MouseArea {
                            id: guideMouse
                            anchors.fill: parent
                            onClicked: root.showingHowToPlay = true
                        }
                    }
                }

                // Quick Setup Row: Theme & Speed Toggles
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    spacing: units.gu(1.0)

                    // Quick Theme Switcher
                    Rectangle {
                        width: (parent.width - units.gu(1.0)) / 2.0
                        height: units.gu(3.8)
                        radius: units.gu(1.9)
                        color: themeMouse.pressed ? "#1E2A3A" : "#121A24"
                        border.color: root.theme ? root.theme.cardBorder : "#223142"
                        border.width: units.gu(0.1)
                        scale: themeMouse.pressed ? 0.94 : 1.0

                        Behavior on scale {
                            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: units.gu(0.7)

                            Rectangle {
                                width: units.gu(0.9)
                                height: units.gu(0.9)
                                radius: width / 2
                                color: root.theme ? (root.theme.previewColor || root.theme.accent) : "#00D2D3"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: root.themeName.length > 0 ? root.themeName : i18n.tr("Theme")
                                font.pixelSize: units.gu(1.1)
                                font.weight: Font.DemiBold
                                color: "#E2E8F0"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: themeMouse
                            anchors.fill: parent
                            onClicked: root.themeCycleRequested()
                        }
                    }

                    // Quick Speed Switcher
                    Rectangle {
                        width: (parent.width - units.gu(1.0)) / 2.0
                        height: units.gu(3.8)
                        radius: units.gu(1.9)
                        color: speedMouse.pressed ? "#1E2A3A" : "#121A24"
                        border.color: root.theme ? root.theme.cardBorder : "#223142"
                        border.width: units.gu(0.1)
                        scale: speedMouse.pressed ? 0.94 : 1.0

                        Behavior on scale {
                            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: units.gu(0.6)

                            Label {
                                text: i18n.tr("Speed: %1").arg(root.speedMode === 0 ? i18n.tr("Slow") : (root.speedMode === 2 ? i18n.tr("Fast") : i18n.tr("Normal")))
                                font.pixelSize: units.gu(1.1)
                                font.weight: Font.DemiBold
                                color: "#E2E8F0"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: speedMouse
                            anchors.fill: parent
                            onClicked: root.speedCycleRequested()
                        }
                    }
                }

                // Player Records Bento Card
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(5.0)
                    radius: units.gu(1.4)
                    color: root.theme ? root.theme.cardOuter : "#0E141C"
                    border.color: root.theme ? root.theme.cardBorder : "#223142"
                    border.width: units.gu(0.1)

                    Row {
                        anchors.fill: parent

                        // Best Score
                        Item {
                            width: parent.width / 2.0
                            height: parent.height

                            Column {
                                anchors.centerIn: parent
                                spacing: units.gu(0.2)

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: i18n.tr("BEST SCORE")
                                    font.pixelSize: units.gu(0.85)
                                    font.weight: Font.Bold
                                    color: "#64748B"
                                }

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.bestScore.toString()
                                    font.pixelSize: units.gu(1.5)
                                    font.weight: Font.Black
                                    color: root.theme ? root.theme.ballMid : "#FFD166"
                                }
                            }
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: units.dp(1)
                            height: parent.height - units.gu(1.6)
                            color: "#1E2A3A"
                        }

                        // Total Rings Passed
                        Item {
                            width: parent.width / 2.0
                            height: parent.height

                            Column {
                                anchors.centerIn: parent
                                spacing: units.gu(0.2)

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: i18n.tr("RINGS CRASHED")
                                    font.pixelSize: units.gu(0.85)
                                    font.weight: Font.Bold
                                    color: "#64748B"
                                }

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.totalRings.toString()
                                    font.pixelSize: units.gu(1.5)
                                    font.weight: Font.Black
                                    color: root.theme ? root.theme.accent : "#00D2D3"
                                }
                            }
                        }
                    }
                }
            }

            // How to Play View
            Column {
                id: howToPlayContent
                anchors.centerIn: parent
                width: parent.width - units.gu(4.0)
                spacing: units.gu(1.2)
                visible: root.showingHowToPlay

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: i18n.tr("HOW TO PLAY")
                    font.pixelSize: units.gu(2.2)
                    font.weight: Font.Black
                    color: root.theme ? root.theme.accent : "#00D2D3"
                }

                // Instructions Card
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: instructionsCol.height + units.gu(2.4)
                    radius: units.gu(1.4)
                    color: root.theme ? root.theme.cardOuter : "#0E141C"
                    border.color: root.theme ? root.theme.cardBorder : "#223142"
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
                                color: root.theme ? root.theme.accent : "#00D2D3"
                                anchors.verticalCenter: parent.verticalCenter

                                Label {
                                    anchors.centerIn: parent
                                    text: "1"
                                    font.pixelSize: units.gu(1.1)
                                    font.weight: Font.Bold
                                    color: root.theme ? root.theme.accentText : "#04070A"
                                }
                            }

                            Label {
                                text: i18n.tr("Swipe left or right to rotate the tower.")
                                font.pixelSize: units.gu(1.2)
                                color: "#E2E8F0"
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
                                color: root.theme ? root.theme.accent : "#00D2D3"
                                anchors.verticalCenter: parent.verticalCenter

                                Label {
                                    anchors.centerIn: parent
                                    text: "2"
                                    font.pixelSize: units.gu(1.1)
                                    font.weight: Font.Bold
                                    color: root.theme ? root.theme.accentText : "#04070A"
                                }
                            }

                            Label {
                                text: i18n.tr("Drop through openings to descend levels.")
                                font.pixelSize: units.gu(1.2)
                                color: "#E2E8F0"
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
                                color: root.theme ? root.theme.topHazard : "#FF4757"
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
                                text: i18n.tr("Avoid landing on red hazard segments.")
                                font.pixelSize: units.gu(1.2)
                                color: "#FF6B81"
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
                                color: root.theme ? root.theme.ballMid : "#FFD166"
                                anchors.verticalCenter: parent.verticalCenter

                                Label {
                                    anchors.centerIn: parent
                                    text: "3"
                                    font.pixelSize: units.gu(1.1)
                                    font.weight: Font.Bold
                                    color: "#04070A"
                                }
                            }

                            Label {
                                text: i18n.tr("Pass 3 rings in one drop to smash platforms!")
                                font.pixelSize: units.gu(1.2)
                                color: root.theme ? root.theme.ballMid : "#FFD166"
                                wrapMode: Text.WordWrap
                                width: parent.width - units.gu(3.0)
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                // Back Button
                Rectangle {
                    id: backBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(4.4)
                    radius: units.gu(2.2)
                    color: backMouse.pressed
                           ? (root.theme ? root.theme.accentHover : "#00B4B5")
                           : (root.theme ? root.theme.accent : "#00D2D3")
                    scale: backMouse.pressed ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: i18n.tr("Back to Menu")
                        font.pixelSize: units.gu(1.5)
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accentText : "#04070A"
                    }

                    MouseArea {
                        id: backMouse
                        anchors.fill: parent
                        onClicked: root.showingHowToPlay = false
                    }
                }
            }
        }
    }
}
