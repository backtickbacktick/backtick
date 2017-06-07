/* globals $ */
function BacktickCommands(store, addGist) {

    let commandItems = [], $results, $resultsContainer, loaded = false;

    return {
        init,
        searchCommands,
        selectNext: select('next'),
        selectPrev: select('prev'),
        runSelected,
        loadCommands
    };

    function runSelected() {

        let selected = commandItems.filter(command => command.isSelected());
        selected.length && selected[0].run();
    }

    function select(action) {
        return function() {

            let selected = commandItems.filter(command => command.isSelected());

            if ('run' === action && selected.length) {
                selected[0].run();
            }

            let showing = commandItems.filter(command => command.isShowing());

            if (!loaded) {
                $results.show();
                loaded = true;
                return showing[0].setSelected();
            }

            if (!showing.length) {
                return;
            }

            if ('first' === action) {
                return showing[0].setSelected();
            }

            if (!showing.filter(command => command.isSelected()).length) {
                return showing[0].setSelected();
            }

            for (let index = 0; index < showing.length; index++) {

                if (showing[index].isSelected()) {

                    if ('next' === action) {
                        let selectIndex = (index + 1) < showing.length ? (index + 1) : 0;
                        return showing[selectIndex].setSelected();
                    }

                    if ('prev' === action) {
                        let selectIndex = (index - 1) > -1 ? (index - 1) : showing.length - 1;
                        return showing[selectIndex].setSelected();
                    }
                }
            }
        };
    }

    function loadCommands() {

        $resultsContainer = $('ul', $results).empty();

        commandItems.forEach(commandItem => commandItem.$element.remove());

        commandItems = [];

        return Promise.resolve(store.getCommands())
            .then(includeAddCommand)
            .then(initializeItems);
    }

    function init() {

        $results = arguments[0];

        return loadCommands();
    }

    function addItem(rawCommand) {

        let command = new BacktickCommand(rawCommand);

        command.$element.insertAfter($('li:first-child', $resultsContainer));
    }

    function initializeItems(rawCommands) {

        commandItems = [];

        rawCommands.forEach(rawCommand => {

            let command = new BacktickCommand(rawCommand);

            command.$element.appendTo($resultsContainer);

        });

        return Promise.resolve(commandItems);
    }

    function includeAddCommand(rawCommands) {

        rawCommands.unshift({
            slug: 'add-to-backtick',
            addGist: true,
            name: 'Add to Backtick',
            description: 'Add the current command gist on GitHub to Backtick.',
            author: 'iambriansreed',
            icon: 'chrome-extension://' + chrome.runtime.id + '/images/add-icon.png'
        });

        return rawCommands;
    }

    function BacktickCommand(rawCommand) {

        if (!rawCommand) {
            return {};
        }

        let selected = false,
            showing = true,
            runCount = 0,
            script = rawCommand.command || '',
            command = {
                $element: $(buildHtml(rawCommand)),
                isSelected,
                isShowing,
                setShow,
                setSelected,
                run
            };

        const blob = [rawCommand.name, rawCommand.description, rawCommand.link].join(' ').toLowerCase();

        command.$element.on('click', () => {
            command.setSelected();
            command.$element.trigger('run.backtick.command.please');
        });

        command.$element.on('run.backtick.command.please', command.run);

        commandItems.push(command);

        return command;

        function run() {

            if (rawCommand.addGist) {
                return addGist()
                    .then(rawCommand => {
                        addItem(rawCommand);
                        alert('New command added!');
                    })
                    .catch(error => {
                        alert(error);
                    });
            }

            if (script) {
                chrome.runtime.sendMessage({ action: 'LoadBacktickCommand', script },
                    (response) => {
                        console.info(response);
                    });
            }
        }

        function setSelected(selectCommand) {

            if (selectCommand === false) {
                selected = false;
                command.$element.removeClass('selected');
                return;
            }

            commandItems.forEach(command => command.setSelected(false));

            selected = true;
            command.$element.addClass('selected');
        }

        function isSelected() {
            return selected;
        }

        function isShowing() {
            return showing;
        }

        function setShow(searchValue) {

            let hasValue = blob.includes(searchValue);

            showing = !searchValue || hasValue;

            command.$element.toggle(showing);

            if (showing) {
                $('.name,.description,.link', command.$element).each((index, propertyElement) => {

                    let text = rawCommand[propertyElement.className];
                    if (text) {

                        let $propertyElement = $(propertyElement);
                        $propertyElement.text(text);
                        if (hasValue) {
                            $propertyElement.html(text.replace(new RegExp(searchValue, 'gi'),
                                (match) => '<span class="match">' + match + '</span>'));
                        }
                    }
                });
                command.$element.show();
                return true;
            }

            command.$element.hide();
            selected = false;
            return false;
        }

        function buildHtml(command) {
            command = Object.assign({ link: '', icon: config.defaultCommandIcon }, command);
            return `
<li class="command" id="command-${command.slug}">
    <div class="icon" style="background-image: url(${command.icon})"></div>
    <div class="body">
        <span class="name">${command.name}</span>
        <p class="description">${command.description}</p>
        ` + (command.link ? `<a class="link" href="${command.link}">${command.link}</a>` : '') + `
    </div>
</li>`;
        }

    }

    function searchCommands(searchText) {

        loaded = true;

        searchText = (searchText || '').toLowerCase().trim();

        let showingCommands = false;

        commandItems.forEach(command => {
            showingCommands = command.setShow(searchText) || showingCommands;
        });

        $results.toggle(showingCommands);

        select('first')();

        return showingCommands;
    }
}