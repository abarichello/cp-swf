# [cp-swf](https://cpswf.barichello.me/)

An interactive archive of Club Penguin SWFs by year.

<figure>
    <a href="https://cpswf.barichello.me/">
    <img src="https://i.imgur.com/4kwlNLC.png"></a>
</figure>

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

# How it works

First a JSON file with the structure of the SWF folder is generated with `tree -J cp-swf-archive`, example:
```json
[
  {"type":"directory","name":".","contents":[
    {"type":"directory","name":"2017","contents":[
      {"type":"directory","name":"default","contents":[
        {"type":"file","name":"attic.swf"},
        // ...
      ]},
    {"type":"directory","name":"unknown","contents":[
      {"type":"file","name":"party10solo.swf"},
        // ...
    ]}
  {"type":"report","directories":9,"files":98}
]
```

Then this JSON gets decoded into the following recursive custom type:
```elm
type alias Archive =
    List Node

type Node
    = Directory { name : String, contents : List Node }
    | File String
    | Report { directories : Int, files : Int }
```

This gives the necessary tree structure to represent the files, their hierarchy and the total number of files and directories.

# Compiling and Debug

1. [Install Elm](https://guide.elm-lang.org/install/elm.html)
1. `git clone --recursive git@github.com:aBARICHELLO/cp-swf.git`
1. Using elm-live: `elm-live src/Main.elm --start-page=index.html -- --output=main.js --debug`
1. Update local archive file by running `tree -J cp-swf-archive > cp-swf-archive/archive.json`
1. To use debug mode edit the flag in `index.html` to `true`, this redirects all archive requests to `localhost:8000`
