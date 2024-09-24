#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LENGTH 20

int main(void) {
    char user_input[MAX_LENGTH];

    printf("Ingrese su nombre y apellido: ");
    fgets(user_input, sizeof(user_input), stdin);
    user_input[strcspn(user_input, "\n")] = '\0';
    //Busca el caracter seleccionado y lo cambia por otro

    printf("Te damos la bienvenida %s a este maravilloso programa!\n", user_input);

    return EXIT_SUCCESS;
}

