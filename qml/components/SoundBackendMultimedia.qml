import QtQuick 2.9
import QtMultimedia 5.0

Item {
    id: backend

    property bool soundEnabled: true
    property real masterVolume: 1.0

    SoundEffect {
        id: sfxBounce
        category: "music"
        source: Qt.resolvedUrl("../../assets/sounds/bounce.wav")
        muted: !backend.soundEnabled
        volume: 1.0
    }

    SoundEffect {
        id: sfxRoundCleared
        category: "music"
        source: Qt.resolvedUrl("../../assets/sounds/fanfare.wav")
        muted: !backend.soundEnabled
        volume: 1.0
    }

    onSoundEnabledChanged: {
        if (!soundEnabled) {
            stopAll();
        }
    }

    function playBounce(velocityNorm) {
        if (!soundEnabled) return;
        try {
            sfxBounce.play();
        } catch (e) {}
    }

    function playRoundCleared() {
        if (!soundEnabled) return;
        try {
            sfxRoundCleared.play();
        } catch (e) {}
    }

    function playFanfare() {
        playRoundCleared();
    }

    // Unused sound methods kept as clean no-ops for compatibility
    function playPass(streak) {}
    function playSmash(streak) {}
    function playGameOver() {}
    function playWhoosh() {}
    function stopWhoosh() {}
    function playClick() {}

    function stopAll() {
        try {
            sfxBounce.stop();
            sfxRoundCleared.stop();
        } catch (e) {}
    }
}
