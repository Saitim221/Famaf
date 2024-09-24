module Main where

import Test.HUnit
import Pred
import Dibujo

import System.Exit (exitFailure)

-- Test cambiar
testCambiar = TestCase(assertEqual "Test cambiar" (figura 2) 
    (cambiar (==1) (const (figura 2)) (figura 1)))

-- Test AnyDib
testAnyDib = TestCase(assertEqual "Test anyDib" True 
    (anyDib (== "Cuadrado") (encimar (Figura "Cuadrado") (Figura "Circulo"))))

-- Test AllDib
testAllDib = TestCase(assertEqual "Test allDib" False (allDib (=="Triangulo") 
    (encimar (Figura "Cuadrado") (Figura "Triangulo")))) 

-- Test AndP (usa auxiliarAnyAll)
testAndP = TestCase(assertEqual "Test andP" False (andP (=="Triangulo") 
    (=="Cuadrado con formas raras") "Cuadrado con formas raras"))

-- Test orP (usa auxiliarAnyAll)
testOrP = TestCase(assertEqual "Test orP" True 
    (orP (== "Octogono") (=="Figura rara") "Figura rara"))

testPred = 
    TestList [testCambiar, testAnyDib, testAllDib, testAndP, testOrP]
-- Lista de todos los tests
tests :: Test
tests = TestList [
    TestLabel "testCambiar" testCambiar,
    TestLabel "testAnyDib" testAnyDib,
    TestLabel "testAllDib" testAllDib,
    TestLabel "testAndP" testAndP,
    TestLabel "testOrP" testOrP
    ]

-- Run the tests
main :: IO ()
main = do
    counts <- runTestTT tests
    if errors counts + failures counts == 0
        then putStrLn "All tests passed."
        else exitFailure
