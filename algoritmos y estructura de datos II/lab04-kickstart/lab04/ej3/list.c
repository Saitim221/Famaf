#include <stdbool.h>
#include <stdlib.h>
#include <assert.h>

#include "list.h"

struct _list
{
  list_elem elem;
  list next;
};

list empty(void)
{
  list l = NULL;
  return l;
}

list addl (list l, list_elem e)
{
  list p = malloc(sizeof(struct _list));
  p->elem = e;
  p->next = l;
  l = p;
  return l;
}

bool is_empty(list l)
{
  bool b = (l == NULL);
  return b;
}

list addr(list l, list_elem e)
{
  list p, q;
  q = malloc(sizeof(struct _list));
  q->elem = e;
  q->next = NULL;
  if (!is_empty(l))
  {
    p = l;
    while (p->next != NULL)
    {
      p = p->next;
    
    }
    p->next = q;
  }
  else
  {
    l = q;
  }
  return l;
}
list destroy_list(list l)
{
  list p;
  while (!is_empty(l))
  {
    p = l->next;
    free(l);
    l=p;
  }
  return l;
}

list_elem head(list l)
{
  assert(!is_empty(l));
  list_elem e = l->elem;
  return e;
}

list tail(list l)
{
  assert(!is_empty(l));
  list q;
  q = l;
  l = l->next;
  destroy_list(q);
  return l;
}

list copy_list(list l)
{
list laux ,p;
laux=empty();
if(!is_empty(l)){
p=l;
while(!is_empty(p)){
laux=addr(laux,p->elem);
p=p->next;
}
}return laux;
}


unsigned int length(list l)
{
  unsigned int length = 0;
  list p = l;
  while (!is_empty(p))
  {
    length++;
    p = p->next;
  }
  return length;
}

list concat(list l1, list l2)
{
  list aux = copy_list(l1);
  while (aux->next != NULL)
  {
    aux = tail(aux);
  }
  aux->next = l2;
  l1 = aux;
  destroy_list(aux);
  return l1;
}

list_elem index(list l, unsigned int x)
{
  assert(length(l) > x);
  list l1 = copy_list(l);
  list p = l1;
for(unsigned int i=0;i<x;i++){
 p = p->next;
}
list_elem e = p->elem;
return e; 
}

list take(list l1, unsigned int x)
{
  list aux = empty();
  while ((!is_empty(l1)) && (x > 0))
  {
    addr(aux, head(l1));
    l1 = l1->next;
    x--;
    l1 = aux;
    destroy_list(aux);
  }
  return l1;
}

list drop(list l1, unsigned int x)
{
  while ((!is_empty(l1)) && (x > 0))
  {
    l1 = l1->next;
    x--;
  }
  return l1;
}