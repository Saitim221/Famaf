module Pred (
  Pred,
  cambiar, anyDib, allDib, orP, andP, falla
) where

import Dibujo

type Pred a = a -> Bool

-- Dado un predicado sobre básicas, cambiar todas las que satisfacen
-- el predicado por la figura básica indicada por el segundo argumento.

cambiar :: Pred a -> (a -> Dibujo a) -> Dibujo a -> Dibujo a
cambiar p f a =  foldDib (\x -> if p x then change f (figura x) else figura x) rotar rot45 espejar apilar juntar encimar a

-- Alguna básica satisface el predicado.
anyDib :: Pred a -> Dibujo a -> Bool
anyDib p a = foldDib (\x -> p x) id id id (\_ _ x y-> x||y) (\_ _ x y-> x||y) (||) a 

-- Todas las básicas satisfacen el predicado.
allDib :: Pred a -> Dibujo a -> Bool
allDib p a = foldDib (\x -> p x) id id id (\_ _ x y-> x&&y) (\_ _ x y-> x||y) (&&) a 

-- Los dos predicados se cumplen para el elemento recibido.
andP :: Pred a -> Pred a -> Pred a
andP p f a = p a && f a


-- Algún predicado se cumple para el elemento recibido.
orP :: Pred a -> Pred a -> Pred a
orP p f a = p a || f a

falla = True