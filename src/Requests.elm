module Requests exposing (ArchiveJSON(..), fetchArchive)

import Http


type ArchiveJSON
    = JSON (Result Http.Error String)


archiveEndpoint : String
archiveEndpoint =
    "https://cpswf.barichello.me/cp-swf-archive/archive.json"


debugEndpoint : String
debugEndpoint =
    "http://localhost:8000/cp-swf-archive/archive.json"


fetchArchive : Bool -> Cmd ArchiveJSON
fetchArchive debug =
    Http.get
        { url =
            if debug then
                debugEndpoint

            else
                archiveEndpoint
        , expect = Http.expectString JSON
        }
