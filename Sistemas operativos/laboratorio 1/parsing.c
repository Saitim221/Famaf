#include <stdlib.h>
#include <stdbool.h>

#include "parsing.h"
#include "parser.h"
#include "command.h"

static scommand parse_scommand(Parser p) {
    scommand cmd = scommand_new();
    char *arg;
    arg_kind_t type;
    while(!parser_at_eof(p)){
        arg = parser_next_argument(p, &type);
        if(arg == NULL){ // Es un fin de linea o llega a un pipe
            return cmd;
        }

        if (type == ARG_NORMAL ){//|| type == ARG_OUTPUT || type == ARG_INPUT) {
            scommand_push_back(cmd, arg);
        }else if(type == ARG_INPUT){// <
                scommand_set_redir_in(cmd, arg);
            /*    char* input_filename = parser_next_argument(p, &type);
                if (input_filename != NULL) {
                    scommand_set_redir_in(cmd, input_filename);
                } else {
                    fprintf(stderr, "Error: Failed to open input file.\n");
                    // exit(EXIT_FAILURE);
                    return NULL;
                }*/
        }else if(type == ARG_OUTPUT){// >
            scommand_set_redir_out(cmd, arg);
            /*char* output_filename = parser_next_argument(p, &type);
            if (output_filename != NULL) {
                    scommand_set_redir_out(cmd, output_filename);
            } else {
                    fprintf(stderr, "Error: Failed to open input file.\n");
                    // exit(EXIT_FAILURE);
                    return NULL;
            }*/
        }else{
            printf("No existe ningun comando de ese tipo\n");
            scommand_destroy(cmd);
            free(arg);
            return NULL;
        }
    }
 
    if (scommand_is_empty(cmd)) {
        // El comando simple está vacío, lo consideramos un error.
        printf("Error: Comando simple vacío\n");
        scommand_destroy(cmd);
        return NULL;
    }
    return cmd;
}

pipeline parse_pipeline(Parser p) {
    pipeline result = pipeline_new();
    scommand cmd = NULL;
    bool error = false, another_pipe=true;
    while (another_pipe && !error){     
        cmd = parse_scommand(p);
        if (cmd == NULL) {
            error = true;
            break;
        }
        pipeline_push_back(result, cmd);
        parser_op_pipe(p, &another_pipe);
        bool is_background = false;
        parser_op_background(p, &is_background);
        pipeline_set_wait(result, !is_background);
    }
    /* Tolerancia a espacios posteriores */
    parser_skip_blanks(p);
    /* Consumir todo lo que hay inclusive el \n */
    bool garbage;
    parser_garbage(p, &garbage);
    /* Si hubo error, hacemos cleanup */
    if (error) {
        pipeline_destroy(result);
        return NULL;
    }
    return result;
}
