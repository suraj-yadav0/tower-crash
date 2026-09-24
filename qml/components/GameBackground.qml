import QtQuick 2.9
import Lomiri.Components 1.3
import "../js/Themes.js" as Themes

Item {
    id: root
    anchors.fill: parent

    property var currentTheme: null
    property var previousTheme: null
    property real themeTransitionProgress: 1.0

    Rectangle {
        id: bgRect
        anchors.fill: parent
        z: 0
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: {
                    if (!root.currentTheme) return "#171612";
                    if (root.previousTheme && root.themeTransitionProgress < 1.0) {
                        return Themes.lerpColor(root.previousTheme.bgTop, root.currentTheme.bgTop, root.themeTransitionProgress);
                    }
                    return root.currentTheme.bgTop;
                }
            }
            GradientStop {
                position: 1.0
                color: {
                    if (!root.currentTheme) return "#0C0B08";
                    if (root.previousTheme && root.themeTransitionProgress < 1.0) {
                        return Themes.lerpColor(root.previousTheme.bgBottom, root.currentTheme.bgBottom, root.themeTransitionProgress);
                    }
                    return root.currentTheme.bgBottom;
                }
            }
        }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: units.dp(1)
        color: root.currentTheme ? root.currentTheme.cardBorder : "#2A2C30"
        z: 50
    }
}
