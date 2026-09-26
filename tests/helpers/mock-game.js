function createMockGame(overrides = {}) {
    const game = {
        difficultyMode: 1,
        currentLevel: 1,
        highestLevelReached: 1,
        unlockedCheckpoints: [1],
        score: 0,
        bestScore: 0,
        streak: 0,
        totalRings: 0,
        isSuperFall: false,
        ballVy: 400,
        gravity: 800,
        bounceSpeed: 300,
        levelRings: 20,
        bannerText: "",
        bannerOpacity: 0.0,
        bannerIsCheckpoint: false,
        bannerIsZone: false,
        activePlayTimeAccumulator: 0.0,
        activePlatformY: 0,
        gameOver: false,
        towerAngle: 0.0,
        currentTheme: {
            accent: "#D99B26",
            accentBg: "#261E10",
            topSafe: "#D99B26",
            topHazard: "#BA3C3C",
            topFragile: "#C47020"
        },
        shatterEvents: [],
        spawnShatterDebris: function(ringY, isGold, isGrand, theme, isFragile) {
            this.shatterEvents.push({ ringY, isGold, isGrand, theme, isFragile });
        },
        checkpointUnlocks: [],
        unlockCheckpoint: function(lvl) {
            this.checkpointUnlocks.push(lvl);
            if (this.unlockedCheckpoints.indexOf(lvl) === -1) {
                this.unlockedCheckpoints.push(lvl);
                this.unlockedCheckpoints.sort((a, b) => a - b);
            }
        },
        particles: [],
        spawnParticles: function(x, y, count, color, mult) {
            this.particles.push({ x, y, count, color, mult });
        },
        spawnBounceDust: function(ringY, theme) {},
        ...overrides
    };

    const soundManager = {
        bounces: 0,
        shatters: 0,
        hazards: 0,
        fanfares: 0,
        haptics: 0,
        milestones: 0,
        playBounce: function() { this.bounces++; },
        playShatter: function() { this.shatters++; },
        playHazardHit: function() { this.hazards++; },
        playFanfare: function() { this.fanfares++; },
        haptic: function() { this.haptics++; },
        milestoneHaptic: function() { this.milestones++; }
    };

    const stageClearTimer = {
        started: false,
        start: function() { this.started = true; },
        restart: function() { this.started = true; }
    };

    return { game, soundManager, stageClearTimer };
}

module.exports = {
    createMockGame
};
