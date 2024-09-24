#include <stdlib.h>
#include <stdio.h>

void absolute(int x, int y) {
    if ( x >= 0){
        y = x;
    } else{
        y = -x;
    }
}

int main(void) {
    int a=0, res=0;
    a = -10;
    absolute(a, res);
    printf("%d \n", res );

    return EXIT_SUCCESS;
}

//El valor de res es 0, no coincide con lo que deberia, deberia dar 10
