module Main where

import Test.HUnit
import Dibujo

import System.Exit (exitFailure)

-- Test rot45 function
testRot45 :: Test
testRot45 = TestCase $ assertEqual
    "rot45 function failed"
    (rot45 (figura 'a'))
    (Rotar45 (Figura 'a'))



-- Test figuras
testFiguras :: Test
testFiguras = TestCase $ assertEqual
    "Test figuras y "
    ["Cuadrado", "Circulo"]
    (figuras (Apilar 1.0 1.0 (Figura "Cuadrado") (Figura "Circulo")))

-- Test rotar90
testRotar90 :: Test
testRotar90 = TestCase $ assertEqual
    "rotar90 function with  failed"
    (rotar (Apilar 1.0 1.0 (Figura 'a') (Figura 'b')))
    (Rotar90 (Apilar 1.0 1.0 (Figura 'a') (Figura 'b')))

-- Test espejar
testEspejar :: Test
testEspejar = TestCase $ assertEqual
    "espejar function with  failed"
    (espejar (Apilar 1.0 1.0 (Figura 'a') (Figura 'b')))
    (Espejar (Apilar 1.0 1.0 (Figura 'a')  (Figura 'b')))

-- Test rotar45
testRotar45 :: Test
testRotar45 = TestCase $ assertEqual
    "rotar45 function with  failed"
    (rot45 (Apilar 1.0 1.0 (Figura 'a') (Figura 'b')))
    (Rotar45 (Apilar 1.0 1.0 (Figura 'a') (Figura 'b')))

-- Test encimar
testEncimar :: Test
testEncimar = TestCase $ assertEqual
    "encimar function with  failed"
    (encimar (Apilar 1.0 1.0 (Figura 'a') (Figura 'b')) (Apilar 1.0 1.0 (Figura 'c') (Figura 'd')))
    (Encimar (Apilar 1.0 1.0 (Figura 'a') (Figura 'b')) (Apilar 1.0 1.0 (Figura 'c') (Figura 'd')))

-- Test apilar
testApilar :: Test
testApilar = TestCase $ assertEqual
    "apilar function with  failed"
    (apilar 1.0 1.0 (apilar 1.0 1.0 (Figura 'a') (Figura 'b')) (apilar 1.0 1.0 (Figura 'c') (Figura 'd')))
    (Apilar 1.0 1.0 (Apilar 1.0 1.0 (Figura 'a') (Figura 'b')) (Apilar 1.0 1.0 (Figura 'c') (Figura 'd')))

-- Test juntar
testJuntar :: Test
testJuntar = TestCase $ assertEqual
    "juntar function with  failed"
    (juntar 1.0 1.0 (Apilar 1.0 1.0 (Figura 'a') (Figura 'b')) (Apilar 1.0 1.0 (Figura 'c') (Figura 'd')))
    (Juntar 1.0 1.0 (Apilar 1.0 1.0 (Figura 'a') (Figura 'b')) (Apilar 1.0 1.0 (Figura 'c') (Figura 'd')))

-- Test rotar90 con foldDib
testRotar90FoldDib :: Test
testRotar90FoldDib = TestCase $ assertEqual
    "rotar90 function with foldDib failed"
    (foldDib
        (\a -> Rotar90 a)             -- Función para figuras
        (\x -> Rotar90 x)             -- Función para rotar90
        (\x -> Espejar x)             -- Función para espejar
        (\x -> Rotar45 x)             -- Función para rotar45
        (\e i a b -> Apilar e i a b)  -- Función para apilar
        (\e i a b -> Juntar e i a b)  -- Función para juntar
        (\x y -> Encimar x y)         -- Función para encimar
        (Rotar90 (Apilar 1.0 1.0 (figura (figura 'a')) (figura(figura 'b')))))
    (Rotar90 (Apilar 1.0 1.0 (Rotar90 (Figura 'a')) (Rotar90 (Figura 'b'))))

