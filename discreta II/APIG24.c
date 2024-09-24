#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>
#include <string.h>
#include <limits.h>
#include "APIG24.h"
#include "EstructuraGrafo24.h"
#include "API2024Parte2.h"

// funcion auxiliar para corroborar que se ingresaron bien los input

struct Par
{
  u32 indice;
  u32 color;
};

struct Par_color
{
  u32 M;
  u32 m;
};



void print_help()
{
  fprintf(stderr, "El grafo esta mal formateado\n"
                  "Este programa solo acepta grafos con formato DIMACS\n");
  exit(1);
}

// TODO ESTOS SON funciones auxiliares para la creacion del grafo y busqueda de datos

void parsear_grafo(FILE *input, u32 *x, u32 *y)
{
  char linea[80]; // asumimos que ninguna linea tendra mas de 80 caracteres (con los ejemplos del profe nos sirvio asi que lo dejamos asi)

  if (fgets(linea, 80, input) == NULL)
  {
    print_help();
  }
  while (linea[0] == 'c')
  {
    if (fgets(linea, 80, input) == NULL)
      print_help();
  }

  if (sscanf(linea, "p edge %u %u", x, y) != 2) // tomamos n y m
    print_help();
}

Grafo crear_grafo(u32 cant_lados, u32 cant_vertices)
{
  Grafo grafo = malloc(sizeof(struct GrafoSt));                                 //! PARTE IMPORTANTE! allocar memoria para nuestro grafo
  struct Vertice *vertices = calloc(4 * cant_vertices, sizeof(struct Vertice)); //! asignamos memoria a todos los vertices de nuestro grafo!

  for (u32 i = 0; i < 4 * cant_vertices; i++)
  {
    vertices[i].empty = true; // avisamos si estan usados o no
  }

  grafo->cant_vertices = grafo->cant_colores = cant_vertices;
  grafo->cant_lados = cant_lados;
  grafo->vertices = vertices; // inicializamos parametros del grafo
  grafo->delta = 0;
  return grafo;
}

void parsear_lado(FILE *input, u32 *x, u32 *y)
{
  char linea[80];
  if (fgets(linea, 80, input) == NULL)
    print_help();

  if (sscanf(linea, "e %u %u", x, y) != 2) // igual que en parsear grafo buscamos los lados de nuestros vertices
    print_help();
}

void agregar_vecino(struct Vertice *v, struct Vertice *n)
{
  /* Si el vertice no tiene ningun vecino, reservamos memoria para guardalos. */
  if (v->vecinos == NULL)
  {
    v->vecinos = malloc(v->total_vecinos * sizeof(struct Vertice *));
  }
  /* Si el vertice  tiene vecinos, reservamos mas memoria en el caso de que supere nuestro "total vecinos". */
  else if (v->total_vecinos <= v->cant_vecinos)
  {
    v->total_vecinos *= 2;
    v->vecinos = realloc(v->vecinos, v->total_vecinos * sizeof(struct Vertice *));
  }

  v->vecinos[v->cant_vecinos] = n; // guardamos en que orden llegan los vecinos

  v->cant_vecinos++; // su "grado"
}

struct Vertice *crear_vertice(Grafo grafo, u32 nombre)
{
  u32 mask = grafo->cant_vertices * 4; // vemos el "largo" de nuestro arreglo
  u32 indice = nombre % mask;          // buscamos la posicion de "nombre" en nuestro arreglo

  struct Vertice *v = grafo->vertices + indice;

  for (;; v = grafo->vertices + indice)
  {
    if (v->empty)
    {
      v->empty = false;
      v->cant_vecinos = 0;
      v->color = 0;
      v->nombre = nombre; // inicializamos nuestro vertice ya que esta asignada la memoria pero no los datos
      v->total_vecinos = 5;
      v->vecinos = NULL;

      return v;
    }
    else if (v->nombre == nombre) // si ya esta creado devolvemos el vertice
    {
      return v;
    }
  }
}

