# [cp-swf](https://cpswf.barichello.me/)

An interactive archive of Club Penguin SWFs by year.

# About
## Archive

The SWF archive is included as a git submodule, the repository can be found here: [cp-swf-archive](https://gitlab.com/BARICHELLO/cp-swf-archive).<br>
Feel free to contribute by adding any missing files.

## Flash

This website uses flash to display Club Penguin's SWF files, here are instructions on how to enable flash plugin:

OS installation:
- [Linux](https://wiki.archlinux.org/index.php/Browser_plugins#Adobe_Flash_Player)
- [Windows](https://web.archive.org/web/20200615235629/https://get.adobe.com/flashplayer/)

Enabling flash on browser:
- [All browsers](https://enableflashplayer.com/)
- [Firefox (local development only)](https://support.mozilla.org/en-US/questions/1172126)

# Compiling

1. [Install Elm](https://guide.elm-lang.org/install/elm.html)
1. `git clone --recursive git@github.com:aBARICHELLO/cp-swf.git`
1. Using elm-live: `elm-live src/Main.elm --start-page=index.html -- --output=main.js --debug`
1. Update local archive file by running `tree -J cp-swf-archive > archive.json`
1. To use debug mode edit the flag in `index.html` to `true`, this redirects all archive requests to localhost
