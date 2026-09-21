import QtQuick 2.9
import Lomiri.Components 1.3

Rectangle {
    id: root

    property int score: 0
    property int bestScore: 0
    property int levelReached: 1
    property var theme: null

    signal restartRequested()
    signal mainMenuRequested()

    anchors.fill: parent
    color: "#E604070A"

    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    // Outer Shell (Double-Bezel architecture)
    Rectangle {
        id: outerShell
        anchors.centerIn: parent
        width: Math.min(parent.width - units.gu(4.0), units.gu(34))
        height: innerCore.height + units.gu(2.0)
        radius: units.gu(2.4)
        color: root.theme ? root.theme.cardOuter : "#0E141C"
        border.color: root.theme ? root.theme.topHazard : "#FF4757"
        border.width: units.gu(0.15)
        scale: root.visible ? 1.0 : 0.88
        opacity: root.visible ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation { duration: 240; easing.type: Easing.OutBack }
        }
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
        }

        // Inner Core
        Rectangle {
            id: innerCore
            anchors.centerIn: parent
            width: outerShell.width - units.gu(1.6)
            height: modalContent.height + units.gu(3.6)
            radius: units.gu(1.8)
            color: root.theme ? root.theme.cardInner : "#080C10"
            border.color: root.theme ? root.theme.cardBorder : "#16202C"
            border.width: units.gu(0.1)

            Column {
                id: modalContent
                anchors.centerIn: parent
                width: parent.width - units.gu(4.0)
                spacing: units.gu(1.3)

                // Eyebrow Tag
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: eyebrowLabel.width + units.gu(2.0)
                    height: units.gu(2.2)
                    radius: units.gu(1.1)
                    color: root.theme ? root.theme.cardOuter : "#261317"
                    border.color: root.theme ? root.theme.sideHazard : "#3D1D23"
                    border.width: units.gu(0.1)

                    Label {
                        id: eyebrowLabel
                        anchors.centerIn: parent
                        text: i18n.tr("DESCENT HALTED")
                        font.pixelSize: units.gu(1.0)
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.topHazard : "#FF6B81"
                    }
                }

                // Title
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: i18n.tr("GAME OVER")
                    font.pixelSize: units.gu(2.8)
                    font.weight: Font.Black
                    color: root.theme ? root.theme.topHazard : "#FF4757"
                }

                // Hero Final Score Bento Box
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(7.6)
                    radius: units.gu(1.4)
                    color: root.theme ? root.theme.cardOuter : "#0D131A"
                    border.color: root.theme ? root.theme.cardBorder : "#1E2A38"
                    border.width: units.gu(0.1)

                    Column {
                        anchors.centerIn: parent
                        spacing: units.gu(0.2)

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("FINAL SCORE")
                            font.pixelSize: units.gu(1.0)
                            font.weight: Font.DemiBold
                            color: "#64748B"
                        }

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.score.toString()
                            font.pixelSize: units.gu(3.8)
                            font.weight: Font.Black
                            color: "#FFFFFF"
                        }

                        // New Best badge if applicable
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: newBestLabel.width + units.gu(1.6)
                            height: units.gu(1.8)
                            radius: units.gu(0.9)
                            color: "#2E240D"
                            border.color: "#F59E0B"
                            border.width: units.gu(0.08)
                            visible: root.score > 0 && root.score >= root.bestScore

                            Label {
                                id: newBestLabel
                                anchors.centerIn: parent
                                text: i18n.tr("NEW BEST RECORD")
                                font.pixelSize: units.gu(0.9)
                                font.weight: Font.Bold
                                color: "#FBBF24"
                            }
                        }
                    }
                }

                // Bento Row: Best Score & Stage Reached
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    spacing: units.gu(1.0)

                    // Best Score Pill Card
                    Rectangle {
                        width: (parent.width - units.gu(1.0)) / 2.0
                        height: units.gu(4.8)
                        radius: units.gu(1.2)
                        color: root.theme ? root.theme.cardOuter : "#0D131A"
                        border.color: root.theme ? root.theme.cardBorder : "#1E2A38"
                        border.width: units.gu(0.1)

                        Column {
                            anchors.centerIn: parent
                            spacing: units.gu(0.1)

                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: i18n.tr("BEST RECORD")
                                font.pixelSize: units.gu(1.0)
                                font.weight: Font.DemiBold
                                color: "#64748B"
                            }

                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.bestScore.toString()
                                font.pixelSize: units.gu(1.8)
                                font.weight: Font.Bold
                                color: root.theme ? root.theme.ballMid : "#FBBF24"
                            }
                        }
                    }

                    // Level Reached Pill Card
                    Rectangle {
                        width: (parent.width - units.gu(1.0)) / 2.0
                        height: units.gu(4.8)
                        radius: units.gu(1.2)
                        color: root.theme ? root.theme.cardOuter : "#0D131A"
                        border.color: root.theme ? root.theme.cardBorder : "#1E2A38"
                        border.width: units.gu(0.1)

                        Column {
                            anchors.centerIn: parent
                            spacing: units.gu(0.1)

                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: i18n.tr("STAGE REACHED")
                                font.pixelSize: units.gu(1.0)
                                font.weight: Font.DemiBold
                                color: "#64748B"
                            }

                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: i18n.tr("Level %1").arg(root.levelReached)
                                font.pixelSize: units.gu(1.8)
                                font.weight: Font.Bold
                                color: root.theme ? root.theme.accent : "#00D2D3"
                            }
                        }
                    }
                }

                // Primary Action: Play Again
                Rectangle {
                    id: playAgainBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(5.0)
                    radius: units.gu(2.5)
                    color: playAgainMouse.pressed
                           ? (root.theme ? root.theme.accentHover : "#00B4B5")
                           : (root.theme ? root.theme.accent : "#00D2D3")
                    scale: playAgainMouse.pressed ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }

                    Label {
                        anchors.left: parent.left
                        anchors.leftMargin: units.gu(2.6)
                        anchors.verticalCenter: parent.verticalCenter
                        text: i18n.tr("Play Again")
                        font.pixelSize: units.gu(1.6)
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accentText : "#04070A"
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(0.8)
                        anchors.verticalCenter: parent.verticalCenter
                        width: units.gu(3.4)
                        height: units.gu(3.4)
                        radius: units.gu(1.7)
                        color: "#1A000000"

                        Canvas {
                            id: restartIconCanvas
                            anchors.centerIn: parent
                            width: units.gu(1.4)
                            height: units.gu(1.4)
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);
                                ctx.fillStyle = root.theme ? root.theme.accentText : "#04070A";
                                ctx.beginPath();
                                ctx.moveTo(width * 0.2, height * 0.1);
                                ctx.lineTo(width * 0.85, height * 0.5);
                                ctx.lineTo(width * 0.2, height * 0.9);
                                ctx.closePath();
                                ctx.fill();
                            }
                            Connections {
                                target: root
                                onThemeChanged: restartIconCanvas.requestPaint()
                            }
                        }
                    }

                    MouseArea {
                        id: playAgainMouse
                        anchors.fill: parent
                        onClicked: root.restartRequested()
                    }
                }

                // Secondary CTA: Main Menu
                Rectangle {
                    id: menuBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(4.4)
                    radius: units.gu(2.2)
                    color: menuMouse.pressed ? "#1E2A3A" : "#121A24"
                    border.color: root.theme ? root.theme.cardBorder : "#223142"
                    border.width: units.gu(0.12)
                    scale: menuMouse.pressed ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: i18n.tr("Main Menu")
                        font.pixelSize: units.gu(1.5)
                        font.weight: Font.DemiBold
                        color: "#94A3B8"
                    }

                    MouseArea {
                        id: menuMouse
                        anchors.fill: parent
                        onClicked: root.mainMenuRequested()
                    }
                }
            }
        }
    }
}
