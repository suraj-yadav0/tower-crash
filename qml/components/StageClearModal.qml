import QtQuick 2.9
import Lomiri.Components 1.3

Rectangle {
    id: root

    property int stageNumber: 1
    property int score: 0
    property int bonusPoints: 100
    property int streak: 0
    property bool isCheckpoint: false
    property int nextCheckpoint: 1
    property int checkpointLevel: 1
    property bool isGrandVictory: false
    property var theme: null

    signal continueRequested()
    signal restartRequested()
    signal restartStageOneRequested()
    signal mainMenuRequested()

    anchors.fill: parent
    color: "#E608090A"

    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    Rectangle {
        id: outerShell
        anchors.centerIn: parent
        width: Math.min(parent.width - units.gu(4.0), units.gu(34))
        height: innerCore.height + units.gu(2.0)
        radius: units.gu(2.0)
        color: root.theme ? root.theme.cardOuter : "#141517"
        border.color: root.isGrandVictory
                      ? "#FFD700"
                      : (root.isCheckpoint ? (root.theme ? root.theme.accent : "#D99B26")
                                           : (root.theme ? root.theme.topSafe : "#2EAA58"))
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
            height: modalContent.height + units.gu(3.6)
            radius: units.gu(1.6)
            color: root.theme ? root.theme.cardInner : "#0D0E0F"
            border.color: root.theme ? root.theme.cardBorder : "#222428"
            border.width: units.gu(0.1)

            Column {
                id: modalContent
                anchors.centerIn: parent
                width: parent.width - units.gu(4.0)
                spacing: units.gu(1.1)

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: eyebrowLabel.width + units.gu(2.0)
                    height: units.gu(2.2)
                    radius: units.gu(1.1)
                    color: root.theme ? root.theme.cardOuter : "#141517"
                    border.color: root.isGrandVictory
                                  ? "#FFD700"
                                  : (root.isCheckpoint ? (root.theme ? root.theme.accent : "#D99B26")
                                                       : (root.theme ? root.theme.topSafe : "#2EAA58"))
                    border.width: units.gu(0.1)

                    Label {
                        id: eyebrowLabel
                        anchors.centerIn: parent
                        text: root.isGrandVictory
                              ? i18n.tr("CAMPAIGN COMPLETE")
                              : (root.isCheckpoint ? i18n.tr("CHECKPOINT REACHED") : i18n.tr("MILESTONE CLEARED"))
                        font.pixelSize: units.gu(1.0)
                        font.weight: Font.Bold
                        color: root.isGrandVictory
                               ? "#FFD700"
                               : (root.isCheckpoint ? (root.theme ? root.theme.accent : "#D99B26")
                                                    : (root.theme ? root.theme.topSafe : "#2EAA58"))
                    }
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.isGrandVictory
                          ? i18n.tr("TOWER CONQUERED")
                          : i18n.tr("STAGE %1 CLEARED").arg(root.stageNumber)
                    font.pixelSize: units.gu(2.6)
                    font.weight: Font.Black
                    color: "#F5F3EF"
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(7.2)
                    radius: units.gu(1.4)
                    color: root.theme ? root.theme.cardOuter : "#141517"
                    border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                    border.width: units.gu(0.1)

                    Column {
                        anchors.centerIn: parent
                        spacing: units.gu(0.2)

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("TOTAL SCORE")
                            font.pixelSize: units.gu(1.0)
                            font.weight: Font.DemiBold
                            color: "#848890"
                        }

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.score.toString()
                            font.pixelSize: units.gu(3.4)
                            font.weight: Font.Black
                            color: "#F5F3EF"
                        }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: bonusLabel.width + units.gu(1.6)
                            height: units.gu(1.8)
                            radius: units.gu(0.9)
                            color: root.theme ? root.theme.accentBg : "#261E10"
                            border.color: root.theme ? root.theme.accent : "#D99B26"
                            border.width: units.gu(0.08)

                            Label {
                                id: bonusLabel
                                anchors.centerIn: parent
                                text: i18n.tr("+%1 STAGE BONUS").arg(root.bonusPoints)
                                font.pixelSize: units.gu(0.85)
                                font.weight: Font.Bold
                                color: root.theme ? root.theme.accent : "#D99B26"
                            }
                        }
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    spacing: units.gu(1.0)

                    Rectangle {
                        width: (parent.width - units.gu(1.0)) / 2.0
                        height: units.gu(4.8)
                        radius: units.gu(1.2)
                        color: root.theme ? root.theme.cardOuter : "#141517"
                        border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                        border.width: units.gu(0.1)

                        Column {
                            anchors.centerIn: parent
                            spacing: units.gu(0.1)

                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: i18n.tr("STREAK")
                                font.pixelSize: units.gu(0.95)
                                font.weight: Font.DemiBold
                                color: "#848890"
                            }

                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.streak > 0 ? (root.streak.toString() + "x") : "-"
                                font.pixelSize: units.gu(1.7)
                                font.weight: Font.Bold
                                color: root.theme ? root.theme.ballMid : "#E6D7BA"
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - units.gu(1.0)) / 2.0
                        height: units.gu(4.8)
                        radius: units.gu(1.2)
                        color: root.theme ? root.theme.cardOuter : "#141517"
                        border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                        border.width: units.gu(0.1)

                        Column {
                            anchors.centerIn: parent
                            spacing: units.gu(0.1)

                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: i18n.tr("NEXT STAGE")
                                font.pixelSize: units.gu(0.95)
                                font.weight: Font.DemiBold
                                color: "#848890"
                            }

                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: (root.stageNumber + 1 <= 100) ? (root.stageNumber + 1).toString() : i18n.tr("End")
                                font.pixelSize: units.gu(1.7)
                                font.weight: Font.Bold
                                color: root.theme ? root.theme.accent : "#D99B26"
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(3.4)
                    radius: units.gu(1.0)
                    visible: root.isCheckpoint
                    color: root.theme ? root.theme.accentBg : "#261E10"
                    border.color: root.theme ? root.theme.accent : "#D99B26"
                    border.width: units.gu(0.08)

                    Row {
                        anchors.centerIn: parent
                        spacing: units.gu(0.8)

                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            text: i18n.tr("Checkpoint Saved (Stage %1)").arg(root.nextCheckpoint)
                            font.pixelSize: units.gu(1.1)
                            font.weight: Font.DemiBold
                            color: root.theme ? root.theme.accent : "#D99B26"
                        }
                    }
                }

                Rectangle {
                    id: continueBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(5.0)
                    radius: units.gu(2.5)
                    color: continueMouse.pressed
                           ? (root.theme ? root.theme.accentHover : "#BF8419")
                           : (root.theme ? root.theme.accent : "#D99B26")
                    scale: continueMouse.pressed ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }

                    Label {
                        anchors.left: parent.left
                        anchors.leftMargin: units.gu(2.6)
                        anchors.verticalCenter: parent.verticalCenter
                        text: (root.stageNumber >= 100) ? i18n.tr("Finish Descent") : i18n.tr("Continue Descent")
                        font.pixelSize: units.gu(1.6)
                        font.weight: Font.Bold
                        color: root.theme ? root.theme.accentText : "#0B0C0D"
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
                            id: continueIconCanvas
                            anchors.centerIn: parent
                            width: units.gu(1.4)
                            height: units.gu(1.4)
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);
                                ctx.fillStyle = root.theme ? root.theme.accentText : "#0B0C0D";
                                ctx.beginPath();
                                ctx.moveTo(width * 0.25, height * 0.15);
                                ctx.lineTo(width * 0.85, height * 0.5);
                                ctx.lineTo(width * 0.25, height * 0.85);
                                ctx.closePath();
                                ctx.fill();
                            }
                            Connections {
                                target: root
                                function onThemeChanged() { continueIconCanvas.requestPaint(); }
                            }
                        }
                    }

                    MouseArea {
                        id: continueMouse
                        anchors.fill: parent
                        onClicked: root.continueRequested()
                    }
                }

                // Secondary Action: Restart Stage
                Rectangle {
                    id: restartBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(4.4)
                    radius: units.gu(2.2)
                    color: restartMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardOuter : "#141517")
                    border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                    border.width: units.gu(0.12)
                    scale: restartMouse.pressed ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: (root.checkpointLevel > 1)
                              ? i18n.tr("Restart Stage (Stage %1)").arg(root.checkpointLevel)
                              : i18n.tr("Restart Stage")
                        font.pixelSize: units.gu(1.45)
                        font.weight: Font.DemiBold
                        color: "#D6D5D2"
                    }

                    MouseArea {
                        id: restartMouse
                        anchors.fill: parent
                        onClicked: root.restartRequested()
                    }
                }

                // Tertiary Action: Restart from Stage 1 (if checkpointLevel > 1)
                Rectangle {
                    id: restartBeginningBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(4.4)
                    radius: units.gu(2.2)
                    visible: root.checkpointLevel > 1
                    color: restartBeginMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardOuter : "#141517")
                    border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                    border.width: units.gu(0.12)
                    scale: restartBeginMouse.pressed ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: i18n.tr("Restart from Stage 1")
                        font.pixelSize: units.gu(1.45)
                        font.weight: Font.DemiBold
                        color: "#848890"
                    }

                    MouseArea {
                        id: restartBeginMouse
                        anchors.fill: parent
                        onClicked: root.restartStageOneRequested()
                    }
                }

                Rectangle {
                    id: menuBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: units.gu(4.4)
                    radius: units.gu(2.2)
                    color: menuMouse.pressed ? "#1E2024" : (root.theme ? root.theme.cardOuter : "#141517")
                    border.color: root.theme ? root.theme.cardBorder : "#2A2C30"
                    border.width: units.gu(0.12)
                    scale: menuMouse.pressed ? 0.95 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }

                    Label {
                        anchors.centerIn: parent
                        text: i18n.tr("Main Menu")
                        font.pixelSize: units.gu(1.45)
                        font.weight: Font.DemiBold
                        color: "#848890"
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