void agregar_lado(Grafo grafo, u32 x, u32 y)
{
  struct Vertice *v = crear_vertice(grafo, x); // se incializa los vertices de cada lado
  struct Vertice *n = crear_vertice(grafo, y);

  agregar_vecino(v, n); // y se agregan los vecinos en ambos sentidos
  agregar_vecino(n, v);

  if (grafo->delta < v->cant_vecinos)
  { // se actualiza delta si alguno de los lados que se ingreso tiene mas vecinos que el delta anterior
    grafo->delta = v->cant_vecinos;
  }

  if (grafo->delta < n->cant_vecinos)
  {
    grafo->delta = n->cant_vecinos;
  }
}

// TODOS ESTOS SON Funciones De Construcción/Destrucción del grafo//

Grafo ConstruirGrafo()
{

  u32 cant_vertices, cant_lados, x, y;
  Grafo grafo;

  parsear_grafo(stdin, &cant_vertices, &cant_lados);
  grafo = crear_grafo(cant_lados, cant_vertices);

  for (u32 i = 0; i < cant_lados; i++)
  {
    parsear_lado(stdin, &x, &y);
    agregar_lado(grafo, x, y);
  }
  return grafo;
}
/*util para DestruirGrafo*/
u32 NumeroDeVertices(Grafo g)
{
  return g->cant_vertices;
}

void DestruirGrafo(Grafo G)
{
  struct Vertice *v;

  for (u32 i = 0; i < NumeroDeVertices(G); i++)
  {
    v = G->vertices + i;
    if (!v->empty)
    {
      free(v->vecinos);
    }
  }

  free(G->vertices);
  free(G);
}

// TODOS ESTOS SON Funciones para extraer informaci ́on de datos del grafo Y Funciones para extraer informaci ́on de los vertices//

u32 NumeroDeLados(Grafo G)
{

  return G->cant_lados;
}

u32 Delta(Grafo G)
{
  return G->delta;
}

u32 Grado(u32 i, Grafo G)
{

  return G->vertices[i].cant_vecinos;
}

color Color(u32 i, Grafo G)
{
  if (i < G->cant_vertices)
  {
    return G->vertices[i].color;
  }

  else
  {
    return 4294967295;
  }
}

u32 Vecino(u32 j, u32 i, Grafo G)
{

  if (i >= G->cant_vertices || ((i < G->cant_vertices) && j >= G->vertices[i].cant_vecinos))
  {
    return 4294967295;
  }

  else
  {

    return G->vertices[i].vecinos[j]->nombre;
  }
}

void AsignarColor(color x, u32 i, Grafo G)
{

  if (i <= G->cant_vertices)
  {
    G->vertices[i].color = x;
  }
}

void ExtraerColores(Grafo G, color *Color)
{
  for (u32 i = 0; i < G->cant_vertices; i++)
  {
    Color[i] = G->vertices[i].color;
  }
}

void ImportarColores(color *Color, Grafo G)
{
  for (u32 i = 0; i < G->cant_vertices; i++)
  {
    G->vertices[i].color = Color[i];
  }
}