-- Test espejar con foldDib
testEspejarFoldDib :: Test
testEspejarFoldDib = TestCase $ assertEqual
    "espejar function with foldDib failed"
    (foldDib
        (\a -> Espejar a)             -- Función para figuras
        (\x -> Rotar90 x)             -- Función para rotar90
        (\x -> Espejar x)             -- Función para espejar
        (\x -> Rotar45 x)             -- Función para rotar45
        (\e i a b -> Apilar e i a b)  -- Función para apilar
        (\e i a b -> Juntar e i a b)  -- Función para juntar
        (\x y -> Encimar x y)         -- Función para encimar
        (Espejar (Apilar 1.0 1.0 (figura (figura 'a')) (figura (figura 'b')))))
    (Espejar (Apilar 1.0 1.0 (Espejar (Figura 'a')) (Espejar (Figura 'b'))))

-- Test rotar45 con foldDib
testRotar45FoldDib :: Test
testRotar45FoldDib = TestCase $ assertEqual
    "rotar45 function with foldDib failed"
    (foldDib
        (\a -> Rotar45 a)             -- Función para figuras
        (\x -> Rotar90 x)             -- Función para rotar90
        (\x -> Espejar x)             -- Función para espejar
        (\x -> Rotar45 x)             -- Función para rotar45
        (\e i a b -> Apilar e i a b)  -- Función para apilar
        (\e i a b -> Juntar e i a b)  -- Función para juntar
        (\x y -> Encimar x y)         -- Función para encimar
        (Rotar45 (Apilar 1.0 1.0 (figura (figura 'a')) (figura (figura 'b')))))
    (Rotar45 (Apilar 1.0 1.0 (Rotar45 (Figura 'a')) (Rotar45 (Figura 'b'))))




-- Test para mapDib con el constructor Figura
testMapFigura :: Test
testMapFigura = TestCase (assertEqual "Test mapDib con Figura" (figura(figura "Cuadrado") ) (mapDib figura (Figura "Cuadrado")))

-- Test para mapDib con el constructor Rotar90
testMapRotar90 :: Test
testMapRotar90 = TestCase (assertEqual "Test mapDib con Rotar90" (Rotar90 (figura(figura "Circulo"))) (mapDib figura (Rotar90 (Figura "Circulo"))))

-- Test para mapDib con el constructor Espejar
testMapEspejar :: Test
testMapEspejar = TestCase (assertEqual "Test mapDib con Espejar" (Espejar (figura(figura "Triangulo"))) (mapDib figura (Espejar (Figura "Triangulo"))))

-- Test para mapDib con el constructor Rotar45
testMapRotar45 :: Test
testMapRotar45 = TestCase (assertEqual "Test mapDib con Rotar45" (Rotar45(figura(figura "Rombo"))) (mapDib figura (Rotar45 (Figura "Rombo"))))


-- Lista de todos los tests
tests :: Test
tests = TestList [
    TestLabel "testFiguras" testFiguras,
    TestLabel "testRotar90" testRotar90,
    TestLabel "testEspejar" testEspejar,
    TestLabel "testRotar45" testRotar45,
    TestLabel "testEncimar" testEncimar,
    TestLabel "testApilar" testApilar,
    TestLabel "testJuntar" testJuntar,
    TestLabel "testRotar90FoldDib" testRotar90FoldDib,
    TestLabel "testEspejarFoldDib" testEspejarFoldDib,
    TestLabel "testRotar45FoldDib" testRotar45FoldDib,
    TestLabel "testMapFigura" testMapFigura,
    TestLabel "testMapRotar90" testMapRotar90,
    TestLabel "testMapEspejar" testMapEspejar,
    TestLabel "testMapRotar45" testMapRotar45
    ]


-- Ejecutar los tests
main :: IO ()
main = do
    counts <- runTestTT tests
    if errors counts + failures counts == 0
        then putStrLn "Todos los tests pasaron."
        else exitFailure
