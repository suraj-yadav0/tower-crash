import QtQuick 2.9
import QtMultimedia 5.0

Item {
    id: backend

    property bool soundEnabled: true
    property real masterVolume: 1.0
    property int bounceVoiceIndex: 0

    Audio {
        id: bounceVoice1
        source: Qt.resolvedUrl("../../assets/sounds/bounce.wav")
        muted: !backend.soundEnabled
    }

    Audio {
        id: bounceVoice2
        source: Qt.resolvedUrl("../../assets/sounds/bounce.wav")
        muted: !backend.soundEnabled
    }

    Audio {
        id: roundClearedVoice
        source: Qt.resolvedUrl("../../assets/sounds/fanfare.wav")
        muted: !backend.soundEnabled
    }

    onSoundEnabledChanged: {
        if (!soundEnabled) {
            stopAll();
        }
    }

    function playBounce(velocityNorm) {
        if (!soundEnabled) return;
        try {
            var voice = (bounceVoiceIndex === 0) ? bounceVoice1 : bounceVoice2;
            bounceVoiceIndex = (bounceVoiceIndex + 1) % 2;
            voice.stop();
            voice.play();
        } catch (e) {}
    }

    function playRoundCleared() {
        if (!soundEnabled) return;
        try {
            roundClearedVoice.stop();
            roundClearedVoice.play();
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
            bounceVoice1.stop();
            bounceVoice2.stop();
            roundClearedVoice.stop();
        } catch (e) {}
    }
}