u32 Greedy(Grafo G, u32 *Orden)
{

  u32 color_actual, grado, max_color = 0; // itera lo vertices

  u32 *aux = calloc(NumeroDeVertices(G), sizeof(u32));

  u32 controlador = 1;

  for (int i = 0; i < NumeroDeVertices(G); i++)
  {
    AsignarColor(0, Orden[i], G);
  }

  /*guardamos en el arreglo auxiliar, el vertice i en la posicion i del arreglo como un +1
  y controlamos que los vertices no sean mayor igual a n*/

  for (int i = 0; i < NumeroDeVertices(G); i++)
  {

    aux[Orden[i]]++;
    if (Orden[i] >= NumeroDeVertices(G))
    {
      controlador = controlador * 0;
    }
  }

  /*despues de rellenar nuestro arreglo auxiliar el cual tarda O(n), veremos devuelta el arreglo auxiliar pero esta ves
  viendo si hay algun vertice que se haya repetido esto solo se controla si orden no nos da vertices mayores a n*/
  if (controlador != 0)
  {

    for (int i = 0; i < NumeroDeVertices(G); i++)
    {
      if (aux[i] !=1 )
      {
        controlador = controlador * 0;
      }
    }
    free(aux);
  }

  /*ahora implementaremos la funcion de greedy propiamente dicha, hata ahora utilizamos 2 for que recorren Orden, que si todo
  esta bien tiene orden O(n) por ende hasta aqui el orden de greedy es de O(2n)  */
  if (controlador == 0)
  {
    u32 a=4294967295;
    printf("%u",a);
  }
  else
  {
    AsignarColor(1, Orden[0], G);

    for (int i = 1; i < NumeroDeVertices(G); i++)
    { 
      grado = Grado(Orden[i], G);
      color *c = calloc(Delta(G)+2,sizeof(color));
      //creamos arreglo c para ver el primer color disponible 
      for (u32 j = 0; j <grado; j++)
      {
        if(Color(Vecino(j,Orden[i],G),G)!=0){
          c[Color(Vecino(j,Orden[i],G),G)]++;
        }
      }
      
      for (u32 j = 1; j < grado+2; j++)
      {
        if(c[j]==0){
          color_actual=j;
          break;
        }
      }
   
      AsignarColor(color_actual, Orden[i], G);

      if (max_color < color_actual)
      {
        max_color = color_actual;
      }
      free(c);
    }
    return max_color;
    free(aux);
  }
}

//merge utilizado en gulducat para comparar grados de colores YA SE QUE SE PUDO HABER HECHO 1 MERGE GENERAL Y LUEGO
//MODIFICARLO PARA ADAPTARLO CON CONDICIONES ASI NO HACIA 3 MERGE PERO BUENO FUNCIONA!
void merge(struct Par_color *par_color, struct Par *par, u32 l, u32 m, u32 r)
{

  u32 n1 = m - l + 1;
  u32 n2 = r - m;

  struct Par *L = calloc(n1, sizeof(struct Par));
  struct Par *R = calloc(n2, sizeof(struct Par));

  for (int i = 0; i < n1; i++)
  {
    L[i].color = par[l + i].color;
    L[i].indice = par[l + i].indice;
  }

  for (int i = 0; i < n2; i++)
  {
    R[i].color = par[m + i + 1].color;
    R[i].indice = par[m + i + 1].indice;
  }
  u32 k = l, i = 0, j = 0;

  while (i < n1 && j < n2)
  {

    // caso en el que los dos sean multiplos de 4
    if (L[i].color % 4 == 0 && R[j].color % 4 == 0)
    { //vemos cual tiene mayor M
      if (par_color[L[i].color].M > par_color[R[j].color].M)
      {
        par[k] = L[i];
        i++;
      }
      
      //si son iguales vemos quien tiene menor color
      else if(par_color[L[i].color].M == par_color[R[j].color].M){
        if(L[i].color<R[j].color){
          par[k] = L[i];
          i++;
        }
      
      
        else{
          par[k]=R[j];
          j++;
       }
    }
    else{
      par[k] = R[j];
      j++;
      }
      
    }

    // el caso en que uno sea multiplo de 4 y el otro no
    else if (L[i].color % 4 == 0 && R[j].color % 4 != 0)
    {

      par[k] = L[i];
      i++;
    }

    else if (L[i].color % 4 != 0 && R[j].color % 4 == 0)
    {
      par[k] = R[j];
      j++;
    }

    // el caso que los dos sean multiplo de 2
    else if (L[i].color % 2 == 0 && R[j].color % 2 == 0)
    {
      if ((par_color[L[i].color].M + par_color[L[i].color].m) > (par_color[R[j].color].M + par_color[R[j].color].m))
      {
        par[k] = L[i];
        i++;
      }

      else if((par_color[L[i].color].M + par_color[L[i].color].m) == (par_color[R[j].color].M + par_color[R[j].color].m)){
        if(L[i].color<R[j].color){
          par[k] = L[i];
          i++;
        }
      
      
        else{
          par[k]=R[j];
          j++;
        }
      }

      else
      {
        par[k] = R[j];
        j++;
      }
    }
    // el caso que uno sea multiplo de 2 y el otro no (si el otro es multiplo de 4 hubiese entrado antes)
    else if (L[i].color % 2 == 0 && R[j].color % 2 != 0)
    {
      par[k] = L[i];
      i++;
    }
    else if (L[i].color % 2 != 0 && R[j].color % 2 == 0)
    {
      par[k] = R[j];
      j++;
    }

    else if (L[i].color % 2 == 1 && R[j].color % 2 == 1)
    {
      if (par_color[L[i].color].m > par_color[R[j].color].m)
      {
        par[k] = L[i];
        i++;
      }

      else if(par_color[L[i].color].m == par_color[R[j].color].m){
        if(L[i].color<R[j].color){
          par[k] = L[i];
          i++;
        }
      
      
        else{
          par[k]=R[j];
          j++;
        }

      
      }
      else{
        par[k]=R[j];
        j++;
      }
      }
    else{
      printf("Aaaa\n");
    }
  
    k++;
  }

  // Copy remaining elements
  // of L[] if any
  while (i < n1)
  {
    par[k] = L[i];
    i++;
    k++;
  }
  // Copy remaining elements
  // of R[] if any
  while (j < n2)
  {
    par[k] = R[j];
    j++;
    k++;
  }

  free(L);
  free(R);
}

