#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include <unistd.h>

#include "command.h"
#include "execute.h"
#include "parser.h"
#include "parsing.h"
#include "builtin.h"



static void show_prompt(void) {
    // Obtengo el nombre de usuario y hostname
    char hostname[_SC_HOST_NAME_MAX + 1];
    // char* username = getenv("USER");
    gethostname(hostname, _SC_HOST_NAME_MAX+1);
    // Obtengo el actual directorio de trabajo con el que se inició la shell
    char pwd[256];
    if (getcwd(pwd, sizeof(pwd)) != NULL) {
        printf("\033[0;32mmybash>\033[0;34m%s$\n", pwd); // formato: mybash>pwd
    }

    // printf("%s@%s-mybash>%s\n", username, hostname, pwd); // formato: user@hostname-mybash>pwd
    fflush(stdout);
}

int main(int argc, char *argv[]) {
    pipeline pipe;
    // scommand cmd;
    Parser input;
    bool quit = false;
    show_prompt();
    input = parser_new(stdin);
    while (!quit) {
        show_prompt();
        // cmd = parse_scommand(input);
        
        pipe = parse_pipeline(input);
        printf("%s\n", pipeline_to_string(pipe));
        /* Hay que salir luego de ejecutar? */
        quit = parser_at_eof(input);

        if (pipe != NULL) {
            if (builtin_alone(pipe)/*builtin_is_internal(pipe)*/) {
                scommand cmd1 = pipeline_front(pipe);
                builtin_run(cmd1);
            } else {
                execute_pipeline(pipe);
            }
        }

    }
    parser_destroy(input); input = NULL;
    return EXIT_SUCCESS;
}

