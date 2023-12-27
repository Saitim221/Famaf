#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

#include "unogame.h"
#include "card.h"

#define NO_PLAYER -1

struct s_ugame {
    /*
     * [COMPLETAR]
     *
     */
    struct s_node *first;
    unsigned int size;



};
struct s_node {
    card_t card;
    player_t player;
    struct s_node *next;
};

static struct s_node *create_node(card_t card, player_t player) {
    struct s_node *new_node=malloc(sizeof(struct s_node));
    assert(new_node!=NULL);
    new_node->card = card;
    new_node->next = NULL;
    new_node->player = player;
    return new_node;
}

static struct s_node *destroy_node(struct s_node *node) {
    node->next=NULL;
    card_destroy(node->card );
    free(node);
    node=NULL;
    return node;
}

unogame_t
uno_newgame(card_t card) {
    /*
     * [COMPLETAR]
     *
     */
    unogame_t uno = NULL;
    uno = malloc(sizeof(struct s_ugame));
    uno->first = create_node(card, NO_PLAYER);
    uno->size++;
    return uno;

}

card_t
uno_topcard(unogame_t uno) {
    /*
     * [COMPLETAR]
     *
     */
    return uno->first->card; 

}

unogame_t
uno_addcard(unogame_t uno, card_t c) {
    /*
     * [COMPLETAR]
     *
     */
    struct s_node *newnode = create_node(c, NO_PLAYER);
    newnode->next = uno->first;
    uno->first = newnode;
    uno->size++;
    return uno;
}

unsigned int
uno_count(unogame_t uno) {
    /*
     * [COMPLETAR]
     *
     */
    return uno->size;
}

bool
uno_validpile(unogame_t uno) {
    /*
     * [COMPLETAR]
     *
     */
    bool validpile = true;
    struct s_node *p = NULL;
    p = uno->first;
    while(p->next->next != NULL){
        if (card_compatible(p->card, p->next->card)){
            validpile &= true;
        }else{
            validpile &= false;
        }
        p = p->next;
    }
    return validpile;
}

color_t
uno_currentcolor(unogame_t uno) {
    /*
     * [COMPLETAR]
     *
     */
    return card_get_color(uno->first->card);
}

player_t
uno_nextplayer(unogame_t uno) {
    /*
     * [COMPLETAR]
     *
     */
    player_t player;
    if(uno->first->player == 0){
        player = NUM_PLAYERS-1;
    }else{
        player = uno->first->player - 1;
    }
    return player;
}



card_t *
uno_pile_to_array(unogame_t uno) {
    /*
     * [COMPLETAR]
     *
     */

   struct s_card **a = calloc(uno_count(uno), sizeof(card_t));
   struct s_node *p = NULL;
   p = uno->first;
  if(uno_count(uno) != 0){
    unsigned int i = 1;
    while(p->next != NULL){
        a[uno_count(uno)-i] = p->card;
        p = p->next;
        }
    }else{
        a = NULL;
    }

    return a;

}

unogame_t
uno_destroy(unogame_t uno) {
    /*
     * [COMPLETAR]
     *
     */
    struct s_node *node=uno->first;
    while (node != NULL) {
        struct s_node *killme=node;
        node = node->next;
        killme = destroy_node(killme);
    }
    free(uno);
    uno = NULL;
    return uno;
}

