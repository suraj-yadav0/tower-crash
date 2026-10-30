import QtQuick 2.9
import "../../qml/components"

Item {
    id: root
    width: 480
    height: 800

    SoundManager {
        id: soundManager
        soundEnabled: true
        volume: 0.8
        hapticsEnabled: false
    }

    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            try {
                if (!soundManager.soundEnabled) throw new Error("soundEnabled should be true");
                if (soundManager.volume !== 0.8) throw new Error("volume mismatch");

                soundManager.playBounce(0.5);
                soundManager.playCrash();
                soundManager.playSmash(3);
                soundManager.playShatter();
                soundManager.playSuperfall();
                soundManager.playFanfare();
                soundManager.playRoundCleared();

                soundManager.play("crash");
                soundManager.play("superfall");
                soundManager.play("bounce");
                soundManager.play("fanfare");

                soundManager.volume = 0.5;
                soundManager.soundEnabled = false;
                soundManager.playCrash();
                soundManager.soundEnabled = true;

                soundManager.stopAll();

                console.log("PASS: test_sound_manager");
                Qt.quit();
            } catch (e) {
                console.error("FAIL: test_sound_manager - " + e.message);
                Qt.exit(1);
            }
        }
    }
}
