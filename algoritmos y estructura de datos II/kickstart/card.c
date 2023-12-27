#include <stdlib.h>
#include <stdbool.h>

#include <assert.h>
#include "card.h"

struct s_card {
    unsigned int num;
    color_t color;
    type_t type;
};

static bool
invrep(card_t c) {
    // Invariante de representación
    bool valid=true;
    if (c->type == change_color || c->type == skip)
    {
        valid &= c->num == 0;
    }
    valid  &= c->num <= 9;

    
    /*
     * [COMPLETAR]
     *
     * Mejorar la invariante chequeando más
     * propiedades de los campos de la estructura
     *
     */
    return valid;
}

card_t
card_new(unsigned int num, color_t color, type_t s) {
    card_t card=NULL;
    /*
     * [COMPLETAR]
     *
     */
    card = malloc(sizeof(struct s_card) );
    card->color = color;
    card->num = num;
    card->type = s;
  assert(invrep(card));
    return card;
}


type_t
card_get_number(card_t card) {
    assert(invrep(card));
    return card->num;
}

color_t
card_get_color(card_t card) {
    assert(invrep(card));
    return card->color;
}

type_t
card_get_type(card_t card) {
    assert(invrep(card));
    return card->type;
}

bool
card_samecolor(card_t c1, card_t c2) {
    /*
     * [COMPLETAR]
     *
     */
    bool res = false;
    if (c1->color == c2->color)
    {
        res = true;
    }

    return res;
}


bool
card_samenum(card_t c1, card_t c2) {
    bool res = false;
    if (c1->num == c2->num)
    {
        res = true;
    }
    return res;
}

bool
card_compatible(card_t new_card, card_t pile_card) {
    bool compatible=false;
    assert(invrep(new_card) && invrep(pile_card));
    /*
     * [COMPLETAR]
     *
     */
    if (new_card->type == change_color)
    {
        compatible = true;

    } else if (card_samecolor(new_card, pile_card))
    {
        compatible = true;

    } else if (card_samenum(new_card, pile_card))
    {
        compatible = true;

    } else if(new_card->type != normal && new_card->type == pile_card->type){

        compatible = true;
        
    }
    
    
    
    
    return compatible;
}

card_t
card_destroy(card_t card) {
    free(card);
    card = NULL;
    return card;
}


