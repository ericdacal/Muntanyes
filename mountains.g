#header
<<
#include <string>
#include <iostream>
#include <stdlib.h>
#include <map>
#include <vector>
using namespace std;


// struct to store information about tokens
typedef struct {
  string kind;
  string text;
} Attrib;


// function to fill token information (predeclaration)
void zzcr_attr(Attrib *attr, int type, char *text);

// fields for AST nodes
#define AST_FIELDS string kind; string text;
#include "ast.h"

// macro to create a new AST node (and function predeclaration)
#define zzcr_ast(as,attr,ttype,textt) as=createASTnode(attr,ttype,textt)
AST* createASTnode(Attrib* attr, int ttype, char *textt);
>>

<<
#include <cstdlib>
#include <cmath>

//global structures
AST *root;


// function to fill token information
void zzcr_attr(Attrib *attr, int type, char *text) {
  // if (type == ID) {
  //   attr->kind = "id";
  //   attr->text = text;
  // }
  // else {
    attr->kind = text;
    attr->text = "";
  // }
}

// function to create a new AST node
AST* createASTnode(Attrib* attr, int type, char* text) {
  AST* as = new AST;
  as->kind = attr->kind;
  as->text = attr->text;
  as->right = NULL;
  as->down = NULL;
  return as;
}

/// create a new "list" AST node with one element
AST* createASTlist(AST *child) {
  AST *as = new AST;
  as->kind = "list";
  as->right = NULL;
  as->down = child;
  return as;
}

/// get nth child of a tree. Count starts at 0.
/// if no such child, returns NULL
AST* child(AST *a, int n) {
  AST *c = a->down;
  for (int i=0; c!=NULL && i<n; i++) c = c->right;
  return c;
}


/// print AST, recursively, with indentation
void ASTPrintIndent(AST *a, string s) {
  if (a == NULL) return;

  cout << a->kind;
  if (a->text != "") cout << "(" << a->text << ")";
  cout << endl;

  AST *i = a->down;
  while (i != NULL && i->right != NULL) {
    cout << s+"  \\__";
    ASTPrintIndent(i, s+"  |"+string(i->kind.size()+i->text.size(), ' '));
    i = i->right;
  }

  if (i != NULL) {
    cout << s+"  \\__";
    ASTPrintIndent(i, s+"   "+string(i->kind.size()+i->text.size(), ' '));
    i = i->right;
  }
}

/// print AST
void ASTPrint(AST *a) {
  while (a != NULL) {
    cout << " ";
    ASTPrintIndent(a, "");
    a = a->right;
  }
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                      Structures to work and store mountains
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// struct to store the diferents sections of the mountain
typedef struct{
    int rep;
    char sym;
}  Section;

//Define mountain as a vector of Sections
typedef vector<Section> Mountain;

//Struct that contain mountains and associates
//moutains with her name variable
map< string, Mountain > Mountains;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                      Functions to work with mountains
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////





Mountain peak(AST *a) {
  Section up;
  up.rep = atoi((a->right->down->kind).c_str());
  up.sym = '/';

  Section top;
  top.rep = atoi((a->right->down->right->kind).c_str());
  top.sym = '-';

  Section down;
  down.rep = atoi((a->right->down->right->right->kind).c_str());
  down.sym = '-';

  Mountain m;

  m.push_back(up);
  m.push_back(top);
  m.push_back(down);

  return m;
}

Mountain valley(AST *a) {
  Section up;
  up.rep = atoi((a->right->down->right->right->kind).c_str());
  up.sym = '/';

  Section top;
  top.rep = atoi((a->right->down->right->kind).c_str());
  top.sym = '-';

  Section down;
  down.rep = atoi((a->right->down->kind).c_str());
  down.sym = '-';

  Mountain m;

  m.push_back(down);
  m.push_back(up);
  m.push_back(top);

  return m;
}


//Store the concatenation of Section in a Mountain
Mountain concatenation(AST *a) {
  if(a == NULL) {
    Mountain f;
    return f;
  }
  else if(a->kind == ";") {
    Mountain l = concatenation(a->down);
    Mountain r = concatenation(a->right);
    l.insert(l.end(), r.begin(), r.end());
    return l;
  }
  else if(a->kind == "*") {
    Section s;
    s.rep = atoi((a->down->kind).c_str());
    s.sym = a->down->right->kind.c_str()[0];
    Mountain m;
    m.push_back(s);
    return m;
  }
}


//Guardar altura en cada punto para hacer el draw y luego hacer ir una función recursiva en funcion de la altura máxima

//Evaluate the AST tree and perform syntactic analysis
void evaluate(AST *root) {
    if(root == NULL) return;
    else if(root->kind == "is") {
        if(root->down->right->kind == "Peak") {
          Mountain m = peak(root->down);
          Mountains[root->down->kind] = m;
        }
        else if(root->down->right->kind == "Valley") {
          Mountain m = valley(root->down);
          Mountains[root->down->kind] = m;
        }
        else if(root->down->right->kind == ";") {
          Mountain l = concatenation(root->down->right->down);
          Mountain r = concatenation(root->down->right->right);
          l.insert(l.end(), r.begin(), r.end());
          Mountains[root->down->kind] = l;
        }
    }
    evaluate(root->right);
}




int main() {
  root = NULL;
  ANTLR(mountains(&root), stdin);
  evaluate(root->down);
  ASTPrint(root);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////






>>


#lexclass START
#token NUM "[0-9]+"
#token VAR "[A-Z][0-9]*"
#token IS "is"
#token SEP "\*"
#token UP "\/"
#token DOWN "\\"
#token TOP "\-"
#token CON "\;"
#token EQU "\=="
#token LESS "\<"
#token EQU "\>"
#token PE "Peak"
#token VA "Valley"
#token DR "Draw"
#token COM "Complete"
#token HEI "Height"
#token WEF "Wellformed"
#token MAT "Match"
#token WH "while"
#token ENDWH "endwhile"
#token IF "if"
#token ENDIF "endif"
#token OR "OR"
#token AND "AND"
#token NOT "NOT"
#token ASTE "\#"
#token PARO "\("
#token PARC "\)"
#token COM "\,"
#token PLUS "\+"

#token SPACE "[\ \t \n]" << zzskip(); >>

mountains: (assign | draw | complete | condic | iter)* <<#0=createASTlist(_sibling);>>;
draw: DR^ PARO! mountoperation PARC!;
complete: COM^ PARO! VAR PARC!;
condic: IF^ PARO! queries PARC! mountains ENDIF!;
queries: queriesand (OR^ queriesand)*;
queriesand: queriesnot (AND^ queriesnot)*;
queriesnot: (NOT^ |) query;
query:  WEF^ PARO! VAR PARC! | MAT^ PARO! ASTE! VAR COM! ASTE! VAR PARC! | height (EQU^ | LESS^ | GREAT^ | ) numoperation | numoperation (EQU^ | LESS^ | GREAT^ | ) numoperation;
height: HEI^ PARO! ASTE! VAR PARC!;
assign: VAR IS^ mountoperation;
mountoperation: (concatenation | component) (CON^ (concatenation | component))* ;
component: (PE^ | VA^) PARO! numoperation COM! numoperation COM! numoperation PARC!;
concatenation: NUM (SEP^ (UP | DOWN | TOP)  | ) | ASTE! VAR;
numoperation: (numoperationlow)  ((PLUS^ | TOP^) (numoperationlow))*;
numoperationlow: (VAR |NUM) ((UP^ | SEP^) (VAR |NUM))*;
iter: WH^ PARO! queries PARC! mountains ENDWH!;
