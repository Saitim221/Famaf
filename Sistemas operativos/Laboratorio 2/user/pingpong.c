#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/spinlock.h"


int main(int argc, char *argv[]) {
    int rally = atoi(argv[1]);
    int rc;
    int sem_code;

    int PING = 0;
    int PONG = 1;

    if (argv[1][0] == '-' || rally == 0) {
        printf("ERROR: El número de rounds tiene que ser mayor a 1\n");
    }
    sem_code = sem_open(PING,1); // semáforo ping
    if (sem_code < 0) { 
        printf("ERROR: la cantidad máxima de semaforos es 5\n");
        exit(1);
    }
    sem_code = sem_open(PONG,0); // semáforo pong
    if (sem_code < 0) {  
        printf("ERROR: la cantidad máxima de semaforos es 5\n");
        exit(1);
    }
    
    
    rc = fork();
    if (rc < 0) {
        printf("Error haciendo fork\n");
        exit(1);
    }
    else if (rc == 0) { // hijo --> pong
        for (unsigned int i = 0; i < rally; i++) {
            sem_code = sem_down(PONG);
            if (sem_code < 0) {
                printf("ERROR: la cantidad máxima de semaforos es 5\n");
                exit(1);
            }

            printf("    pong\n");

            sem_code = sem_up(PING);
            if (sem_code < 0) {
                printf("ERROR: la cantidad máxima de semaforos es 5\n");
                exit(1);
            }
            else if (sem_code == -2) {
                printf("a ping\n");
                printf("ERROR: la cuenta no puede superar 1\n");
                exit(1);
            }
        }
    }
    else { // padre --> ping
        for (unsigned int i = 0; i < rally; i++) {
            sem_code = sem_down(PING);
            if (sem_code < 0) {
                printf("ERROR: la cantidad máxima de semaforos es 5\n");
                exit(1);
            }
            printf("ping\n");
            sem_code = sem_up(PONG);
            if (sem_code < 0) {
                printf("ERROR: la cantidad máxima de semaforos es 5\n");
                exit(1);
            }
            else if (sem_code == -2) {
                printf("a pong\n");
                printf("ERROR: la cuenta no puede superar 1\n");
                exit(1);
            }
        }
        wait(0); // (int *)  ???
        sem_code = sem_close(PING);
        if (sem_code < 0) {
            printf("ERROR: la cantidad máxima de semaforos es 5\n");
            exit(1);
        }
        else if (sem_code == -2) {
            printf("ERROR: no se puede cerrrar un semáforo que esta siendo usado\n");
            exit(1);
        }
        sem_code = sem_close(PONG);
        if (sem_code < 0) {
            printf("ERROR: la cantidad máxima de semaforos es 5\n");
            exit(1);
        }
        else if (sem_code == -2) {
            printf("ERROR: no se puede cerrrar un semáforo que esta siendo usado\n");
            exit(1);
        }
    }
    exit(0);
}