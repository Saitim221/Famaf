---
title: Laboratorio de Funcional
author: Santiago Afonso Osorio, Jeremías Broin Luque, Santino Cirico
---
La consigna del laboratorio está en https://tinyurl.com/funcional-2024-famaf

# 1. Tareas
Pueden usar esta checklist para indicar el avance.

## Verificación de que pueden hacer las cosas.
- [X] Haskell instalado y testeos provistos funcionando. (En Install.md están las instrucciones para instalar.)

## 1.1. Lenguaje
- [X] Módulo `Dibujo.hs` con el tipo `Dibujo` y combinadores. Puntos 1 a 3 de la consigna.
- [X] Definición de funciones (esquemas) para la manipulación de dibujos.
- [X] Módulo `Pred.hs`. Punto extra si definen predicados para transformaciones innecesarias (por ejemplo, espejar dos veces es la identidad).

## 1.2. Interpretación geométrica
- [X] Módulo `Interp.hs`.

## 1.3. Expresión artística (Utilizar el lenguaje)
- [X] El dibujo de `Dibujos/Feo.hs` se ve lindo.
- [X] Módulo `Dibujos/Grilla.hs`.
- [X] Módulo `Dibujos/Escher.hs`.
- [X] Listado de dibujos en `Main.hs`.

## 1.4 Tests
- [X] Tests para `Dibujo.hs`.
- [X] Tests para `Pred.hs`.

# 2. Experiencia
En este lab nos enfrentamos a crear un DSL que consistia en una serie de dibujos que podiamos armar y su interpretacion para poder graficarlos. Para ello tuvimos que definir la sintaxis para poder hacer los dibujos y las diferentes funciones que interactuaban con ellos. Luego, en la parte semantica, definimos como nuestro DSL interpretaba los dibujos que les mandabamos y las mencionadas funciones.
Una vez terminada la sintaxis y la semantica el lenguaje nos permitia crear dibujos e interactuar con ellos para crear nuevos. 
Si bien la creacion de la sintaxis no fue tan dificil para nuestro grupo, mas allá de la interpretacion del tipo dibujo y como interactuaban ciertas funciones con el tipo. La implementacion del interprete (la semantica del lenguaje) fue desafiante debido a que no terminabamos de entender el funcionamiento de las pictures y como se representaban en el gloss. Sobre todo porque tardamos en notar que las "figuras" propiamente dichas, es decir las basicas de cada dibujo (dicho de esta forma ahora una vez terminado y entendido) eran dibujadas y definidas en cada archivo de la carpeta Dibujo que le correspondia, por lo cual nosotros no debiamos trazar las lineas de cada dibujo en esta parte semantica. Sino simplemente dar una implementación a las funciones que habiamos definido en la sintaxis de nuestro DSL.
El lab nos sirvio para poder hacer la diferenciacion entre sintaxis y semantica de una manera mas profunda, y entender (a nivel basico) por que y para que los lenguajes de programacion tienen cada modulo correspondiente.
Las caracteristicas de este laboratorio (la creacion de dibujos y sobretodo de un dibujo a partir de otros hasta llegar a figuras basicas) eran propias para la utilizacion de un lenguaje funcional, por lo que nos planteamos que el uso de haskell era logico para este laboratorio.


# 3. Preguntas
Al responder tranformar cada pregunta en una subsección para que sea más fácil de leer.

1. ¿Por qué están separadas las funcionalidades en los módulos indicados? Explicar detalladamente la responsabilidad de cada módulo.

Las funcionalidades de los modulos estan separados para mayor abstraccion en nuestro lenguaje y una mejor organizacion a la hora de programar.

