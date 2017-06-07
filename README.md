# Backtick

**Backtick is a command line for bookmarklets and scripts**, packaged as a Chrome extension. ~~For a better explanation, try out the demo at [backtick.ninja/](http://backtick.ninja)~~ Coming soon. The extension is free to use.

*[MIT Licensed](http://opensource.org/licenses/MIT) 2017 Brian Reed*

#### Developing
The code is open for you to play around with and contribute to, if you wish. Here's some instructions on how to get up and running.


##### Dependencies
To compile Backtick, you'll need to install the following dependencies on your system:
  * [Node.js](http://nodejs.org/)
  * [Grunt](http://gruntjs.com/)

With that installed, run these two commands to download the NPM and Bower packages:
```bash
$ npm install
```

##### Building
To build all the files, just run `grunt` in the root folder. This will put all built files into the *_dist/* folder.

To load the built extension files from the *_dist/* folder into Chrome, [follow these instructions](http://developer.chrome.com/extensions/getstarted.html#unpacked).

##### Updates
This new version of Backtick is still under development, check for updates on [twitter](https://twitter.com/backtickninja). 
