#ifndef __STRFUNCS_H__
#define __STRFUNCS_H__

#include <stdbool.h>


/**
* @brief Devuelve el tamano del caracter
*/
size_t string_length(const char *str);

/**
* @brief Devuelve el caracter en memoria dinamica
*/
char *string_filter(const char *str, char c);


#endif


