function createMockLocalStorage() {
    const table = new Map();

    const mockDb = {
        transaction: function(callback) {
            const tx = {
                executeSql: function(query, params = []) {
                    const trimmed = query.trim();

                    if (trimmed.startsWith('CREATE TABLE')) {
                        return { rows: { length: 0, item: () => null } };
                    }

                    if (trimmed.startsWith('INSERT OR REPLACE INTO kv')) {
                        const key = params[0];
                        const val = String(params[1]);
                        table.set(key, val);
                        return { rows: { length: 0, item: () => null } };
                    }

                    if (trimmed.startsWith('SELECT k, v FROM kv')) {
                        const rows = [];
                        for (const [k, v] of table.entries()) {
                            rows.push({ k, v });
                        }
                        return {
                            rows: {
                                length: rows.length,
                                item: function(i) {
                                    return rows[i];
                                }
                            }
                        };
                    }

                    return { rows: { length: 0, item: () => null } };
                }
            };

            callback(tx);
        }
    };

    return {
        Sql: {
            LocalStorage: {
                openDatabaseSync: function() {
                    return mockDb;
                }
            }
        },
        _store: table
    };
}

module.exports = {
    createMockLocalStorage
};
