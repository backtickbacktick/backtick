**Backtick is a console for bookmarklets and scripts**, packaged as a Chrome extension. For a better explanation, try out the demo at [backtick.io/](http://backtick.io). The extension is free to use, but it will occasionally nag you to install the [$5 Backtick license](http://goo.gl/LkPHMG).

*[MIT Licensed](http://opensource.org/licenses/MIT) 2013 Joel Besada*

#### Developing
If you want to play around with the code, you'll first need to install [Node.js](http://nodejs.org/), [Grunt](http://gruntjs.com/) and [Bower](http://bower.io/). With that installed, run the following commands:

```bash
# Install NPM dependencies
npm install
# Install Bower dependencies
bower install
# Run grunt to compile files to dist/
grunt
```

To load the built extension files in the *dist/* folder into Chrome, [follow these instructions](http://developer.chrome.com/extensions/getstarted.html#unpacked).

#### Why are you open sourcing this?
Because that's just something I like to do to contribute back to the community. It also forces me to write cleaner code. (Well, in theory at least.)

#### But wait, couldn't I just clone this repo and remove the nag dialog?
Yes, you absolutely could. That's why I've made it [extra easy for you](https://github.com/JoelBesada/Backtick/blob/master/extension/license.coffee#L2), just flip that boolean to true and you're good to go. However, a nicer option would be to actually buy [the license](http://goo.gl/LkPHMG) to support the continued development of Backtick.

