Lab 2 - Programación orientada a objetos
Dependencias
Necesitan Java 17, tanto el JRE como el JDK. En Ubuntu, pueden instalarlo con:

apt install openjdk-17-jdk openjdk-17-jre
Compilación y ejecución
Para compilar el código ejecutamos make, lo cual crea todos los archivos compilados en el directorio ./bin

Para correr el código ejecutamos make run ARGS="<flags>" donde son las flags que corresponden a los args toma la función principal del software.

make clean borra los archivos .class que se generan en la compilación

---
title: Laboratorio de Programación Orientada a Objetos
author: Santiago Afonso Osorio, Jeremías Broin Luque, Santino Cirico
---

El enunciado del laboratorio se encuentra en [este link](https://docs.google.com/document/d/1wLhuEOjhdLwgZ4rlW0AftgKD4QIPPx37Dzs--P1gIU4/edit#heading=h.xe9t6iq9fo58).

# 1. Tareas
Pueden usar esta checklist para indicar el avance.

## Verificación de que pueden hacer las cosas.
- [ ] Java 17 instalado. Deben poder compilar con `make` y correr con `make run` para obtener el mensaje de ayuda del programa.

## 1.1. Interfaz de usuario
- [ ] Estructurar opciones
- [ ] Construir el objeto de clase `Config`

## 1.2. FeedParser
- [ ] `class Article`
    - [ ] Atributos
    - [ ] Constructor
    - [ ] Método `print`
    - [ ] _Accessors_
- [ ] `parseXML`

## 1.3. Entidades nombradas
- [ ] Pensar estructura y validarla con el docente
- [ ] Implementarla
- [ ] Extracción
    - [ ] Implementación de heurísticas
- [ ] Clasificación
    - [ ] Por tópicos
    - [ ] Por categorías
- Estadísticas
    - [ ] Por tópicos
    - [ ] Por categorías
    - [ ] Impresión de estadísticas

## 1.4 Limpieza de código
- [ ] Pasar un formateador de código
- [ ] Revisar TODOs

# 2. Experiencia
El objetivo principal de este laboratorio fue aprender POO a través de la lectura del título, descripción, fecha y link de artículos que se encontraban en páginas xml.
En el desarrollo del mismo utilizamos diferentes clases de Java con diferentes objetivos cada uno y también creamos algunas que eran necesarias.
Entre los principales desafíos fueron la lectura de la página xml y la estructura del método run de la clase App (junto al entendimiento del userInterface.java y config.java que está requería).
También durante el lab pudimos desenvolvernos y reforzar nuestros conocimientos para el uso de chatgpt y copylot para aquellas veces que no sabíamos realizar lo que teníamos en mente.

Luego de las correcciones pertinentes al laboratorio, pudimos aprovechar el POO para permitir que nuestro código tenga una lectura más sencilla, y además sea expansible. esto a través de crear las llamadas a objetos, que a su vez permitan que no tengamos que reescribir código que ya tenemos.

# 3. Preguntas
1. Explicar brevemente la estructura de datos elegida para las entidades nombradas.
La estructura de datos elegida para las entidades nombradas, es un objeto con atributos para su categoría, nombre de la entidad y tópicos. Además esta estructura de datos entidades, tiene otras clases heredadas correspondiente a cada categoría, en la carpeta categoryClass. Cada una de estas clases, hereda todos los atributos de namedEntity a los que le asigna también características propias de su categoría. Por lo que una entidad nombrada, que sea de la clase persona, tendrá todos los atributos y funciones de la clase named entity (al igual que un objeto de cualquier otra clase que sea una categoría) más atributos propios de persona.


2. Explicar brevemente cómo se implementaron las heurísticas de extracción.
Nuestras heurísticas de extracción están implementadas de forma similar a la heurística que nos proveyó la cátedra, nos basamos en las palabras del texto sin los signos de puntuación (exceptuando en una que se basa en los puntos, por ello los dejamos)
Nuestra primera heurística "two times" se fija si esa misma palabra aparece otras veces pero en minúscula. Esto logra que palabras comunes como esta, las, la, etc no sean consideradas como named entities. Tiene 2 posibles fallas que le encontramos fácilmente: la primera es que si es una palabra no named entities pero es la única vez que aparece y lo hace en mayúsculas, entonces la tomará igual. La segunda es que ciertas palabras que admiten doble significado serán descartadas cuando no deberían, ejemplo: Argentina, ya que también podría ser encontrada la frase "la chica argentina".
Nuestra segunda heurística "AfterPoint" se fija si las palabras con mayúsculas vienen después de un punto y en ese caso no las agrega a nuestras named entities, esto puede descartar un montón de palabras que no deberían eliminarse, pero suele funcionar bien ya que los nombres propios suelen repetirse alguna otra vez (probablemente está otra vez no después de un punto) y que las frases en el español no suelen empezar con un nombre propio (muchas veces)


### TODOS:
x- Abstraer heurísticas, y usar la abstracción para quitar bloques de código repetido
x- Reescribir Entity y NamedEntity utilizando correctamente el paradigma
x- Modularizar adecuadamente la funcionalidad dentro de NamedEntity
x- Revisar nombres de clases y de métodos
- Statistics: cambiar nombres y reestructurar pensando en OOP
-[X] Reformateen App. La función principal tiene que ser escueta
[X] Print help muevanlo a user interface
-[X] Revisar caso de uso `-sf inexistente`
x- Esta parte del enunciado se la saltearon: "Las entidades nombradas de diferentes categorías deben tener al menos una característica propia de la categoría (excepto por la categoría OTHER). Por ejemplo, una entidad nombrada de la categoría LOCATION puede tener atributos de longitud y latitud. No se preocupen por como obtener los valores de estas características, simplemente piensen que la estructura las debe contemplar." Piensen como reestructurar NamedEntities teniendo esto.
