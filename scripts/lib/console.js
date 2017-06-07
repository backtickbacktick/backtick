/* globals $ */
function BacktickConsole(store, commands, addGist) {

    if (!(this instanceof BacktickConsole)) {
        return new BacktickConsole();
    }

    let open = false, loading = true, searchText = '',
        $container, $console, $input, $results,
        inputActions = {
            13: enter,
            27: escape,
            38: arrowUp,
            40: arrowDown
        },
        documentActions = {};

    documentActions[store.getHotkey()] = toggle;

    buildHtml();

    toggle();

    return { toggle };

    function inputActionSearch(event) {

        if (loading) {
            return;
        }

        if (inputActions.hasOwnProperty(event.which)) {
            return;
        }

        searchText = $input[0].value;
        commands.searchCommands(searchText);
    }

    function inputAction(event) {

        if (inputActions.hasOwnProperty(event.which)) {
            event.preventDefault();
            event.stopPropagation();
            return inputActions[event.which]();
        }
    }

    function documentAction(event) {

        if (documentActions.hasOwnProperty(event.which)) {
            event.preventDefault();
            event.stopPropagation();
            return documentActions[event.which]();
        }
    }

    // keyActions

    function toggle() {

        $input.val('');

        if (open) {

            $console.removeClass('in').addClass('out');
            $results.hide();
            $('>input', $console).val('');
            $('>input', $console).blur();

        } else {

            $('>input', $console).blur();
            $console.removeClass('out').addClass('in');
            setTimeout(() => { $('>input', $console).focus(); }, 500);
        }

        open = !open;
        loading = false;
    }

    function enter() {
        commands.runSelected();
    }

    function escape() {
        toggle();
    }

    function arrowUp() {
        commands.selectPrev();
    }

    function arrowDown() {
        commands.selectNext();
    }

    // buildHtml

    function buildHtml() {

        $('body').append(`
<div class="console-container" id="backtick-container">
    <div class="console" class="in">
        <button type="button" class="settings" title="Settings"></button>
        <div class="spinner"></div>
        <input type="text" placeholder="Find and execute a command" spellcheck="false" name="backtick">
        <button type="button" class="add-gist" title="Add Gist"></button>
    </div>
    <div class="results custom-scrollbar" style="display:none;">
        <ul>
        </ul>
    </div>
</div>
`);

        $container = $('#backtick-container');

        $console = $('.console', $container);

        $input = $('>input', $console);

        $results = $('.results', $container);

        commands.init($results);

        $input.on('keydown', inputAction);
        $input.on('keyup', inputActionSearch);

        $('button.settings', $console).on('click', function() {

            chrome.runtime.sendMessage({
                    action: 'LoadBacktickChromeTabs',
                    tabAction: 'create',
                    params: {
                        'url': '/options.html'
                    }
                },
                (response) => {
                    console.info(response);
                });
        });

        $(document).on('keypress', documentAction);

        if (window.location.host === 'gist.github.com') {
            $container.addClass('gist-detected');
            $('button.add-gist', $console).on('click', function() {
                return addGist()
                    .then(rawCommand => {
                        commands.addItem(rawCommand);
                        alert('New command added!');
                    })
                    .catch(error => {
                        alert(error);
                    });
            });
        }

    }
}