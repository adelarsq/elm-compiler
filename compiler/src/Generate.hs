module Generate
  ( Output(..)
  , generate
  , JS.generateForRepl
  )
  where

import qualified Data.Map as Map
import qualified Data.Set as Set
import qualified Data.ByteString.Builder as B

import qualified Generate.Mode as Mode
import qualified AST.Optimized as Opt
import qualified AST.Module.Name as ModuleName
import qualified Elm.Name as N

import qualified Generate.JavaScript as JS
import qualified Generate.WebAssembly as WA


data Output
  = None
  | Some N.Name [N.Name] B.Builder


generate :: Mode.Mode -> Opt.Graph -> [ModuleName.Canonical] -> Output
generate mode (Opt.Graph mains graph _fields) roots =
  let
    rootSet = Set.fromList roots
    rootMap = Map.restrictKeys mains rootSet
  in
  case map ModuleName._module (Map.keys rootMap) of
    [] ->
      None

    name:names ->
      let
        builder =
          case mode of
            Mode.Wat fieldIndices ->
              WA.generateWat mode graph rootMap

            _ ->
              JS.generateJs mode graph rootMap
      in
        Some name names builder
