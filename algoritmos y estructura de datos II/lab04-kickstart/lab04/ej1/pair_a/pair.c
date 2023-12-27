#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#include "pair.h"

pair_t pair_new(int x, int y){
    pair_t p;
    p.fst = x;
    p.snd = y;
    return p;
}

int pair_first(pair_t p){
    int res = p.fst;
    return res;
}

int pair_second(pair_t p){
    int res = p.snd;
    return res;
}

pair_t pair_swapped(pair_t p){
    pair_t n = pair_new(pair_second(p), pair_first(p));
    
    p = n;
    return p;
}

pair_t pair_destroy(pair_t p){
    return p;
}