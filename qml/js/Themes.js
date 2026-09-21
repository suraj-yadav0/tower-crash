.pragma library

var themeList = [
    {
        topSafe: "#00b4d8",
        sideSafe: "#0077b6",
        topHazard: "#ff4757",
        sideHazard: "#b71523",
        ballLight: "#fff5cc",
        ballMid: "#ffd166",
        ballDark: "#d62828",
        bgTop: "#192026",
        bgBottom: "#0e1317",
        pole1: "#2c3440",
        pole2: "#525f6e",
        pole3: "#1c2128"
    },
    {
        topSafe: "#a29bfe",
        sideSafe: "#6c5ce7",
        topHazard: "#ff6b6b",
        sideHazard: "#ee5253",
        ballLight: "#e0fcfc",
        ballMid: "#00d2d3",
        ballDark: "#01a3a4",
        bgTop: "#1a1224",
        bgBottom: "#0f0b15",
        pole1: "#382952",
        pole2: "#624b87",
        pole3: "#1f1430"
    },
    {
        topSafe: "#ffeaa7",
        sideSafe: "#fdcb6e",
        topHazard: "#eb2f06",
        sideHazard: "#b71540",
        ballLight: "#ffe6f9",
        ballMid: "#ff9ff3",
        ballDark: "#f368e0",
        bgTop: "#1c1c14",
        bgBottom: "#10100a",
        pole1: "#47402c",
        pole2: "#786d4e",
        pole3: "#262217"
    },
    {
        topSafe: "#55efc4",
        sideSafe: "#00b894",
        topHazard: "#d63031",
        sideHazard: "#8a1b1b",
        ballLight: "#fff0f0",
        ballMid: "#ff7675",
        ballDark: "#d63031",
        bgTop: "#101e18",
        bgBottom: "#09120e",
        pole1: "#234032",
        pole2: "#3b6953",
        pole3: "#15261e"
    }
];

function getTheme(levelNum) {
    var index = (Math.max(1, levelNum) - 1) % themeList.length;
    return themeList[index];
}
