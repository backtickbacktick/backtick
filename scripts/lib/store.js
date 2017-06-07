/* globals $ */
function BacktickStore() {

    // initialize store
    let store = { commands: [], hotkey: config.defaultHotkey },
        service = {
            addHotkey,
            addCommands,
            removeCommands,
            addMessage,
            getLibrary,
            getHotkey: () => ('' + store.hotkey),
            getCommands: () => $.extend(true, [], store.commands),
        };

    return getStore()
        .then(storage => {

            let initActions = [];

            storage = storage || {};

            if (storage.message) {
                alert(storage.message);
                chrome.storage.sync.set({ message: null });
            }

            let overwrite = 0;
            if (!overwrite && isValidCommands(storage['commands'])) {
                store.commands = storage['commands'];
            } else {
                let setCommands = getLibrary().then(addCommands);
                initActions.push(setCommands);
            }

            if (isValidString(storage['hotkey'])) {
                store.hotkey = storage['hotkey'];
            } else {
                initActions.push(addHotkey(config.defaultHotkey));
            }

            return Promise.all(initActions)
                .then(() => Promise.resolve(service))
                .catch(error => alert);
        });

    function getStore() {
        return new Promise(resolve => {
            chrome.storage.sync.get(null, storage => {
                resolve(storage);
            });
        });
    }

    function isValidString(hotkey) {
        return hotkey && 'string' === typeof(hotkey);
    }

    function isValidCommands(commands) {
        return commands && Array.isArray(commands);
    }

    function addHotkey(newHotkey) {

        return new Promise((resolve, reject) => {

            if (!isValidString(newHotkey)) {
                return reject('New hotkey is not a string.');
            }

            store.hotkey = newHotkey;

            chrome.storage.sync.set({ hotkey: store.hotkey }, function() {
                return resolve(store.hotkey);
            });

        });
    }

    function addMessage(newMessage) {

        return new Promise((resolve, reject) => {

            if (!isValidString(newMessage)) {
                return reject('New message is not a string.');
            }

            store.message = newMessage;

            chrome.storage.sync.set({ message: store.message }, function() {
                return resolve(store.message);
            });

        });
    }

    function addCommands(newCommands) {

        return new Promise((resolve, reject) => {

            if (!isValidCommands(newCommands)) {
                return reject('New commands are not an array.');
            }

            store.commands = newCommands.concat(store.commands);

            chrome.storage.sync.set({ commands: store.commands }, function() {
                return resolve(store.commands);
            });

        });
    }

    function removeCommands(removeCommands) {

        return new Promise((resolve, reject) => {

            if (!isValidCommands(removeCommands)) {
                return reject('Commands are not an array.');
            }

            let removeCommandSlugs = removeCommands.map(command => command.slug);

            store.commands = store.commands.filter(command => !removeCommandSlugs.includes(command.slug));

            chrome.storage.sync.set({ commands: store.commands }, function() {
                return resolve(store.commands);
            });

        });
    }

    function getLibrary() {
        return new Promise((resolve, reject) => {
            $.getJSON(config.libraryCommandsJson)
                .fail(() => reject('Could not load library commands.'))
                .done(defaultCommands => {
                    return resolve(defaultCommands);
                });
        });
    }

}