/*
  @file sort.c
  @brief sort functions implementation
*/

#include <assert.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include "helpers.h"
#include "sort.h"
#include "player.h"

bool goes_before(player_t x, player_t y){
    bool res;
    if(x.rank <= y.rank){
        res = true;
    }else{
        res = false;
    }
    return res;
}

void swap(player_t atp[], unsigned int i, unsigned int j){
    player_t aux = atp[i];
    atp[i] = atp[j];
    atp[j] = aux;
}

bool array_is_sorted(player_t atp[], unsigned int length) {
    unsigned int i = 1u;
    while (i < length && goes_before(atp[i - 1u], atp[i])) {
        i++;
    }
    return (i == length);
}



static unsigned int partition(player_t atp[], unsigned int izq, unsigned int der) {
       unsigned int i, j, piv;
    piv = izq;
    i = izq + 1u;
    j = der;
    while (i <= j){
        if (goes_before(atp[i], atp[piv])){
            i ++;
        }
        else if (goes_before(atp[piv], atp[j])){
            j--;
        }
        else if(goes_before(atp[piv], atp[i]) && goes_before(atp[j], atp[piv])){
            swap(atp, i, j);
        }
        
    }
    swap(atp, piv, j);
    piv = j;
    return piv;
}

static void quick_sort_rec(player_t atp[], unsigned int izq, unsigned int der) {
    unsigned int piv = izq;
    if (der > izq){ 
                piv = partition(atp,izq,der);
                quick_sort_rec( atp,izq,(piv==0u) ? 0u : piv - 1u);
                quick_sort_rec( atp,piv+1,der); 
}
}

void sort(player_t atp[], unsigned int length) {
    quick_sort_rec(atp, 0, (length == 0) ? 0 : length - 1);
}