void sort(struct Par_color *par_color, struct Par *par, u32 l, u32 r)
{

  if (l < r)
  {
    u32 m = l + (r - l) / 2;

    sort(par_color, par, l, m);
    sort(par_color, par, m + 1, r);
    merge(par_color, par, l, m, r);
  }
}
//funciones max y min
u32 min(u32 x, u32 y)
{
  if (x < y)
  {
    return x;
  }
  else
  {
    return y;
  }
}

u32 max(u32 x, u32 y)
{
  if (x > y)
  {
    return x;
  }
  else
  {
    return y;
  }
}

char GulDukat(Grafo G, u32 *Orden)
{

  // 0 si esta todo bien, 1 sino
  char res = 0;

  // arreglo que contiene los colores de c/vertice
  u32 *aux = calloc(NumeroDeVertices(G), sizeof(u32));

  // arreglo que tiene el color de cada vertice
  struct Par *par = calloc(NumeroDeVertices(G), sizeof(struct Par));

  // el color mas grande
  u32 max_color = 0;

  ExtraerColores(G, aux);

  // busco el color mas grande
  for (int i = 0; i < NumeroDeVertices(G); i++)
  {
    max_color = max(max_color, aux[i]);
  }

  // el grado mas grande y chico de cada color
  struct Par_color *aux1 = calloc(max_color+1, sizeof(struct Par_color));

  // guardamos todos los vectores con su respectivo indice
  for (int i = 0; i < NumeroDeVertices(G); i++)
  {
    par[i].color = aux[i];
    par[i].indice = i;
  }
  //arreglo de grados M y m para cada color 
  for (int i = 0; i < max_color+1; i++)
  {

    aux1[i].M = 0;
    aux1[i].m = 4294967294;
  }

  for (int i = 0; i < NumeroDeVertices(G); i++)
  { // aqui veo si el color de los vertices cual tiene el grado mas grande
    aux1[aux[i]].M = max(aux1[aux[i]].M, Grado(i, G));
    aux1[aux[i]].m = min(aux1[aux[i]].m, Grado(i, G));
    // printf("%u,%u\n",par[i].indice,par[i].color);
  }

  // printf("%u",par[0].color);
  sort(aux1, par, 0, NumeroDeVertices(G) - 1);
  // printf("%u,%u\n",par[1].indice,par[1].color);
  for (int i = 0; i < NumeroDeVertices(G); i++)
  {
    Orden[i] = par[i].indice;
  }
  free(aux);
  free(par);
  free(aux1);

  return res;
}
//////////////////////////////////////////////////////////////////////




