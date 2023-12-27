#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <glib.h>
#include <stdbool.h>
#include <string.h>
#include "command.h"
#include "strextra.h"

struct scommand_s 
{
    GQueue *queue;
    char *stdin;
    char *stdout;
};


scommand scommand_new(void) {
    scommand result = NULL;
    result = malloc(sizeof  (struct scommand_s));
    result->queue = g_queue_new();
    result->stdin = NULL;
    result->stdout = NULL;
    assert(result != NULL && scommand_is_empty (result) && scommand_get_redir_in (result) == NULL && scommand_get_redir_out (result) == NULL); // ENSURES
    return result;
}

scommand scommand_destroy(scommand self) {
    assert(self != NULL); // REQUIRES
    g_queue_free(self->queue);
    free(self);
    self = NULL;
    assert(self == NULL); // ensures
    return self;
}

void scommand_push_back(scommand self, char *argument) {
    assert(self != NULL && argument != NULL); // requires
    g_queue_push_tail(self->queue, argument);
    assert(!scommand_is_empty(self)); // ensures
}

void scommand_pop_front(scommand self) {
    assert(self != NULL && !scommand_is_empty(self)); // requires
    g_queue_pop_head(self->queue);
}

void scommand_set_redir_in(scommand self, char * filename) {
    assert(self != NULL); // requires
    self->stdin = filename;
    //scommand_push_back(self, "<");
}

void scommand_set_redir_out(scommand self, char * filename) {
    assert(self != NULL); // requires
    self->stdout = filename;
    //scommand_push_back(self, ">");
}

bool scommand_is_empty(const scommand self) {
    assert(self != NULL);
    return (g_queue_is_empty(self->queue));
}

unsigned int scommand_length(const scommand self) {
    assert(self != NULL); // requires
    unsigned int len = g_queue_get_length(self->queue);
    assert((len == 0) == scommand_is_empty(self)); // ensures
    return len;
}

char * scommand_front(const scommand self) {
    assert(self != NULL && !scommand_is_empty(self)); // requires
    char *front_arg = g_queue_peek_head(self->queue);
    assert(front_arg != NULL); // ensures
    return front_arg;
}

char * scommand_get_redir_in(const scommand self) {
    assert(self != NULL); // requires
    return self->stdin;
}
char * scommand_get_redir_out(const scommand self) {
    assert(self != NULL); // requires
    return self->stdout;
    
}


char * scommand_to_string(const scommand self) {
    assert(self != NULL); // requires
    unsigned int len = scommand_length(self);
    char *cmd = calloc((2*len), sizeof(char));
    assert(cmd != NULL);
    char *arg = NULL;

    for (unsigned int i=0; i<len; i++) {
        arg = g_queue_peek_nth(self->queue, i);
        cmd = strmerge(cmd, arg);
        cmd = strmerge(cmd, " ");
    }
    if (self->stdin != NULL) {
        cmd = strmerge(cmd, " < ");
        cmd = strmerge(cmd, self->stdin);
        }
    if (self->stdout != NULL) {
        cmd = strmerge(cmd, " > ");
        cmd = strmerge(cmd, self->stdout);
    }
    assert(scommand_is_empty(self) || scommand_get_redir_in(self)==NULL || scommand_get_redir_out(self)==NULL || strlen(cmd)>0); // ensures
    return cmd;
}

// agregado
scommand scommand_copy(const scommand self) {
    assert(self != NULL);
    scommand copy = scommand_new();
    copy->queue = g_queue_copy(self->queue);
    copy->stdin = self->stdin;
    copy->stdout = self->stdout;
    return copy;
}


// pipeline 
struct pipeline_s {
    GQueue *queue;
    bool wait;
};

pipeline pipeline_new(void) {
    pipeline p = NULL;
    p = malloc(sizeof(struct pipeline_s));
    p->queue = g_queue_new();
    p->wait = true;
    assert(p != NULL && pipeline_is_empty(p) && pipeline_get_wait(p)); // ensures
    return p;
}

pipeline pipeline_destroy(pipeline self) {
    assert(self != NULL); // requires
    scommand cmd = NULL;
    // libero cada scommand
    for (unsigned int i = 0; i < pipeline_length(self); i++) {
        cmd = g_queue_peek_nth(self->queue, i);
        cmd = scommand_destroy(cmd);
    }
    // libero la cola
    g_queue_free(self->queue);
    // libero el struct
    free(self);
    self = NULL;
    assert(self == NULL); // ensures
    return self;
}

void pipeline_push_back(pipeline self, scommand sc) {
    assert(self != NULL && sc != NULL); // requires
    g_queue_push_tail(self->queue, sc);
    assert(!pipeline_is_empty(self)); // ensures
}

void pipeline_pop_front(pipeline self) {
    assert(self != NULL && !pipeline_is_empty(self)); // requires
    g_queue_pop_head(self->queue);
}

void pipeline_set_wait(pipeline self, const bool w) {
    assert(self != NULL); // requires
    if (w) {
        self->wait = true;
    }
    else {
        self->wait = false;
    }
}

bool pipeline_is_empty(const pipeline self) {
    assert(self != NULL); // requires
    return (g_queue_is_empty(self->queue));
}

unsigned int pipeline_length(const pipeline self) {
    assert(self != NULL); // requires
    unsigned int len = g_queue_get_length(self->queue);
    assert((len == 0) == pipeline_is_empty(self)); // ensures
    return len;
}

scommand pipeline_front(const pipeline self) {
    assert(self!=NULL && !pipeline_is_empty(self)); // requires
    scommand front_arg = g_queue_peek_head(self->queue);
    assert(front_arg != NULL); // ensures
    return front_arg;
}

bool pipeline_get_wait(const pipeline self) {
    assert(self != NULL); // requires
    return self->wait;
}

char * pipeline_to_string(const pipeline self) {
    assert(self != NULL); // requires
    char *pipe = NULL;
    unsigned int len = pipeline_length(self);
    pipe = calloc((2*len)+1, sizeof(char));
    assert(pipe != NULL);
    scommand cmd = NULL;
    if (!pipeline_is_empty(self)) {
        for (unsigned int i=0; i<len-1; i++) {
            cmd = g_queue_peek_nth(self->queue, i);
            pipe = strmerge(pipe, scommand_to_string(cmd));
            pipe = strmerge(pipe, " | ");
        }
        cmd = g_queue_peek_nth(self->queue, len-1);
        pipe = strmerge(pipe, scommand_to_string(cmd));
        if (!self->wait) {
            pipe = strmerge(pipe, " &");
        }
    }
    
    assert(pipeline_is_empty(self) || pipeline_get_wait(self) || strlen(pipe)>0); // ensures
    return pipe;
}

// agregado
pipeline pipeline_copy(const pipeline self) {
    assert(self != NULL);
    pipeline copy = pipeline_new();
    copy->queue = g_queue_copy(self->queue);
    copy->wait = self->wait;
    return copy;
}

