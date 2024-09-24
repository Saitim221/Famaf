#include <stdio.h>
#include <stdlib.h>
#include "APIG24.h"
#include "EstructuraGrafo24.h"
#include "API2024Parte2.h"

//estructura para ordenar los vectores con respecto al grado
struct Par
{
  u32 indice;
  u32 grado;
};

u32 min1(u32 x, u32 y)
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

////////////////////////////////////////
//merge utilizado para el ordenamiento 4
void merge3(struct Par *arr, u32 l, u32 m, u32 r)
{

    u32 n1 = m - l + 1;
    u32 n2 = r - m;

    // Create temp arrays
    
    struct Par *L = calloc(n1, sizeof(struct Par));
    struct Par *R = calloc(n2, sizeof(struct Par));;

    // Copy data to temp arrays L[] and R[]
    for (u32 i = 0; i < n1; i++){
        L[i].grado = arr[l + i].grado;
        L[i].indice = arr[l + i].indice;
    }
    for (u32 j = 0; j < n2; j++){
    R[j].grado = arr[m + j + 1].grado;
    R[j].indice = arr[m + j + 1].indice;
    }

    
    u32 i, j, k;
    // Merge the temp arrays back into arr[l..r
    i = 0;
    j = 0;
    k = l;
    while (i < n1 && j < n2) {
        if (L[i].grado > R[j].grado) {
            arr[k] = L[i];
            i++;
        }
        else {
            arr[k] = R[j];
            j++;
        }
        k++;
    }

    // Copy the remaining elements of L[],
    // if there are any
    while (i < n1) {
        arr[k] = L[i];
        i++;
        k++;
    }

    // Copy the remaining elements of R[],
    // if there are any
    while (j < n2) {
        arr[k] = R[j];
        j++;
        k++;
    }
    free(L);
    free(R);    
}

// l is for left index and r is right index of the
// sub-array of arr to be sorted
void mergeSort(struct Par* arr, int l, int r)
{
    if (l < r) {
        int m = l + (r - l) / 2;

        // Sort first and second halves
        mergeSort(arr, l, m);
        mergeSort(arr, m + 1, r);

        merge3(arr, l, m, r);
    }
}



