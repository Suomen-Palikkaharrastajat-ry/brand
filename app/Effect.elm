module Effect exposing (Effect, batch, fromCmd, map, none, perform)

import Browser.Navigation
import Form
import Http
import Pages.Fetcher
import Url exposing (Url)


type Effect msg
    = None
    | Cmd (Cmd msg)
    | Batch (List (Effect msg))


none : Effect msg
none =
    None


fromCmd : Cmd msg -> Effect msg
fromCmd =
    Cmd


batch : List (Effect msg) -> Effect msg
batch =
    Batch


map : (a -> b) -> Effect a -> Effect b
map fn effect =
    case effect of
        None ->
            None

        Cmd cmd ->
            Cmd (Cmd.map fn cmd)

        Batch effects ->
            Batch (List.map (map fn) effects)


type alias FormData =
    { fields : List ( String, String )
    , method : Form.Method
    , action : String
    , id : Maybe String
    }


perform :
    { fetchRouteData :
        { data : Maybe FormData
        , toMsg : Result Http.Error Url -> pageMsg
        }
        -> Cmd msg
    , submit :
        { values : FormData
        , toMsg : Result Http.Error Url -> pageMsg
        }
        -> Cmd msg
    , fromPageMsg : pageMsg -> msg
    , runFetcher : Pages.Fetcher.Fetcher pageMsg -> Cmd msg
    , key : Browser.Navigation.Key
    , setField : { formId : String, name : String, value : String } -> Cmd msg
    }
    -> Effect pageMsg
    -> Cmd msg
perform ({ fromPageMsg } as helpers) effect =
    case effect of
        None ->
            Cmd.none

        Cmd cmd ->
            Cmd.map fromPageMsg cmd

        Batch effects ->
            List.map (perform helpers) effects
                |> Cmd.batch
