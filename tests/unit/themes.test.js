const test = require('node:test');
const assert = require('node:assert');
const { loadQmlModule } = require('../helpers/qml-module-loader');

const Themes = loadQmlModule('qml/js/Themes.js');

test('Themes - themeList contains required palette properties', () => {
    assert.ok(Array.isArray(Themes.themeList), 'themeList must be an array');
    assert.ok(Themes.themeList.length >= 8, 'themeList should contain at least 8 themes');

    const requiredProps = [
        'id', 'name', 'previewColor', 'topSafe', 'sideSafe',
        'topHazard', 'sideHazard', 'ballLight', 'ballMid', 'ballDark',
        'bgTop', 'bgBottom', 'accent', 'cardOuter', 'cardInner'
    ];

    for (const theme of Themes.themeList) {
        for (const prop of requiredProps) {
            assert.ok(theme[prop] !== undefined, `Theme ${theme.id || 'unnamed'} missing prop: ${prop}`);
        }
    }
});

test('Themes - dynamic and fixed theme lookup', () => {
    // Mode 0: Dynamic
    const dynLevel1 = Themes.getTheme(0, 1);
    const dynLevel6 = Themes.getTheme(0, 6);
    assert.ok(dynLevel1, 'Dynamic theme at level 1 should exist');
    assert.ok(dynLevel6, 'Dynamic theme at level 6 should exist');

    const nameDyn = Themes.getThemeName(0, 1);
    assert.ok(nameDyn.startsWith('Dynamic ('), `Dynamic theme name must include prefix: ${nameDyn}`);

    // Mode 1: First explicit theme
    const theme1 = Themes.getTheme(1, 1);
    assert.strictEqual(theme1.name, Themes.themeList[0].name);
});

test('Themes - lerpColor interpolates hex colors cleanly', () => {
    const black = '#000000';
    const white = '#FFFFFF';

    assert.strictEqual(Themes.lerpColor(black, white, 0.0), black);
    assert.strictEqual(Themes.lerpColor(black, white, 1.0), white);

    const mid = Themes.lerpColor(black, white, 0.5);
    assert.strictEqual(mid, 'rgb(128,128,128)');
});
