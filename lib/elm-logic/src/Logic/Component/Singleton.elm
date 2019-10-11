module Logic.Component.Singleton exposing (Spec, update, cursor)

{-|

@docs Spec, update, cursor

-}


{-| Main way of creating ECS "anti-pattern", but time to time you need to create some component that can exist only one per whole application (viewport, keyboard, websocket-connection, etc. )
-}
type alias Spec comp world =
    { get : world -> comp
    , set : comp -> world -> world
    }


{-| Update whole component set, can be used also with `Component.Set` (not only `Singleton`)
-}
update : { get : world -> comp, set : comp -> world -> world } -> (comp -> comp) -> world -> world
update spec f world =
    spec.set (f (spec.get world)) world


{-| Helper function to create nested components
-}
cursor : Spec subWorld world -> Spec comp subWorld -> Spec comp world
cursor spec2 spec1 =
    { get = spec2.get >> spec1.get
    , set =
        \comp world ->
            spec2.set (spec1.set comp (spec2.get world)) world
    }
