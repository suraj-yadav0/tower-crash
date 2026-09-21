import QtQuick 2.9
import Lomiri.Components 1.3

Rectangle {
    id: root

    property int score: 0
    property int bestScore: 0
    property int levelReached: 1

    signal restartRequested()

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
        color: "#0E141C"
        border.color: "#FF4757"
        border.width: units.gu(0.15)

        // Inner Core
        Rectangle {
            id: innerCore
            anchors.centerIn: parent
            width: outerShell.width - units.gu(1.6)
            height: modalContent.height + units.gu(4.0)
            radius: units.gu(1.8)
            color: "#080C10"
            border.color: "#16202C"
            border.width: units.gu(0.1)

            Column {
                id: modalContent
                anchors.centerIn: parent
                width: parent.width - units.gu(4.0)
                spacing: units.gu(1.4)

                // Eyebrow Tag
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: eyebrowLabel.width + units.gu(2.0)
                    height: units.gu(2.2)
                    radius: units.gu(1.1)
                    color: "#261317"
                    border.color: "#3D1D23"
                    border.width: units.gu(0.1)

                    Label {
                        id: eyebrowLabel
                        anchors.centerIn: parent
                        text: i18n.tr("DESCENT HALTED")
                        font.pixelSize: units.gu(1.0)
                        font.weight: Font.Bold
                        color: "#FF6B81"
                    }
                }

                // Title
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: i18n.tr("GAME OVER")
                    font.pixelSize: units.gu(3.0)
                    font.weight: Font.Black
                    color: "#FF4757"
                }

                // Hero Final Score Bento Box
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(8.0)
                    radius: units.gu(1.4)
                    color: "#0D131A"
                    border.color: "#1E2A38"
                    border.width: units.gu(0.1)

                    Column {
                        anchors.centerIn: parent
                        spacing: units.gu(0.2)

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("FINAL SCORE")
                            font.pixelSize: units.gu(1.1)
                            font.weight: Font.DemiBold
                            color: "#64748B"
                        }

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.score.toString()
                            font.pixelSize: units.gu(4.0)
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
                        color: "#0D131A"
                        border.color: "#1E2A38"
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
                                color: "#FBBF24"
                            }
                        }
                    }

                    // Level Reached Pill Card
                    Rectangle {
                        width: (parent.width - units.gu(1.0)) / 2.0
                        height: units.gu(4.8)
                        radius: units.gu(1.2)
                        color: "#0D131A"
                        border.color: "#1E2A38"
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
                                color: "#00D2D3"
                            }
                        }
                    }
                }

                // Primary Action: Play Again (Button-in-Button Pattern)
                Rectangle {
                    id: playAgainBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(5.0)
                    radius: units.gu(2.5)
                    color: playAgainMouse.pressed ? "#0D9668" : "#10B981"
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
                        color: "#FFFFFF"
                    }

                    // Trailing icon circle wrapper
                    Rectangle {
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(0.8)
                        anchors.verticalCenter: parent.verticalCenter
                        width: units.gu(3.4)
                        height: units.gu(3.4)
                        radius: units.gu(1.7)
                        color: "#26000000"

                        Canvas {
                            anchors.centerIn: parent
                            width: units.gu(1.4)
                            height: units.gu(1.4)
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);
                                ctx.fillStyle = "#FFFFFF";
                                ctx.beginPath();
                                ctx.moveTo(width * 0.2, height * 0.1);
                                ctx.lineTo(width * 0.85, height * 0.5);
                                ctx.lineTo(width * 0.2, height * 0.9);
                                ctx.closePath();
                                ctx.fill();
                            }
                        }
                    }

                    MouseArea {
                        id: playAgainMouse
                        anchors.fill: parent
                        onClicked: root.restartRequested()
                    }
                }
            }
        }
    }
}
