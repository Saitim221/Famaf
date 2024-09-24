module Dibujos.Grilla where

import Dibujo (Dibujo, figura, juntar, apilar, rot45, rotar, encimar, espejar)
import FloatingPic(Conf(..), Output, half, zero,Output,grid)
import qualified Graphics.Gloss.Data.Point.Arithmetic as V
import Graphics.Gloss

--import Distribution.Simple.Test (test)
import Interp
type Basica = (Int,Int)


row :: [Dibujo a] -> Dibujo a
row [] = error "row: no puede ser vacío"
row [d] = d
row (d:ds) = juntar 1 (fromIntegral $ length ds) d (row ds)

column :: [Dibujo a] -> Dibujo a
column [] = error "column: no puede ser vacío"
column [d] = d
column (d:ds) = apilar 1 (fromIntegral $ length ds) d (column ds)

grilla :: [[Dibujo a]] -> Dibujo a
grilla = column . map row

generartuplas :: [[Dibujo Basica]]
generartuplas = map (\x -> map (\y -> figura (x,y)) aux) aux 
    where aux = [0,1,2,3,4,5,6,7]

testAll :: Dibujo Basica
testAll = grilla generartuplas

interpBas :: Output Basica
interpBas a (x,y) _ _ =translate (x+10) (y+10) (scale 0.1 0.1 (text (show a)))



grillaConf :: Conf
grillaConf = Conf {
    name = "Grilla"
    , pic = testAll
    , bas = interpBas
}

--[[figura (0,0), figura (0,1), figura (0,2), figura (0,3), figura (0,4), figura (0,5), figura (0,6), figura (0,7)],[figura (1,0), figura (1,1), figura (1,2), figura (1,3), figura (1,4), figura (1,5), figura (1,6), figura (1,7)],[figura (2,0), figura (2,1), figura (2,2), figura (2,3), figura (2,4), figura (2,5), figura (2,6), figura (2,7)],[figura (3,0), figura (3,1), figura (3,2), figura (3,3), figura (3,4), figura (3,5), figura (3,6), figura (3,7)],[figura (4,0), figura (4,1), figura (4,2), figura (4,3), figura (4,4), figura (4,5), figura (4,6), figura (4,7)],[figura (5,0), figura (5,1), figura (5,2), figura (5,3), figura (5,4), figura (5,5), figura (5,6), figura (5,7)],[figura (6,0), figura (6,1), figura (6,2), figura (6,3), figura (6,4), figura (6,5), figura (6,6), figura (6,7)],[figura (7,0), figura (7,1), figura (7,2), figura (7,3), figura (7,4), figura (7,5), figura (7,6), figura (7,7)]]
