#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

#define MAX_SIZE 1000

unsigned int data_from_file(const char *path, unsigned int indexes[], char letters[], unsigned int max_size){
    FILE *file = fopen(path, "r");
    if(file == NULL){
        printf("Error \n");
        EXIT_FAILURE;
    }
    unsigned int i = 0;
    while(!feof(file) && i <= max_size){
        //feof devuelve 1 si se encuentra en el final del archivo
    fscanf(file, "%u -> *%c*\n", &indexes[i], &letters[i]);
    i++;
    }
    fclose(file);

    return i;
}
char *parse_filepath(int argc, char *argv[]){
    char *result = NULL;
    bool valid_arg_count = (argc == 2);

    //Si se proporciona un solo argumento, que es la ubicación del archivo, entonces argc tendrá un valor de 2: 
    //el primer argumento es el nombre del programa, y el segundo argumento es la ubicación del archivo. 
    //Si se proporcionan más argumentos, argc será mayor que 2, y si se proporciona menos argumentos, argc será menor que 2.

    if(!valid_arg_count){
        EXIT_FAILURE;
    }

    result = argv[1];
    return result;



}

void letters_are_sorted(unsigned int lenght, unsigned int indexes[], char sorted[], char letters[]){
    for(unsigned int i=0; i < lenght; i++){
        int j = 0;
        while(indexes[j] != i){
            j++;
        }
        sorted[i] = letters[j];
    }
}

static void dump(char a[], unsigned int length) {
    printf("\"");
    for (unsigned int j=0u; j < length; j++) {
        printf("%c", a[j]);
    }
    printf("\"");
    printf("\n\n");
}

int main(int argc, char *argv[]) {
    
    unsigned int indexes[MAX_SIZE];
    char letters[MAX_SIZE];
    char sorted[MAX_SIZE];
   
    char *path = NULL;  
    path = parse_filepath(argc, argv);
    unsigned int length = data_from_file(path, indexes, letters, MAX_SIZE); 
    letters_are_sorted(length, indexes, sorted, letters);

    
    dump(sorted, length);

    return EXIT_SUCCESS;
}

