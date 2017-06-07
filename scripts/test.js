chrome.storage.sync.get(null, storage => {
    $('pre').html(JSON.stringify(storage, null, '\t'));
});