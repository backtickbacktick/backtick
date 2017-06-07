new BacktickStore().then(backtickStore => {

    let addGist = BacktickAddGistInitiator(backtickStore);
    new BacktickOptions(backtickStore, addGist);
});

function BacktickOptions(store, addGist) {

    let optionsPage = $('.options-page'),
        hotkeyInput = $('#hotkey'),
        gistForm = $('#import-form'),
        savedList = $('#saved-list'),
        libraryList = $('#library-list'),
        hotkeyUpdate = setTimeout(() => {});

    hotkeyInput.val(store.getHotkey() || config.hotkey);

    const loading = {
        start: () => {
            optionsPage.addClass('loading');
        },
        end: () => {
            setTimeout(() => { optionsPage.removeClass('loading'); }, 500);
        }
    };

    store.getLibrary().then(libraryCommands => {

        let savedCommands = store.getCommands();

        libraryList.prepend(libraryCommands.filter(command => !haveSlug(savedCommands, command.slug))
            .map(buildHtml).join(''));

        savedList.prepend(savedCommands
            .map(buildHtml).join(''));

        sortCommands(libraryList);
        sortCommands(savedList);

        loading.end();

        libraryList.on('click', '.toggle', function() {

            let toggle = $(this),
                element = toggle.closest('li').detach(),
                slug = toggle.data('slug'),
                command = libraryCommands.filter(command => command.slug === slug)[0];

            store.addCommands([command])
                .then(commands => {
                    savedCommands = commands;
                    element.prependTo(savedList);
                    sortCommands(savedList);

                    loading.end();
                });
        });

        savedList.on('click', '.toggle', function() {

            let toggle = $(this),
                element = toggle.closest('li').detach(),
                slug = toggle.data('slug'),
                command = savedCommands.filter(command => command.slug === slug)[0];

            store.removeCommands([command])
                .then(commands => {
                    savedCommands = commands;
                    if (haveSlug(libraryCommands, command.slug)) {
                        element.prependTo(libraryList);
                        sortCommands(libraryList);
                    }
                    loading.end();
                });
        });

        hotkeyInput
            .on('keyup', function() {
                hotkeyInput.select();
                clearTimeout(hotkeyUpdate);
                loading.start();
                hotkeyUpdate = setTimeout(function() {
                    store.addHotkey(hotkeyInput.val()).then(() => {
                        loading.end();
                    });
                }, 1000);
            })
            .on('click', function() {
                hotkeyInput.select();
            });

        let submitting = false;
        gistForm.on('submit', function(event) {
            event.preventDefault();

            let gistId = $('[name="gistId"]', this).val();

            if (savedCommands.filter(command => command.slug === gistId).length) {
                alert('Custom command already added.');
                return false;
            }

            if (!submitting && gistId) {
                submitting = true;
                addGist(gistId)
                    .then(command => {
                        savedList.prepend(buildHtml(command));
                        sortCommands(savedList);
                        submitting = false;
                        alert('New command added!');
                    })
                    .catch(error => {
                        alert(error);
                    });
            }
            return false;
        });

    });

    GoogleAnalytics();

    function haveSlug(commands, slug) {
        return commands.filter(command => command.slug === slug).length;
    }

    function sortCommands($list) {

        let $items = $list.children().not('.none');

        $items.sort(function(a, b) {

            let an = a.getAttribute('data-name'),
                bn = b.getAttribute('data-name');

            return (an > bn) ? 1 : ((an < bn) ? -1 : 0);
        });

        $items.detach().prependTo($list);
    }

    function buildHtml(command) {

        command = Object.assign({ link: '', icon: config.defaultCommandIcon }, command);

        return `
<li class="command" id="command-${command.slug}" data-name="${command.name}">
    <div class="icon" style="background-image: url(${command.icon})"></div>
    <div class="body">
        <span class="name">${command.name}</span>
        <p class="description">${command.description}</p>
        ` + (command.link ? `<a class="link" href="${command.link}">${command.link}</a>` : '') + `
    </div>
    <span class="toggle" data-slug="${command.slug}">
        <span class="add">Add</span>
        <span class="remove">Remove</span>
    </span>
</li>
`;
    }
}