Podemos distinguir los modulos:

    Dibujos: Definimos nuestro tipo Dibujo a partir de una figura o constructores para poder modificar otros dibujos. Logrando a partir de la combinacion de estos constructores diversos dibujos. A parte definimos otras funciones como mapDib o FoldDib, entre otras. Que nos permiten interactuar con la estructura de nuestro tipo dibujo, que es propia de este archivo. Logrando asi la abstracción buscada en este laboratorio respecto al resto de modulos.  

    Pred: Este modulo nos permite, a partir de una sentencia, generar un booleano que nos diga si esta sentencia se cumple en todo el dibujo o en alguna parte del dibujo. Tambien podemos modificar el dibujo a partir de si ciertas partes del mismo cumplen o no la sentencia. 

    FlaotingPic: Este modulo nos presenta la definicion de nuestro Output y nos provee de funciones que nos permiten trabajar con los vectores de nuestros dibujos (cosa fundamental para nuestro Output).

    Interp: En el interp trabajamos con la semántica de nuestro lenguaje. Este modulo es el que propiamente interpreta la sintaxis correspondiente del tipo Dibujo y sus funciones y define como se hacen las diferentes transformaciones de un dibujo en nuestro DSL. En este modulo trabajamos con los vectores que le corresponden a cada floatingpic que es parte del dibujo, para asi poder transformar el dibujo correctamente.

    A parte en la carpeta dibujo podemos encontrar diferentes tipos de dibujos, son estos los que definen un tipo "basico" del dibujo a partir del cual se ira construyendo todo. Cada dibujo tiene su propio tipo basico y la generacion del dibujo en gloss del mismo. Tambien cada archivo distinto tiene una grilla de fondo que indica en que parte de la pantalla se debe imprimir cada dibujo que forma el dibujo total.

2. ¿Por qué las figuras básicas no están incluidas en la definición del lenguaje, y en vez de eso, es un parámetro del tipo?

Para tratar cada dibujo como una composicion de transformaciones sobre figuras de manera general, a las cuales les podemos aplicar las funcionalidades que nos sean necesarias, por la definicion de nuestro lenguaje. Luego los diferentes dibujos trabajaran con diferentes figuras basicas y gracias a como esta implementado nuestro lenguaje. No será necesario redefinir las funciones que interactuaran con nuestras figuras ni dibujos nuevas, y a su vez permite que cada dibujo solo tenga que "crear" la figura basica que ese dibujo utiliza, y su interpretacion. De esta forma, los dibujos, no tendrán que interpretar figuras basicas que pueden no ser usadas en ese dibujo pero si en otros. Para esto es importante la separacion del lenguaje en modulos que nos permiten tener las funcionalidades de los dibujos por un lado, mientras cada archivo define sus propias figuras basicas que interactuan con estas funcionalidades por el otro.

3. ¿Qué ventaja tiene utilizar una función de `fold` sobre hacer pattern-matching directo?

Las ventajas que tiene la utilizacion de una función fold sobre hacer pattern-matching directo son:
- La capacidad de abstraccion de nuestro DSL, debido a que la implementacion del tipo Dibujo es propio del archivo Dibujo.hs, entonces no podriamos hacer patter-matching sobre el mismo si no podemos acceder a esta definición
- Una mejor lectura del código ya que gracias a fold muchas de las funciones se pueden escribir en una sola linea de codigo. Mientras si usaramos pattern-matching deberiamos usar una linea por cada posible constructor del tipo dibujo.


4. ¿Cuál es la diferencia entre los predicados definidos en Pred.hs y los tests?

Los predicados definidos en Pred.hs toman una sentencia que se pueda aplicar sobre un dibujo completo o sobre parte de el y analiza su valor de verdad sobre el dibujo que le pasamos. Ahora en los test que nosotros realizamos le pasamos un dibujo hecho a partir de funcionalidades de nuestro lenguaje y corroboramos que el dibujo final sea igual a otro dibujo realizado a traves de los constructores del tipo dibujo (esto es mas comodo de realizar a traves de los unit test).
Es decir nosotros en el Pred.hs damos un valor de verdad sobre una sentencia para nuestro dibujo, mientras que en los test, luego de construir un dibujo a traves de las funcionalidades que queremos probar, chequeamos que sea igual a la construccion manual de ese dibujo.

# 4. Extras

En la grilla propuesta en el kickstart, del archivo grilla.hs. Las variables para apilar y juntar las columnas y filas estaban puestas al reves, por lo que debimos cambiarlas para que quede bien el dibujo.
En un principio nuestros test devolvian "some test failed" en caso de que se encuentren errores al final, el problema de eso es que nos indicaba que pasaba los test incluso cuando no debia y nos creaba un archivo donde al final si decia "some test failed", nuestra solucion a eso es que en caso de fallar nos da un exitFailure.