/* globals $ */
function BacktickCommands(store) {

    let commandItems = [], $results, $resultsContainer, loaded = false;
    const resultsHeight = 275;

    return {
        init,
        addItem,
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
            .then(initializeItems);
    }

    function init() {

        $results = arguments[0];

        return loadCommands();
    }

    function addItem(rawCommand) {

        let command = new BacktickCommand(rawCommand);

        command.setSelected();

        return Promise.resolve(true);
    }

    function initializeItems(rawCommands) {

        rawCommands.forEach(rawCommand => new BacktickCommand(rawCommand));

        return Promise.resolve(commandItems);
    }

    function BacktickCommand(rawCommand) {

        if (!rawCommand) {
            return {};
        }

        let selected = false,
            showing = true,
            script = rawCommand.command || '',
            command = {
                height: 0,
                index: commandItems.length,
                $element: $(buildHtml(rawCommand)),
                isSelected,
                isShowing,
                setShow,
                setSelected,
                run,
                getHeight
            };

        const blob = [rawCommand.name, rawCommand.description, rawCommand.link].join(' ').toLowerCase();

        command.$element.appendTo($resultsContainer);

        command.$element.on('click', () => {
            command.setSelected();
            command.$element.trigger('run.backtick.command.please');
        });

        command.$element.on('run.backtick.command.please', command.run);

        commandItems.push(command);

        return command;

        function run() {

            if (script) {
                chrome.runtime.sendMessage({ action: 'LoadBacktickCommand', script },
                    (response) => {
                        console.info(response);
                    });
            }
        }

        function getHeight() {
            if (!command.height) {
                command.height = command.$element.outerHeight();
            }
            return command.height;
        }

        function setSelected(selectCommand) {

            if (selectCommand === false) {
                command.$element.removeClass('selected');
                selected = false;
                return selected;
            }

            commandItems.forEach(command => command.setSelected(false));
            command.$element.addClass('selected').focus();

            $results.scrollTop(scrollTo());

            selected = true;
            return selected;
        }

        function scrollTo() {

            if (command.index === 0) {
                return 0;
            }

            const itemTop = commandItems
                .map(cmd => {
                    return cmd.index < command.index ? cmd.getHeight() : 0;
                })
                .concat([0])
                .reduce(function(a, b) { return a + b; });

            if (command.index === commandItems.length - 1) {
                return itemTop;
            }

            const
                itemBottom = itemTop + command.getHeight(),
                windowTop = $results.scrollTop(),
                windowBottom = windowTop + resultsHeight;

            const
                withinTop = itemTop >= windowTop,
                withinBottom = itemBottom <= windowBottom;

            if (!withinTop || !withinBottom) {

                let increment = (!withinTop ? -1 : 1);
                return windowTop + (increment * command.getHeight());
            }
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