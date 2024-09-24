module Dibujos.Escher(
    escherConf
) where
import Dibujo 
import FloatingPic(Conf(..), Output, half, zero)
import Graphics.Gloss (text, scale, translate, blank, line, polygon, pictures)
import qualified Graphics.Gloss.Data.Point.Arithmetic as V
import Dibujos.Grilla(grilla)    

-- Supongamos que eligen.
type Escher = Bool

figEscher :: Output Escher
figEscher True x y w =   line [x, x V.+ y, x V.+ y V.+ w, x V.+ w, x]
    where
        p33 = 3 V.* (uX V.+ uY)
        p13 = uX V.+ 3 V.* uY
        x4 = 4 V.* uX
        y5 = 5 V.* uY
        uX = (1/6) V.* y
        uY = (1/6) V.* w


blankEsch :: Dibujo Escher
blankEsch = figura False

-- El dibujo u.
dibujoU :: Dibujo Escher -> Dibujo Escher
dibujoU p = encimar4 (espejar (rot45 p))

-- El dibujo t.
dibujoT :: Dibujo Escher -> Dibujo Escher
dibujoT p = encimar p (encimar (espejar (rot45 p)) (r270 (espejar (rot45 p))))

-- Esquina con nivel de detalle en base a la figura p.
esquina :: Int -> Dibujo Escher -> Dibujo Escher                         
esquina 1 p = cuarteto blankEsch blankEsch blankEsch (dibujoU p)
esquina n p = cuarteto (esquina (n-1) p)        (lado (n-1) p) 
                       (rotar $ lado (n-1) p)   (dibujoU p)

-- Lado con nivel de detalle.
lado :: Int -> Dibujo Escher -> Dibujo Escher
lado 1 p = cuarteto blankEsch blankEsch (rotar $ dibujoT p) (dibujoT p)
lado n p = cuarteto (lado (n-1) p)       (lado (n-1) p) 
                    (rotar $ dibujoT p)  (dibujoT p)

-- Por suerte no tenemos que poner el tipo!
noneto p q r s t u v w x = grilla [[p, q, r], [s, t, u], [v, w, x]]

-- El dibujo de Escher:
escher :: Int -> Escher -> Dibujo Escher
escher n p = noneto 
             (esquina n (figura p))         (lado n (figura p))        (r270 $ esquina n (figura p)) 
             (rotar $ lado n (figura p))    (dibujoU $ figura p)       (r270 $ lado n (figura p)) 
             (rotar $ esquina n (figura p)) (r180 $ lado n (figura p)) (r180 $ esquina n (figura p)) 

interpBas :: Output Escher
interpBas False _ _ _ = blank
interpBas True x y w = figEscher True x y w        -- EN ESA FUNCION ESTA EL DIBUJO BASICO

testAll :: Dibujo Escher
testAll = grilla [[escher 7 True]]                 -- ACA SE REGULA LA COMPLEJIDAD DEL DIBUJO

escherConf :: Conf
escherConf = Conf {
    name = "Escher"
    , pic = testAll
    , bas = interpBas
}