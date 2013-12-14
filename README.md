**Backtick is a console for bookmarklets and scripts**, packaged as a Chrome extension. For a better explanation, try out the demo at [backtick.io/](http://backtick.io). The extension is free to use, but it will occasionally nag you to install the [$5 Backtick license](http://goo.gl/LkPHMG).

*[MIT Licensed](http://opensource.org/licenses/MIT) 2013 Joel Besada*

#### Developing
The code is open for you to play around with and contribute to, if you wish. Here's some instructions on how to get up and running.


##### Dependencies
To compile Backtick, you'll need to install the following dependencies on your system:
  * [Node.js](http://nodejs.org/)
  * [Grunt](http://gruntjs.com/)
  * [Bower](http://bower.io/)
  * [Compass](http://compass-style.org/)

With that installed, run these two commands to download the NPM and Bower packages:
```bash
  npm install
  bower install
```

##### Building
To build all the files, just run `grunt` in the root folder. This will put all built files into the *dist/* folder.

To load the built extension files from the *dist/* folder into Chrome, [follow these instructions](http://developer.chrome.com/extensions/getstarted.html#unpacked).

You can also use `grunt serve` if you want to run the code inside a web page instead of an extension. This gives you an option to more quickly develop "front-end" features of Backtick, with auto compiling and live reloading. You can't test any extension-specific code with this, however.

##### Testing
There are a couple of tests in the *test/* folder. Use `grunt test` to run this on a web page. This also uses live reload, so you can write code or new tests and the page will automatically refresh.

##### Vagrant

If you'd like to use Vagrant instead, there is a Vagrantfile for setting everything up for building the extension. If you haven't already, download [Vagrant](http://downloads.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads), and then do the following:

```
git clone https://github.com/JoelBesada/Backtick.git
cd Backtick
vagrant up
```

After making changes to the source files, you can rebuild `dist/` as follows:

```
# either run it as one command:
vagrant ssh -- 'bash -l -c "cd /vagrant/ ; grunt build"'

# or do it interactively
vagrant ssh
cd /vagrant
grunt build
```

#### Why are you open sourcing this?
Because that's just something I like to do to contribute back to the community. It also forces me to write cleaner code. (Well, in theory at least.)

#### But wait, couldn't I just clone this repo and remove the nag dialog?
Yes, you absolutely could. That's why I've made it [extra easy for you](https://github.com/JoelBesada/Backtick/blob/master/extension/license.coffee#L2), just flip that boolean to true and you're good to go. However, a nicer option would be to actually buy [the license](http://goo.gl/LkPHMG) to support the continued development of Backtick.

