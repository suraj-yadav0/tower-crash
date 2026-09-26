const fs = require('fs');
const path = require('path');
const vm = require('vm');

function loadQmlModule(relativeFilePath, customGlobals = {}) {
    const fullPath = path.resolve(__dirname, '..', '..', relativeFilePath);
    let code = fs.readFileSync(fullPath, 'utf8');

    // Strip QML directives that are invalid in Node.js
    code = code.replace(/^\s*\.pragma\s+library\s*;?/gm, '');
    code = code.replace(/^\s*\.import\s+.*$/gm, '');

    const sandbox = {
        console,
        Math,
        parseInt,
        parseFloat,
        isNaN,
        JSON,
        Array,
        Object,
        String,
        Number,
        Boolean,
        Date,
        RegExp,
        i18n: {
            tr: (text) => ({
                arg: (val1) => ({
                    arg: (val2) => String(text).replace('%1', val1).replace('%2', val2),
                    toString: () => String(text).replace('%1', val1)
                }),
                toString: () => String(text)
            })
        },
        ...customGlobals
    };

    const context = vm.createContext(sandbox);
    vm.runInContext(code, context);
    return context;
}

module.exports = {
    loadQmlModule
};
