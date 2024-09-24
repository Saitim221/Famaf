module Dibujo --(encimar, figura,apilar,juntar,rot45,foldDib,espejar,Dibujo,change,rotar,r270,encimar4,cuarteto,r180)
    -- agregar las funciones constructoras
     where

--import Graphics.Gloss



-- nuestro lenguaje 
data TriORect = Triangulo | Rectangulo deriving (Eq, Show)

data Dibujo a =
    Figura a
  | Rotar90 (Dibujo a)
  | Espejar (Dibujo a)
  | Rotar45 (Dibujo a)
  | Apilar Float Float (Dibujo a) (Dibujo a)
  | Juntar Float Float (Dibujo a) (Dibujo a)
  | Encimar (Dibujo a) (Dibujo a)
  deriving (Eq,Show)


type Fantastica = Dibujo TriORect

-- combinadores
infixr 6 ^^^

infixr 7 .-.

infixr 8 ///




-- Funciones constructoras


figura :: a -> Dibujo a
figura  = Figura


encimar :: Dibujo a -> Dibujo a -> Dibujo a
encimar = Encimar 

apilar :: Float -> Float -> Dibujo a -> Dibujo a -> Dibujo a
apilar = Apilar

juntar  :: Float -> Float -> Dibujo a -> Dibujo a -> Dibujo a
juntar = Juntar 

rot45 :: Dibujo a -> Dibujo a
rot45 = Rotar45

rotar :: Dibujo a -> Dibujo a
rotar = Rotar90

espejar :: Dibujo a -> Dibujo a
espejar = Espejar



-- Superpone un dibujo con otro.
(^^^) :: Dibujo a -> Dibujo a -> Dibujo a
(^^^) x y = encimar x y 

-- Pone el primer dibujo arriba del segundo, ambos ocupan el mismo espacio.
(.-.) :: Dibujo a -> Dibujo a -> Dibujo a
(.-.) x y = apilar 1.0 1.0 x y

-- Pone un dibujo al lado del otro, ambos ocupan el mismo espacio.
(///) :: Dibujo a -> Dibujo a -> Dibujo a
(///) x y = juntar 1.0 1.0 x y

comp :: Int -> (a -> a) -> a -> a
comp 0 f x=  x
comp n f x = comp (n-1) f (f x)


-- rotaciones
r90 :: Dibujo a -> Dibujo a
r90 = Rotar90

r180 :: Dibujo a -> Dibujo a
r180  x = comp 2 Rotar90 x

r270 :: Dibujo a -> Dibujo a
r270 x = comp 3 Rotar90 x

-- una figura repetida con las cuatro rotaciones, superimpuestas.
encimar4 :: Dibujo a -> Dibujo a
encimar4 x = (^^^) ((^^^) x (r90 x)) ((^^^) (r180 x)  (r270 x))

-- cuatro figuras en un cuadrante.
cuarteto :: Dibujo a -> Dibujo a -> Dibujo a -> Dibujo a -> Dibujo a
cuarteto x y z w = (.-.)((///)x y) ((///)z w)

-- un cuarteto donde se repite la imagen, rotada (¡No confundir con encimar4!)
ciclar :: Dibujo a -> Dibujo a
ciclar x= (///)((.-.)x (r90 x))((.-.)(r180 x) (r270 x))


-- map para nuestro lenguaje
mapDib :: (a -> b) -> Dibujo a -> Dibujo b
mapDib f (Figura a) = Figura (f a)
mapDib f (Rotar90 a) = Rotar90 (mapDib f a) 
mapDib f (Espejar a) = Espejar (mapDib f a)
mapDib f (Rotar45 a) = Rotar45 (mapDib f a)
mapDib f (Apilar x y a b) = Apilar x y (mapDib f a) (mapDib f b)
mapDib f (Juntar x y a b) = Juntar x y (mapDib f a) (mapDib f b)
mapDib f (Encimar a b) = Encimar (mapDib f a) (mapDib f b)
-- verificar que las operaciones satisfagan
-- 1. map figura = id
-- 2. map (g . f) = mapDib g . mapDib f

-- Cambiar todas las básicas de acuerdo a la función.
change :: (a -> Dibujo b) -> Dibujo a -> Dibujo b
change f (Figura a)= f a
change f (Rotar90 a) = Rotar90(change f a) 
change f (Espejar a) = Espejar (change f a)
change f (Rotar45 a) = Rotar45 (change f a)
change f (Apilar x y a b) = Apilar x y (change f a) (change f b)
change f (Juntar x y a b) = Juntar x y (change f a) (change f b)
change f (Encimar a b) = Encimar (change f a) (change f b)

-- Principio de recursión para Dibujos.
foldDib ::
  (a -> b) ->
  (b -> b) ->
  (b -> b) ->
  (b -> b) ->
  (Float -> Float -> b -> b -> b) ->
  (Float -> Float -> b -> b -> b) ->
  (b -> b -> b) ->
  Dibujo a ->
  b

  
foldDib f x y z w v p (Figura a) = f(a) 
foldDib f x y z w v p (Rotar90 a)  = x (foldDib f x y z w v p a)
foldDib f x y z w v p (Espejar a)  = y (foldDib f x y z w v p a)
foldDib f x y z w v p (Rotar45 a)  = z (foldDib f x y z w v p a)
foldDib f x y z w v p (Apilar e i a b)  = w e i (foldDib f x y z w v p a) (foldDib f x y z w v p b)
foldDib f x y z w v p (Juntar e i a b)  = v e i (foldDib f x y z w v p a) (foldDib f x y z w v p b)
foldDib f x y z w v p (Encimar a b) = p (foldDib f x y z w v p a) (foldDib f x y z w v p b)

figuras :: Dibujo a -> [a]
figuras (Figura a) =  [a]
figuras (Rotar45 a) = figuras a  
figuras (Espejar a) = figuras a 
figuras (Rotar90 a) = figuras a 
figuras (Apilar x y a b) = (figuras a) ++ (figuras b)
figuras (Juntar x y a b) = (figuras a) ++ (figuras b)
figuras (Encimar a b) = (figuras a) ++ (figuras b)