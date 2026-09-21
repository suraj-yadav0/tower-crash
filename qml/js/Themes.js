.pragma library

var themeList = [
    {
        id: "tactical",
        name: "Tactical Ochre",
        previewColor: "#D99B26",
        topSafe: "#D99B26",
        sideSafe: "#9E6E14",
        topHazard: "#BA3C3C",
        sideHazard: "#7D2222",
        ballLight: "#FFF9ED",
        ballMid: "#E6D7BA",
        ballDark: "#A89879",
        bgTop: "#161718",
        bgBottom: "#0B0C0D",
        pole1: "#282A2E",
        pole2: "#42454B",
        pole3: "#1B1C1E",
        goalTop: "#E8C872",
        goalSide: "#B09242",
        accent: "#D99B26",
        accentHover: "#BF8419",
        accentText: "#0B0C0D",
        accentBg: "#261E10",
        accentBorder: "#544020",
        cardOuter: "#141517",
        cardInner: "#0D0E0F",
        cardBorder: "#2A2C30"
    },
    {
        id: "kyoto",
        name: "Kyoto Celadon",
        previewColor: "#6E8B76",
        topSafe: "#6E8B76",
        sideSafe: "#4A6351",
        topHazard: "#B8543E",
        sideHazard: "#7D3121",
        ballLight: "#FAF4EB",
        ballMid: "#E2D7C3",
        ballDark: "#B0A28A",
        bgTop: "#151614",
        bgBottom: "#0B0C0A",
        pole1: "#292B26",
        pole2: "#41443D",
        pole3: "#1D1E1B",
        goalTop: "#D6C797",
        goalSide: "#9B8E63",
        accent: "#6E8B76",
        accentHover: "#57715F",
        accentText: "#0B0C0A",
        accentBg: "#1B241E",
        accentBorder: "#3E5244",
        cardOuter: "#141613",
        cardInner: "#0C0E0B",
        cardBorder: "#292E27"
    },
    {
        id: "nordic",
        name: "Nordic Lichen",
        previewColor: "#7B998E",
        topSafe: "#7B998E",
        sideSafe: "#546E64",
        topHazard: "#9E4453",
        sideHazard: "#6E2834",
        ballLight: "#EEF8F7",
        ballMid: "#A7C9C5",
        ballDark: "#6A8F8B",
        bgTop: "#131719",
        bgBottom: "#090C0D",
        pole1: "#21272B",
        pole2: "#384249",
        pole3: "#171B1E",
        goalTop: "#C8D9B4",
        goalSide: "#8B9E78",
        accent: "#7B998E",
        accentHover: "#658277",
        accentText: "#090C0D",
        accentBg: "#1A2421",
        accentBorder: "#3A4F48",
        cardOuter: "#121618",
        cardInner: "#0A0D0E",
        cardBorder: "#242E33"
    },
    {
        id: "desert",
        name: "Desert Dune",
        previewColor: "#C78853",
        topSafe: "#C78853",
        sideSafe: "#945B2C",
        topHazard: "#385898",
        sideHazard: "#213B70",
        ballLight: "#FFF1E0",
        ballMid: "#E8A87C",
        ballDark: "#B36E42",
        bgTop: "#181313",
        bgBottom: "#0C0808",
        pole1: "#332320",
        pole2: "#543934",
        pole3: "#211412",
        goalTop: "#E6BA75",
        goalSide: "#A88142",
        accent: "#C78853",
        accentHover: "#AD6F3C",
        accentText: "#0C0808",
        accentBg: "#2E1B13",
        accentBorder: "#5E3825",
        cardOuter: "#171212",
        cardInner: "#0E0909",
        cardBorder: "#302220"
    },
    {
        id: "braun",
        name: "Braun Slate",
        previewColor: "#CBC3B3",
        topSafe: "#CBC3B3",
        sideSafe: "#918979",
        topHazard: "#D85A20",
        sideHazard: "#963A0E",
        ballLight: "#FFFFFF",
        ballMid: "#E6923C",
        ballDark: "#A85816",
        bgTop: "#141414",
        bgBottom: "#0A0A0A",
        pole1: "#262626",
        pole2: "#3D3D3D",
        pole3: "#1A1A1A",
        goalTop: "#E2DBCE",
        goalSide: "#A39C90",
        accent: "#CBC3B3",
        accentHover: "#B5AC9A",
        accentText: "#0A0A0A",
        accentBg: "#211F1C",
        accentBorder: "#4A453D",
        cardOuter: "#141414",
        cardInner: "#0C0C0C",
        cardBorder: "#2E2D2B"
    }
];

var themeOptions = [
    { id: 0, name: "Dynamic", previewColor: "#D99B26" },
    { id: 1, name: "Tactical", previewColor: "#D99B26" },
    { id: 2, name: "Kyoto", previewColor: "#6E8B76" },
    { id: 3, name: "Lichen", previewColor: "#7B998E" },
    { id: 4, name: "Desert", previewColor: "#C78853" },
    { id: 5, name: "Braun", previewColor: "#CBC3B3" }
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
        return "Dynamic (" + theme.name + ")";
    }
    for (var i = 0; i < themeOptions.length; i++) {
        if (themeOptions[i].id === mode) {
            return themeOptions[i].name;
        }
    }
    return "Tactical";
}
