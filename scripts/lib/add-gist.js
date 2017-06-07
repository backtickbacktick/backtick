/* globals $ */
function BacktickAddGistInitiator(store) {

    return (gistId) => {

        return (!gistId ? getGistIdFromUrl() : Promise.resolve(gistId))
            .then(fetchGist)
            .then(commandFromGist)
            .then(newCommand => {
                if (store.getCommands().filter(command => newCommand.slug === command.slug).length) {
                    return Promise.reject('Already saved this command.');
                }
                return store.addCommands([newCommand])
                    .then(() => newCommand);
            });

        function fetchGist(gistId) {
            return new Promise((resolve, reject) => {
                return $.getJSON(`${config.githubApiUrl}/gists/${gistId}?t=${Date.now()}`)
                    .fail(() => {
                        return reject(`Unable to get gist with id '${gistId}'.`);
                    })
                    .done(gist => {
                        return resolve(gist);
                    });
            });
        }

        function parseJson(json) {
            try {
                return JSON.parse(json);
            } catch (e) {
                return { error: 'The command.json file in the gist is not a valid JSON file.' };
            }
        }

        function commandFromGist(gist) {

            let command = { command: null };

            if (gist.hasOwnProperty('files')
                && gist.files.hasOwnProperty('command.js')
                && gist.files['command.js'].hasOwnProperty('raw_url')) {
                command.command = gist.files['command.js']['raw_url'];
            } else {
                return Promise.reject('Gist is missing the command.js file.');
            }

            if (gist.hasOwnProperty('files')
                && gist.files.hasOwnProperty('command.json')
                && gist.files['command.json'].hasOwnProperty('content')) {
                command = Object.assign({}, parseJson(gist.files['command.json']['content']), command);
                if (command.error) {
                    return Promise.reject(command.error);
                }
            } else {
                return Promise.reject('Gist is missing the command.json file.');
            }

            if (command.icon && command.icon.indexOf('https://') !== 0) {
                return Promise.reject('Command icon url must start with "https://".');
            }
            else if (!command.name) {
                return Promise.reject('Command name missing.');
            }
            else if (!command.description) {
                return Promise.reject('Command description missing.');
            }

            command.slug = gist.id;

            return Promise.resolve(command);
        }

        function getGistIdFromUrl() {

            if (window.location.host !== 'gist.github.com') {
                return Promise.reject('You need to be on gist.github.com to add a command.');
            }

            let path = location.pathname;
            return Promise.resolve(path.slice(path.lastIndexOf('/') + 1));
        }
    };
}