//merge para el Elimgarak
void merge2(u32 *vertice_color, struct Par *par, u32 l, u32 m, u32 r)
{

  u32 n1 = m - l + 1;
  u32 n2 = r - m;

  struct Par *L = calloc(n1, sizeof(struct Par));
  struct Par *R = calloc(n2, sizeof(struct Par));

  for (int i = 0; i < n1; i++)
  {
    L[i].color = par[l + i].color;
    L[i].indice = par[l + i].indice;
  }

  for (int i = 0; i < n2; i++)
  {
    R[i].color = par[m + i + 1].color;
    R[i].indice = par[m + i + 1].indice;
  }
  u32 k = l, i = 0, j = 0;

  while (i < n1 && j < n2)
  {
    if(L[i].color==1 && R[j].color!=1){
      par[k]=R[j];
      j++;
    }

    else if(L[i].color!=1 && R[j].color==1){
    par[k]=L[i];
    i++;
    }

    else if(L[i].color==1 && R[j].color==1){
    par[k]=L[i];
    i++;
    }

    else if(L[i].color==1 && R[j].color==2){
    par[k]=R[j];
    j++;
    }

    else if(L[i].color==2 && R[j].color==1){
    par[k]=L[i];
    i++;
    }

    else if(L[i].color==2 && R[j].color==2){
    par[k]=L[i];
    i++;
    }

    else if(L[i].color==2 && R[j].color!=2){
    par[k]=R[j];
    j++;
    }
    
    else if(L[i].color!=2 && R[j].color==2){
    par[k]=L[i];
    i++;
    }

    else if(vertice_color[L[i].color] > vertice_color[R[j].color])
    {
      par[k]=R[j];
      j++;
    }

    else if(vertice_color[L[i].color] < vertice_color[R[j].color])
    {
      par[k]=L[i];
      i++;
    }
    else if(vertice_color[L[i].color] == vertice_color[R[j].color])
    {
      if(L[i].color<R[j].color){
        par[k]=L[i];
        i++;
      }
      else{
        par[k]=R[j];
        j++;
      }
    }
    else{printf("aaaa");}
    k++;

  }

  // Copy remaining elements
  // of L[] if any
  while (i < n1)
  {
    par[k] = L[i];
    i++;
    k++;
  }
  // Copy remaining elements
  // of R[] if any
  while (j < n2)
  {
    par[k] = R[j];
    j++;
    k++;
  }

  free(L);
  free(R);
}

void sort2(u32 *par_color, struct Par *par, u32 l, u32 r)
{

  if (l < r)
  {
    u32 m = l + (r - l) / 2;

    sort2(par_color, par, l, m);
    sort2(par_color, par, m + 1, r);
    merge2(par_color, par, l, m, r);
  }
}


char ElimGarak(Grafo G, u32 *Orden)
{

  // 0 si esta todo bien, 1 sino
  char res = 0;

  // arreglo que contiene los colores de c/vertice
  u32 *aux = calloc(NumeroDeVertices(G), sizeof(u32));

  // arreglo que tiene el color de cada vertice
  struct Par *par = calloc(NumeroDeVertices(G), sizeof(struct Par));

  // el color mas grande
  u32 max_color = 0;

  ExtraerColores(G, aux);

  // busco el color mas grande
  for (int i = 0; i < NumeroDeVertices(G); i++)
  {
    max_color = max(max_color, aux[i]);
  }

  // cantidad de vertices de cada color
  u32 *aux1 = calloc(max_color+1, sizeof(u32));

  // guardamos todos los vectores con su respectivo indice
  for (int i = 0; i < NumeroDeVertices(G); i++)
  {
    par[i].color = aux[i];
    par[i].indice = i;
  }

  //asigno 0 a todos los colores
  for (int i = 0; i < max_color+1; i++)
  {
    aux1[i]=0;
  }
 
  for (int i = 0; i < NumeroDeVertices(G); i++)
  { //veo cuantos vertices tiene ese color

    aux1[par[i].color]++;
   
  }

  // printf("%u",par[0].color);
  sort2(aux1, par, 0, NumeroDeVertices(G) - 1);

  // printf("%u,%u\n",par[1].indice,par[1].color);
  for (int i = 0; i < NumeroDeVertices(G); i++)
  {
    Orden[i] = par[i].indice;
  } 
  free(aux);
  free(par); 
  free(aux1);

  return res;
}
