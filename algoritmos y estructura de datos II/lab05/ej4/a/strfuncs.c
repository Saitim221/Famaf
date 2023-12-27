#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "strfuncs.h"


size_t string_length(const char *str){
    unsigned int i = 0;
    while(str[i] != '\0' ){
        
        i++;

    }

    return i;
    
}

char *string_filter(const char *str, char c){
    char *new_one = NULL;
    new_one = malloc(sizeof(char) * (string_length(str) + 1));
    unsigned int j= 0;
    for (unsigned int i = 0; i < string_length(str); i++){
        if (str[i] != c ){
            new_one[j] = str[i];
            j++;
        }
       
    }
    new_one[j] = '\0';
    return new_one;
}

