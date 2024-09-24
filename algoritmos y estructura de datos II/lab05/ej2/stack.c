#include <stdlib.h>
#include <assert.h>
#include "stack.h"

struct _s_stack {
    stack_elem *elems;      // Arreglo de elementos
    unsigned int size;      // Cantidad de elementos en la pila
    unsigned int capacity;  // Capacidad actual del arreglo elems
};

static bool inv_repre(stack s){
  return (s!=NULL ? ((s->size <= s->capacity) && (s->elems != NULL) && (s->capacity > 0)) : true);
}

stack stack_empty(){
    
  stack s = malloc(sizeof(struct _s_stack));
  
  s->elems = malloc(sizeof(stack_elem));
  s->size = 0u;
  s->capacity = 1u;
  return s;
}


stack stack_push(stack s, stack_elem e){
    assert(inv_repre(s));
s->size++;
    if (s->size > s->capacity) {
        s->capacity *= 2;
        s->elems = realloc(s->elems, sizeof(stack_elem) * s->capacity);
    }
    s->elems[s->size-1] = e;
    assert(inv_repre(s));
return s;
}


bool stack_is_empty(stack s){
    bool b = (s->size == 0u);
    return b;
}

stack_elem stack_top(stack s){
    assert(inv_repre(s));
    assert(!stack_is_empty(s));
    stack_elem e = s->elems[s->size - 1];
    assert(inv_repre(s));
    return e;
}


stack stack_pop(stack s){
    assert(inv_repre(s));
assert(!stack_is_empty(s));
s->size --;
assert(inv_repre(s));
return s;
}


unsigned int stack_size(stack s){
return (s == NULL ? 0u : s->size);
}

stack_elem *stack_to_array(stack s){
    assert(inv_repre(s));
  stack_elem *a = calloc(stack_size(s), sizeof(stack_elem));
  stack p = s;
  if(!stack_is_empty(p)){
    for (size_t i = stack_size(p); i >0; i--)
        {
        a[i-1] = stack_top(p);
        stack_pop(p);
        }
    }else{
        a = NULL;
    }
    assert(inv_repre(s));
    return a;
}

stack stack_destroy(stack s){
    assert(inv_repre(s));
  free(s->elems);
  s->elems = NULL;
  free(s);
  s = NULL;
  assert(inv_repre(s));
  return s;
}

