/* globals $ */
chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {

    if (!request.action) {
        return;
    }

    if (request.action === 'LoadBacktickPlease') {
        chrome.tabs.insertCSS(sender.tab.id, { file: 'styles/style.css' });
        chrome.tabs.executeScript(sender.tab.id, { file: 'scripts/jquery.min.js' });
        chrome.tabs.executeScript(sender.tab.id, { file: 'scripts/main.js' });
        sendResponse('Loaded');
    }

    if (request.action === 'LoadBacktickCommand' && request.script) {

        const JAVASCRIPT_URL_REGEXP = /^javascript:/;

        function convertSourceToUrl(url) {

            if (JAVASCRIPT_URL_REGEXP.test(url)) {
                url = url.replace(JAVASCRIPT_URL_REGEXP, '');
                try { url = decodeURIComponent(url); }
                catch (e) {}
            }
            return `javascript:${url}`;
        }

        return $.ajax(request.script)
            .done(response => {
                let url = convertSourceToUrl(response);
                chrome.tabs.update(sender.tab.id, { url });
                sendResponse('Command run.');
            })
            .fail(error => {
                sendResponse(error);
                alert(error);
            });
    }

});
