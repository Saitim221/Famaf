#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <assert.h>
#include <string.h>
#include <fcntl.h>

#include "execute.h"
#include "command.h"
#include "builtin.h"

#include "tests/syscall_mock.h"

static void execute_scommand(scommand scmd) {
    assert(scmd != NULL);

    char *output_file = scommand_get_redir_out(scmd); // verifico si hay output redirection
    if (output_file != NULL) {
        int output_file_fd = open(output_file, O_CREAT|O_WRONLY|O_TRUNC, S_IRWXU);
        if (output_file_fd < 0) {
            printf("Error abriendo el output file");
            exit(EXIT_FAILURE);
        }
        dup2(output_file_fd, STDOUT_FILENO);
        if (close(output_file_fd) < 0) {
            printf("Error cerrando el file descriptor del input file");
            exit(EXIT_FAILURE);
        }
    }
    char *input_file = scommand_get_redir_in(scmd);
    if (input_file != NULL) {
        int input_file_fd = open(input_file, O_RDONLY, S_IRUSR);
        if (input_file_fd < 0) {
            printf("Error abriendo el input file");
            exit(EXIT_FAILURE);
        }
        dup2(input_file_fd, STDIN_FILENO);
        if (close(input_file_fd) < 0) {
            printf("Error cerrando el file descriptor del input file");
            exit(EXIT_FAILURE);
        }
    }
    char **args = malloc((scommand_length(scmd) + 1) * sizeof(char *));
    char *arg = NULL;
    unsigned int i = 0;
    while (!scommand_is_empty(scmd))
    {   
        arg = scommand_front(scmd);
        args[i] = arg;
        scommand_pop_front(scmd);
        i++;
    }
    args[i] = NULL; 
    
    if (execvp(args[0], args) == -1) {
        fprintf(stderr, "Error ejecutando el comando %s", args[0]);
        exit(EXIT_FAILURE);
    }
       
}

void execute_pipeline(pipeline apipe) {
    assert(apipe != NULL);
    unsigned int j = 0;
    unsigned int pipe_len = pipeline_length(apipe);
    unsigned int num_pipes = 0;
    scommand cmd = NULL;
    if (pipe_len > 0) {
       num_pipes = pipe_len-1;
    }

    
    // int fds[2*num_pipes]; // file descriptors   
    int *fds = (int *)malloc(2 * num_pipes * sizeof(int)); // Asignación dinámica para descriptores de archivo

    
    for (unsigned int i = 0; i < num_pipes; i++) {
        if (pipe(fds + i*2) == -1) {
            fprintf(stderr, "Error abriendo los pipes\n");
            exit(EXIT_FAILURE);
        }
    }
    
    while (!pipeline_is_empty(apipe))
    {   
        if (builtin_alone(apipe)) {
            cmd = pipeline_front(apipe);
            builtin_run(cmd);
            pipeline_pop_front(apipe);
            break;
        }

        cmd = pipeline_front(apipe);

        int rc = fork();
        if (rc < 0) {
            fprintf(stderr, "Error en el fork");
            exit(EXIT_FAILURE);
        }
        else if (rc == 0) { //child process
            if (j != 0) { // no es primer cmd
                // printf("stdout -> p_write: %d, j: %u\n", fds[(j-1)*2], j);
                dup2(fds[(j-1)*2], STDIN_FILENO); 
            }
            if (j != pipe_len-1) { // no es último cmd
                // printf("stdin -> p_read: %d, j: %u\n", fds[j*2+1], j);
                dup2(fds[j*2+1], STDOUT_FILENO); 
            }
            for (unsigned int i = 0; i < 2*num_pipes; i++) { // cierro todos los pipes en los hijos
                if (close(fds[i]) < 0) {
                    printf("Error cerrando el pipe número %u", i);
                    exit(EXIT_FAILURE);
                }
            }     
            execute_scommand(cmd);
        }
        j++;
        pipeline_pop_front(apipe);
        
    }
    
    for (unsigned int i = 0; i < 2*num_pipes; i++) { // cierro todos los pipes en el padre
        if (close(fds[i]) < 0) {
            printf("Error cerrando el pipe número %u", i);
            exit(EXIT_FAILURE);
        }
    }
        
    for (unsigned int i = 0; i < pipe_len; i++) { // para cada hijo, espero.
        wait(NULL);
    }
}
