module Logic.Template.SaveLoad.Internal.Decode exposing
    ( andMap
    , float
    , id
    , list
    , sequence
    , sizedString
    , xy
    , xyz
    )

import Bytes exposing (Bytes, Endianness(..))
import Bytes.Decode as D exposing (Decoder, Step(..), andThen, loop, map, succeed, unsignedInt32)


sequence : List (Decoder (a -> a)) -> Decoder (a -> a)
sequence =
    List.foldl (D.map2 (<<)) (D.succeed identity)



--
--decodeWithTexture : List (Decoder (b -> a -> a)) -> Bytes -> Maybe (b -> a -> a)
--decodeWithTexture decoders =
--    D.decode (sequence2 (List.reverse decoders))


sequence2 : List (Decoder (b -> a -> a)) -> Decoder (b -> a -> a)
sequence2 =
    List.foldl (D.map2 composeBAA) (D.succeed (\_ a -> a))


composeBAA : (b -> a -> a) -> (b -> a -> a) -> b -> a -> a
composeBAA f g b a =
    f b (g b a)


andMap : Decoder a -> Decoder (a -> b) -> Decoder b
andMap =
    D.map2 (|>)


float : Decoder Float
float =
    D.float32 BE


xy : Decoder { x : Float, y : Float }
xy =
    D.map2 (\x y -> { x = x, y = y })
        float
        float


xyz : Decoder { x : Float, y : Float, z : Float }
xyz =
    D.map3 (\x y z -> { x = x, y = y, z = z })
        float
        float
        float


id : Decoder Int
id =
    D.unsignedInt32 BE


sizedString : Decoder String
sizedString =
    D.unsignedInt32 BE
        |> D.andThen D.string


list : Decoder a -> Decoder (List a)
list decoder =
    unsignedInt32 BE
        |> andThen (\len -> loop ( len, [] ) (listStep decoder))


listStep : Decoder a -> ( Int, List a ) -> Decoder (Step ( Int, List a ) (List a))
listStep decoder ( n, xs ) =
    if n <= 0 then
        succeed (Done xs)

    else
        map (\x -> Loop ( n - 1, x :: xs )) decoder
