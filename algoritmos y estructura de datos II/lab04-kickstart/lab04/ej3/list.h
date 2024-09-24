#ifndef _LIST_H
#define _LIST_H

#include <stdbool.h>

typedef int list_elem;
typedef struct _list *list;


/*Constructors*/
list empty(void);
/*create an empty list*/

list addl( list l, list_elem e);
/*add a new element at the beginning of the list*/



/*Destroy*/
list destroy(list l);
/*Free memory if it is necessary*/



/*Operations*/
bool is_empty(list l);
/* Return true if the list is empty*/

list_elem head(list l);
/*Return the first element of the list*/
/*PRE: !is_empty(l) */

list tail(list l);
/* erase the first element of the list 
PRE: !is_empty(l) */

list addr (list l, list_elem e);
/* add the element at the end of the list */

unsigned int length(list l);
/*Return the length of the list */

list concat(list l, list l0);
/* add the elements of a list at the end of another list in the same order*/

list_elem index(list l, unsigned int n );
/* Return the n-element of the list
PRE: length(l) > n */

list take(list  l ,unsigned int n);
/* let in l only the first n-elements */

list drop(list l , unsigned int n );
/*Erase the first n-elements of the list l*/

list copy_list(list l1 );
/*Copy the list l1*/

#endif