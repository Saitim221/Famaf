#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "stack.h"
#define MAX_SIZE 1000000

struct _s_stack {
stack_elem elem;
stack next;
};

stack stack_empty(){
  stack s = NULL;
  return s;
}

stack stack_push(stack s, stack_elem e){
stack p = malloc(sizeof(struct _s_stack));
p-> elem = e;
p->next = s;
s=p;
return p;
}

bool stack_is_empty(stack s){

bool res = (s==NULL);
return res;
}

stack_elem stack_top(stack s){
    if(stack_is_empty(s)){
    printf("La pila es vacia\n");
    return 0;
}
return s->elem;
}

stack stack_pop(stack s){
assert(!stack_is_empty(s));
stack top = s;
s = s->next;
free(top);
return(s);
}


unsigned int stack_size(stack s){
unsigned int size=0;
stack p = s;
while(!stack_is_empty(p)){
  size++;
  p = p->next;
}
stack_destroy(p);
return size;
}

stack_elem *stack_to_array(stack s){
  stack_elem *a = calloc(stack_size(s), sizeof(stack_elem));
  stack p = s;
  if(!stack_is_empty(s)){
    for (size_t i = stack_size(s); i > 0; i--)
    {
      a[i-1] = stack_top(p);
      p = p->next;
    }
    
  } else{
    a = NULL;
  }
  return a;
}

stack stack_destroy(stack s){
  stack p;
  while (!stack_is_empty(s))
  {
    p = s->next;
    free(s);
    s=p;
  }
  return s;
}


