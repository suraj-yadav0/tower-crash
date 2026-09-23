import QtQuick 2.9
import QtFeedback 5.0

Item {
    id: root

    property bool soundEnabled: true
    property real volume: 0.85
    property bool hapticsEnabled: true

    Loader {
        id: multimediaLoader
        asynchronous: false
        source: "SoundBackendMultimedia.qml"
        onLoaded: {
            if (item) {
                item.soundEnabled = Qt.binding(function() { return root.soundEnabled; });
                item.masterVolume = Qt.binding(function() { return root.volume; });
            }
        }
    }

    HapticsEffect {
        id: hapticLight
        duration: 25
        intensity: 0.6
    }

    HapticsEffect {
        id: hapticHeavy
        duration: 70
        intensity: 1.0
    }

    ThemeEffect {
        id: themeHaptic
        effect: ThemeEffect.Press
    }

    Timer {
        id: dualHapticTimer
        interval: 120
        repeat: false
        onTriggered: {
            try { hapticHeavy.start(); } catch (e) {}
        }
    }

    onSoundEnabledChanged: {
        if (!soundEnabled && multimediaLoader.item) {
            try { multimediaLoader.item.stopAll(); } catch (e) {}
        }
    }

    function playBounce(velocityNorm) {
        if (!soundEnabled || !multimediaLoader.item) return;
        try {
            multimediaLoader.item.playBounce(velocityNorm);
        } catch (e) {}
    }

    function playRoundCleared() {
        if (!soundEnabled || !multimediaLoader.item) return;
        try {
            multimediaLoader.item.playRoundCleared();
        } catch (e) {}
    }

    function playFanfare() {
        playRoundCleared();
    }

    // No-op compatibility methods
    function playPass(streak) {}
    function playSmash(streak) {}
    function playGameOver() {}
    function playWhoosh() {}
    function stopWhoosh() {}
    function playClick() {}

    function stopAll() {
        if (!multimediaLoader.item) return;
        try {
            multimediaLoader.item.stopAll();
        } catch (e) {}
    }

    function play(type) {
        if (!soundEnabled) return;
        if (type === "bounce") playBounce(0.6);
        else if (type === "fanfare" || type === "roundCleared") playRoundCleared();
    }

    function haptic(heavy) {
        if (!hapticsEnabled) return;
        try {
            if (heavy) hapticHeavy.start();
            else hapticLight.start();
        } catch (e) {}
    }

    function buttonHaptic() {
        if (!hapticsEnabled) return;
        try {
            themeHaptic.start();
        } catch (e) {}
    }

    function milestoneHaptic() {
        if (!hapticsEnabled) return;
        try {
            hapticHeavy.start();
            dualHapticTimer.start();
        } catch (e) {}
    }
}
