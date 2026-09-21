import QtQuick 2.9
import QtMultimedia 5.9
import QtFeedback 5.0

Item {
    id: root

    property bool soundEnabled: true
    property bool hapticsEnabled: true

    SoundEffect {
        id: sfxBounce
        source: "../../assets/sounds/bounce.wav"
        muted: !root.soundEnabled
    }

    SoundEffect {
        id: sfxPass
        source: "../../assets/sounds/pass.wav"
        muted: !root.soundEnabled
    }

    SoundEffect {
        id: sfxSmash
        source: "../../assets/sounds/smash.wav"
        muted: !root.soundEnabled
    }

    SoundEffect {
        id: sfxGameOver
        source: "../../assets/sounds/gameover.wav"
        muted: !root.soundEnabled
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

    function play(type) {
        if (!soundEnabled) return;
        try {
            if (type === "bounce") sfxBounce.play();
            else if (type === "pass") sfxPass.play();
            else if (type === "smash") sfxSmash.play();
            else if (type === "gameover") sfxGameOver.play();
        } catch (e) {}
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
}
