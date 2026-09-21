.pragma library

var themeList = [
    {
        id: "cyber",
        name: "Cyber Neon",
        previewColor: "#00d2d3",
        topSafe: "#00b4d8",
        sideSafe: "#0077b6",
        topHazard: "#ff4757",
        sideHazard: "#b71523",
        ballLight: "#fff5cc",
        ballMid: "#ffd166",
        ballDark: "#f77f00",
        bgTop: "#111827",
        bgBottom: "#070b12",
        pole1: "#1e293b",
        pole2: "#334155",
        pole3: "#0f172a",
        accent: "#00d2d3",
        accentHover: "#00b4b5",
        accentText: "#070b12",
        accentBg: "#122631",
        accentBorder: "#00d2d3",
        cardOuter: "#0e141c",
        cardInner: "#080c10",
        cardBorder: "#223142"
    },
    {
        id: "emerald",
        name: "Emerald",
        previewColor: "#10b981",
        topSafe: "#10b981",
        sideSafe: "#059669",
        topHazard: "#f43f5e",
        sideHazard: "#be123c",
        ballLight: "#fef08a",
        ballMid: "#fbbf24",
        ballDark: "#d97706",
        bgTop: "#0b1a14",
        bgBottom: "#040d09",
        pole1: "#162e24",
        pole2: "#264d3d",
        pole3: "#0f2019",
        accent: "#10b981",
        accentHover: "#059669",
        accentText: "#040d09",
        accentBg: "#0c281e",
        accentBorder: "#10b981",
        cardOuter: "#0c1713",
        cardInner: "#060f0c",
        cardBorder: "#1c332a"
    },
    {
        id: "obsidian",
        name: "Obsidian",
        previewColor: "#f59e0b",
        topSafe: "#f59e0b",
        sideSafe: "#d97706",
        topHazard: "#ef4444",
        sideHazard: "#b91c1c",
        ballLight: "#e0f2fe",
        ballMid: "#38bdf8",
        ballDark: "#0284c7",
        bgTop: "#1a1713",
        bgBottom: "#0c0a08",
        pole1: "#332b20",
        pole2: "#524535",
        pole3: "#241e17",
        accent: "#f59e0b",
        accentHover: "#d97706",
        accentText: "#0c0a08",
        accentBg: "#2b2110",
        accentBorder: "#f59e0b",
        cardOuter: "#16130f",
        cardInner: "#0e0c09",
        cardBorder: "#2e261d"
    },
    {
        id: "amethyst",
        name: "Amethyst",
        previewColor: "#8b5cf6",
        topSafe: "#8b5cf6",
        sideSafe: "#6d28d9",
        topHazard: "#f97316",
        sideHazard: "#c2410c",
        ballLight: "#fecdd3",
        ballMid: "#f43f5e",
        ballDark: "#be185d",
        bgTop: "#181028",
        bgBottom: "#0c0717",
        pole1: "#31214d",
        pole2: "#4c3575",
        pole3: "#221638",
        accent: "#8b5cf6",
        accentHover: "#7c3aed",
        accentText: "#ffffff",
        accentBg: "#24163b",
        accentBorder: "#8b5cf6",
        cardOuter: "#161024",
        cardInner: "#0d0818",
        cardBorder: "#2b1e42"
    },
    {
        id: "sunset",
        name: "Sunset",
        previewColor: "#fb7185",
        topSafe: "#fb7185",
        sideSafe: "#e11d48",
        topHazard: "#06b6d4",
        sideHazard: "#0891b2",
        ballLight: "#fef08a",
        ballMid: "#facc15",
        ballDark: "#ca8a04",
        bgTop: "#201217",
        bgBottom: "#10080b",
        pole1: "#3d1e28",
        pole2: "#613040",
        pole3: "#29131a",
        accent: "#fb7185",
        accentHover: "#e11d48",
        accentText: "#10080b",
        accentBg: "#2e141e",
        accentBorder: "#fb7185",
        cardOuter: "#190f14",
        cardInner: "#0f080c",
        cardBorder: "#331c27"
    }
];

var themeOptions = [
    { id: 0, name: "Auto", previewColor: "#00d2d3" },
    { id: 1, name: "Cyber", previewColor: "#00b4d8" },
    { id: 2, name: "Emerald", previewColor: "#10b981" },
    { id: 3, name: "Obsidian", previewColor: "#f59e0b" },
    { id: 4, name: "Amethyst", previewColor: "#8b5cf6" },
    { id: 5, name: "Sunset", previewColor: "#fb7185" }
];

function getTheme(arg1, arg2) {
    if (arguments.length === 1) {
        var idx = (Math.max(1, arg1) - 1) % themeList.length;
        return themeList[idx];
    }
    var mode = parseInt(arg1) || 0;
    var level = parseInt(arg2) || 1;
    if (mode === 0) {
        var autoIdx = (Math.max(1, level) - 1) % themeList.length;
        return themeList[autoIdx];
    }
    var selected = (mode - 1) % themeList.length;
    if (selected < 0) selected = 0;
    return themeList[selected];
}

function getThemeName(themeMode, levelNum) {
    var mode = parseInt(themeMode) || 0;
    if (mode === 0) {
        var theme = getTheme(0, levelNum);
        return "Auto (" + theme.name + ")";
    }
    for (var i = 0; i < themeOptions.length; i++) {
        if (themeOptions[i].id === mode) {
            return themeOptions[i].name;
        }
    }
    return "Cyber";
}
