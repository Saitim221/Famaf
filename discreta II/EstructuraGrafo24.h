#ifndef ESTRUCTURAGRAFO24_H
#define ESTRUCTURAGRAFO24_H
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>
#include <string.h>
#include "APIG24.h"

typedef unsigned int u32;

typedef struct GrafoSt *Grafo;

typedef unsigned int color;

struct Vertice{
  bool empty ;    //al inicializar los vertices tengo que poner quienes estan en uso y quienes no
  u32 nombre;     //id de cada vertice corresponde su posicion con su nombre ej:grafo->vertice[1].nombre=1
  color color;    //color del vertice en cuestion
  u32 cant_vecinos;     //cantidad de vecinos esto sirve para saber el grado del vertice
  u32 total_vecinos;    //sirve para reallocar memoria a la hora de añadir vecinos a un vertice este es exponencial
  struct Vertice** vecinos; //array de vecinos
};

struct GrafoSt{
  u32 cant_vertices;      //datos del grafo 
  u32 cant_lados;
  u32 cant_colores;
  u32 delta;
  
  struct Vertice* vertices; //array de vertices
};
#endif