#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <assert.h>
#include "abb.h"

struct _s_abb {
    abb_elem elem;
    struct _s_abb *left;
    struct _s_abb *right;
};

static bool 
elem_eq(abb_elem a, abb_elem b)
{
    return(a == b);
}

static bool 
elem_less(abb_elem a, abb_elem b)
{
    return(a < b);
}

/*
 * @brief: Checks if all the elements of the right subtree are 
 * greater than the root of the tree. 
 *        
 * @param tree: The subtree to check.
 * @param e: The root of the tree of type abb_elem.
 * @return: True if all the elements of the right subtree are greater than
 * */

static bool 
isSubtreeRightGreater(abb tree, abb_elem e)
{   
    bool res = true;
    if(tree != NULL) 
    {
        res = elem_less(e, tree->elem)              && 
              isSubtreeRightGreater(tree->right, e) &&
              isSubtreeRightGreater(tree->left, e);
    }

    return(res);
}
 
/*
 * @brief: Checks if all the elements of the left subtree are 
 * less than the root of the tree. 
 *
 * @param tree: The tree to check.
 * @param e: The root of the tree. 
 * @return: True if all the elements of the left subtree are less than
 *
 * */

static bool 
isSubtreeLeftLess(abb tree, abb_elem e)
{   
    bool res = true;
    if(tree != NULL) 
    {
        res = elem_less(tree->elem, e)         &&
              isSubtreeLeftLess(tree->left, e) &&
              isSubtreeLeftLess(tree->right, e);
    }

    return(res);
}
 
/*
 * @brief: Checks if the tree is a valid abb.
 *         invrep is a recursive function.
 *
 * @param: tree: The tree to check.
 * @return: True if the tree is a valid abb.
 * 
 * How to do this? 
 * 
 * 1. check if the right subtree is greater than the root 
 * 2. check if the left subtree is less than the root 
 * 3. check if the right subtree is a valid abb 
 * 4. check if the left subtree is a valid abb 
 *
 * */ 

static bool 
invrep(abb tree)
{
    bool res = true;
    if(tree==NULL)
    {
        res = true;
    }
    else 
    {
        res = isSubtreeRightGreater(tree->right, tree->elem) &&
              isSubtreeLeftLess(tree->left, tree->elem)      &&
              invrep(tree->right) && invrep(tree->left);
    }

    return(res);
}
 
/*
 * @brief: Creates a leaf of the abb.
 * @param: e: The element of the leaf.
 * @return: The leaf.
 *  */

static abb 
mk_leaf(abb_elem e) 
{   
    abb tree = NULL; 
    tree = malloc(sizeof(struct _s_abb));
    assert(tree != NULL);
    tree->elem = e; 
    tree->left = abb_empty(); 
    tree->right = abb_empty();
    
    return(tree);
}

/*
 * @brief: destroys a leaf of the abb.
 * @return: NULL
 *
 * */ 

static abb
rm_leaf(abb tree)
{
    assert(!abb_is_empty(tree));
    tree->left = NULL;
    tree->right = NULL;
    free(tree);
    tree = NULL;

    return(tree);
}

/*
 * @brief: removes the maximum element of the tree.
 * @param: tree: The tree. 
 * @return: The tree without the maximum element. 
 * 
 * @pre: The tree is not empty.
 *
 *  */

static abb 
remove_max(abb tree)
{
    if(!abb_is_empty(tree))
    {
        if(abb_is_empty(tree->right))
        {   
            abb ref = tree->left;
            tree = rm_leaf(tree);
            tree = ref;
        }
        else 
        {
            tree->right = remove_max(tree->right);
        }
    }

    return(tree);
}

abb
abb_remove(abb tree, abb_elem e)
{
    assert(invrep(tree));
    
    if(!abb_is_empty(tree))
    {
        if(elem_less(e, tree->elem))
        {
            tree->left = abb_remove(tree->left, e);
        }
        else if(e==tree->elem && abb_is_empty(tree->left))
        {   
            abb tp = tree->right;
            tree = rm_leaf(tree);
            tree = tp;
            tp = NULL;
        }
        else if(e==tree->elem && !abb_is_empty(tree->left))
        {
            tree->elem = abb_max(tree->left);
            tree->left = remove_max(tree->left); 
        }
        else if(elem_less(tree->elem, e))
        {
            tree->right = abb_remove(tree->right, e);
        }
    }

    assert(invrep(tree) && !abb_exists(tree, e));

    return(tree);
}
 
abb 
abb_empty(void)
{
    abb tree = NULL;
    assert(invrep(tree) && abb_is_empty(tree));
    
    return(tree);
}

abb 
abb_add(abb tree, abb_elem e)
{
    assert(invrep(tree));
    if(abb_is_empty(tree))
    {
        tree = mk_leaf(e);
    }
    else 
    {
        if(e == abb_root(tree))
        {
            ;
        }
        else if(elem_less(e, abb_root(tree)))
        {
            tree->left = abb_add(tree->left, e);
        }
        else if(elem_less(abb_root(tree), e))
        {
            tree->right = abb_add(tree->right, e);
        }
    } 
    assert(invrep(tree) && abb_exists(tree, e));
    
    return(tree);
}
 
bool
abb_is_empty(abb tree)
{
    bool is_empty = (tree == NULL);
   
    return(is_empty);
}

bool
abb_exists(abb tree, abb_elem e)
{
    bool exists = false;
    assert(invrep(tree));

    exists = (tree!=NULL) && ((elem_eq(e, tree->elem)) || 
             (elem_less(tree->elem, e) && abb_exists(tree->right, e)) ||
             (elem_less(e, tree->elem) && abb_exists(tree->left, e)));

    return(exists);
}

unsigned int 
abb_length(abb tree)
{
    unsigned int length = 0u;
    assert(invrep(tree));
    if(!abb_is_empty(tree))
    {
        length = abb_length(tree->left)  +
                 abb_length(tree->right) + 1u;
    }
    assert(invrep(tree) && (abb_is_empty(tree) || length > 0u));

    return(length);
}

abb_elem 
abb_root(abb tree)
{
    assert(invrep(tree) && !abb_is_empty(tree));
    abb_elem root = tree->elem; 
    assert(abb_exists(tree, root));
   
    return(root);
}

abb_elem
abb_max(abb tree) 
{
    assert(invrep(tree) && !abb_is_empty(tree));
    abb_elem max_e;
    if(abb_is_empty(tree->right))
    {
        max_e = tree->elem;
    }
    else
    {
        max_e = abb_max(tree->right);
    }
    assert(invrep(tree) && abb_exists(tree, max_e));
    
    return(max_e);
}

abb_elem
abb_min(abb tree)
{
    assert(invrep(tree) && !abb_is_empty(tree));
    abb_elem min_e;
    if(abb_is_empty(tree->left))
    {
        min_e = tree->elem;
    }
    else
    {
        min_e = abb_min(tree->left);
    }
    assert(invrep(tree) && abb_exists(tree, min_e));
    
    return(min_e);
}

void
abb_dump(abb tree)
{
    assert(invrep(tree));
    if (tree != NULL) 
    {
        abb_dump(tree->left);
        printf("%d ", tree->elem);
        abb_dump(tree->right);
    }
}

abb 
abb_destroy(abb tree)
{
    assert(invrep(tree));
    if(!abb_is_empty(tree))
    {
        abb_destroy(tree->left);
        abb_destroy(tree->right);
        free(tree);
        tree = NULL;
    }
    assert(tree == NULL);

    return(tree);
}