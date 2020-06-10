module Requests exposing (ArchiveJSON(..), fetchArchive)

import Http


type ArchiveJSON
    = JSON (Result Http.Error String)


archiveEndpoint : String
archiveEndpoint =
    "https://cpswf.barichello.me/cp-swf-archive/archive.json"


fetchArchive : Cmd ArchiveJSON
fetchArchive =
    Http.get
        { url = archiveEndpoint
        , expect = Http.expectString JSON
        }
