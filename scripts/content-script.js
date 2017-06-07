(function() {

    chrome.storage.sync.get(null, storage => {

        if (storage.message) {
            alert(storage.message);
            loadExtension();
        }

        let hotkey = storage.hotkey || '`';
        document.addEventListener('keypress', event => onKeypress(event, hotkey), true);
    });

    function onKeypress(event, hotkey) {

        // not hotkey or is an editable field
        const key = String.fromCharCode(event.which);
        const nodeName = document.activeElement.nodeName.toLowerCase();

        if (hotkey !== key
            || document.activeElement.isContentEditable
            || 'input' === nodeName || 'textarea' === nodeName || 'select' === nodeName) {
            return;
        }

        loadExtension();

        return false;
    }

    function loadExtension() {

        // let the initial load event clear out
        setTimeout(() => {
            chrome.runtime.sendMessage({ action: 'LoadBacktickPlease' }, function(response) {
                // loaded successfully ? stop listening
                if (response === 'Loaded') {
                    document.removeEventListener('keypress', onKeypress, true);
                }
            });
        }, 100);
    }
})();