//MAIN
int main(){
    Grafo g = ConstruirGrafo();
    u32 *aux=calloc(NumeroDeVertices(g),sizeof(u32));

//////////////////////////////////////////////
    //Orden 1
    //ordenamos de 0 a n-1
    for (int i = 0; i < NumeroDeVertices(g); i++)
    {
        aux[i]=i;
    }

    //corremos greedy
    u32 res;
    res=Greedy(g,aux);
    printf("color con 1er greedy=%u\n",res);

    for (int i = 0; i < 50; i++)
    {   
        GulDukat(g,aux);        
        res=Greedy(g,aux);
        ElimGarak(g,aux);
        res=Greedy(g,aux);
        //printf("%u\n",res);
    }
    u32 res1=res;
    u32 *res1c=calloc(NumeroDeVertices(g),sizeof(u32));
    ExtraerColores(g,res1c);
    printf("color 1er greedy despues de las iteraciones es=%u\n",res);
//////////////////////////////////////////////
    //Orden 2
    //ordenamos de n-1 a 0
    for (int i =0; i < NumeroDeVertices(g); i++)
    {
        aux[i]=NumeroDeVertices(g)-i-1;
    
    }
    //corremos greedy
    res=Greedy(g,aux);
    printf("color con 2do greedy=%u\n",res);
    //vemos el color mas grande del greedy
    
    for (int i = 0; i < 50; i++)
    {   //printf("%i\n",i);
        ElimGarak(g,aux);
        res=Greedy(g,aux);
        GulDukat(g,aux);
        res=Greedy(g,aux);
        
    }
    u32 res2=res;
    u32 *res2c=calloc(NumeroDeVertices(g),sizeof(u32));
    ExtraerColores(g,res2c);
    printf("color 2do greedy despues de las iteraciones es=%u\n",res);

//////////////////////////////////////////////
    //Orden 3
    //Ordenamos pares de mayor a menor primero y luego los impares de menor a mayor despues
    u32 a=0;
    for (int i =NumeroDeVertices(g)-1; i>=0; i--)
    {
        if(i%2==0){
        aux[a]=i;
        a++;
        }
        
        
    }
    for (int i =0; i<NumeroDeVertices(g); i++)
    {
        if(i%2==1){
        aux[a]=i;
        a++;
        }
    }

    res=Greedy(g,aux);
    printf("color con 3er greedy=%u\n",res);

    for (int i = 0; i < 50; i++)
    {   //printf("%i\n",i);
        ElimGarak(g,aux);
        res=Greedy(g,aux);
        GulDukat(g,aux);
        res=Greedy(g,aux);
        
    }
    u32 res3=res;
    u32 *res3c=calloc(NumeroDeVertices(g),sizeof(u32));
    ExtraerColores(g,res3c);
    printf("color 3er greedy despues de las iteraciones es=%u\n",res);

//////////////////////////////////////////////
    //ORDEN 4
struct Par* grado_vertice =calloc(NumeroDeVertices(g),sizeof(struct Par));

for (u32 i = 0; i < NumeroDeVertices(g); i++)
{
    grado_vertice[i].grado=Grado(i,g);
    grado_vertice[i].indice=i;
}

//ordenamos respecto al Grado
mergeSort(grado_vertice,0,NumeroDeVertices(g)-1);

    for (u32 i = 0; i < NumeroDeVertices(g); i++)
    {
        aux[i]=grado_vertice[i].indice;
    }
    

    res=Greedy(g,aux);
    printf("color con 4to greedy=%u\n",res);

    for (int i = 0; i < 50; i++)
    {   //printf("%i\n",i);
        ElimGarak(g,aux);
        res=Greedy(g,aux);
        GulDukat(g,aux);
        res=Greedy(g,aux);
        
    }
    u32 res4=res;
    u32 *res4c=calloc(NumeroDeVertices(g),sizeof(u32));
    ExtraerColores(g,res4c);
    printf("color 4to greedy despues de las iteraciones es=%u\n",res);


free(grado_vertice);

//////////////////////////////////////////////
    //Orden 5
    a=0;
    for (int i =0; i<NumeroDeVertices(g); i++)
    { 
        if(i%2==0){
        aux[a]=i;
        a++;
        }
        
    }
    for (int i =0; i<NumeroDeVertices(g); i++)
    {
        if(i%2==1){
        aux[a]=i;
        a++;
        }
    }
    res=Greedy(g,aux);
    printf("color con 5to greedy=%u\n",res);

    for (int i = 0; i < 50; i++)
    {   //printf("%i\n",i);
        ElimGarak(g,aux);
        res=Greedy(g,aux);
        GulDukat(g,aux);
        res=Greedy(g,aux);
        
    }
    u32 res5=res;
    u32 *res5c=calloc(NumeroDeVertices(g),sizeof(u32));
    ExtraerColores(g,res5c);
    printf("color 5to greedy despues de las iteraciones es=%u\n",res);

    //la respuesta mas chica de los 5 ordenes
    u32 resfinal=min1(min1(min1(min1(res1,res2),res3),res4),res5);
    
    if(res1==resfinal){
        ImportarColores(res1c,g);
    }
    else if(res2==resfinal){
        ImportarColores(res2c,g);
    }
    else if(res3==resfinal){
        ImportarColores(res3c,g);
    }
    else if(res4==resfinal){
        ImportarColores(res4c,g);
    }
    else if(res5==resfinal){
        ImportarColores(res5c,g);
    }

    printf("color antes del 50/50=%u\n",resfinal);

    u32 numero;
    for (u32 i = 0; i < 500; i++)
    {
        numero= rand()%2;

        if(numero==1){
            GulDukat(g,aux);
            res=Greedy(g,aux);
        }
        else{
            ElimGarak(g,aux);
            res=Greedy(g,aux);
            }
    }
    printf("color despues de las 500=%u\n",res);
    free(res1c);
    free(res2c);
    free(res3c);
    free(res4c);
    free(res5c);
    free(aux);
    DestruirGrafo(g);
  
}

