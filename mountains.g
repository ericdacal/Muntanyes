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
    if (type == VAR) {
        attr->kind = "id";
        attr->text = text;
    }
    else if (type == NUM) {
        attr->kind = "intconst";
        attr->text = text;
    }
    else {
        attr->kind = text;
        attr->text = "";
    }
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
    int height;
}  Section;

typedef struct {
  vector<Section> sections;
  int max_height;
  int min_height;
} Mountain;

//Struct that contain mountains and associates
//mountains with her name variable
map< string, Mountain > Mountains;

//Struct that contain numeric variables and associates
//numeric variables with her name variable
map< string, int> numVars;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                      Functions to work with mountains
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


void draw(Mountain m) {
  /*  for(int i = m.max_height; i > m.min_height; --i) {
        for(int j = 0; j < m.sections.size(); ++j) {
                if(m.sections[j].height == i) {
                    if(m.sections[j].sym != '-') {
                      --m.sections[j].height;
                      cout << m.sections[j].sym;
                    }
                    else {

                    }
                }
                else cout << '*';
        }
        cout << endl;
    }*/

}



int num_operation(AST *a) {
    if(a->kind == "+") return num_operation(a->down) + num_operation(a->down->right);
    else if(a->kind == "-") return num_operation(a->down) - num_operation(a->down->right);
    else if(a->kind == "/") return num_operation(a->down) / num_operation(a->down->right);
    else if(a->kind == "*") return num_operation(a->down) * num_operation(a->down->right);
    else if(a->kind == "intconst") return atoi((a->text).c_str());
    else if(a->kind == "Height") return Mountains[a->down->text].max_height;
    else return numVars[a->text];
}


bool match(const Mountain& a, const Mountain& b) {
    if(a.sections.size() == b.sections.size()) {
        for(int i = 0; i < a.sections.size(); ++i) {
            if(a.sections[i].sym != b.sections[i].sym or a.sections[i].rep != b.sections[i].rep) return false;
        }
    }
    return true;
}

bool wellformed(const Mountain& a) {
    bool up, down, top;
    up = down = top = false;
    int i = 0;
    while(not up or not down or not top and i < a.sections.size()) {
        if(a.sections[i].sym == '/') up = true;
        else if(a.sections[i].sym == '-') top = true;
        else if(a.sections[i].sym == '\\') down = true;
        ++i;
    }
    return up and top and down;
}

bool bool_operation(AST *a) {
    if(a->kind == "OR") return (bool_operation(a->down) or bool_operation(a->down->right));
    else if(a->kind == "AND") return (bool_operation(a->down) and bool_operation(a->down->right));
    else if(a->kind == "NOT") return not (bool_operation(a->down));
    else if(a->kind == "<") return (num_operation(a->down) < num_operation(a->down->right));
    else if(a->kind == ">") return (num_operation(a->down) > num_operation(a->down->right));
    else if(a->kind == "==") return (num_operation(a->down) == num_operation(a->down->right));
    else if(a->kind == "Match") return match(Mountains[a->down->text], Mountains[a->down->right->text]);
    else if(a->kind == "Wellformed") return wellformed(Mountains[a->down->text]);
}




Mountain peak(AST *a, int type) {
    Mountain m;
    m.max_height = 0;
    m.min_height = 0;
    if(type < 3) {
        Section s;
        s.rep = num_operation(a);
        m = peak(a->right, type + 1);

        if(type == 0) {
            s.sym = '\\';
            if(m.sections.size() == 0) s.height = s.rep;
            else s.height = m.sections[m.sections.size() - 1].height - s.rep;
        }
        else if(type == 1) {
            s.sym = '-';
            if(m.sections.size() == 0) s.height = s.rep;
            else s.height = m.sections[m.sections.size() - 1].height;
        }
        else {
            s.sym = '/';
            if(m.sections.size() == 0) s.height = s.rep;
            else s.height = m.sections[m.sections.size() - 1].height + s.rep;
        }


        if(m.max_height < s.height) m.max_height = s.height;
        if(m.min_height > s.height) m.min_height = s.height;
        m.sections.push_back(s);
    }
    return m;
}

Mountain valley(AST *a, int type) {
    Mountain m;
    m.max_height = 0;
    m.min_height = 0;
    if(type < 3) {
        Section s;
        s.rep = num_operation(a);
        m = valley(a->right, type + 1);
        if(type == 0) {
            s.sym = '/';
            if(m.sections.size() == 0) s.height = s.rep;
            else s.height = m.sections[m.sections.size() - 1].height + s.rep;
        }
        else if(type == 1) {
            s.sym = '-';
            if(m.sections.size() == 0) s.height = s.rep;
            else s.height = m.sections[m.sections.size() - 1].height;
        }
        else {
          s.sym = '\\';
          if(m.sections.size() == 0) s.height = -s.rep;
          else s.height = m.sections[m.sections.size() - 1].height - s.rep;
        }

        if(m.max_height < s.height) m.max_height = s.height;
        if(m.min_height > s.height) m.min_height = s.height;
        m.sections.push_back(s);
    }
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
        Mountain r = concatenation(a->down->right);
        l.sections.insert(l.sections.end(), r.sections.begin(), r.sections.end());
        return l;
    }
    else if(a->kind == "*") {
        Section s;
        s.rep = atoi((a->down->text).c_str());
        s.sym = a->down->right->kind.c_str()[0];
        Mountain m;
        m.sections.push_back(s);
        return m;
    }
    else {
        return Mountains[a->text];
    }
}


//Guardar altura en cada punto para hacer el draw y luego hacer ir una función recursiva en funcion de la altura máxima

//Evaluate the AST tree and perform syntactic analysis
void evaluate(AST *root) {
    if(root == NULL) return;
    else if(root->kind == "is") {
        if(root->down->right->kind == "Peak") {
            Mountain m = peak(root->down->right->down, 0);
            Mountains[root->down->text] = m;
        }
        else if(root->down->right->kind == "Valley") {
            Mountain m = valley(root->down->right->down, 0);
            Mountains[root->down->text] = m;
        }
        else if(root->down->right->kind == ";") {
            Mountain m  = concatenation(root->down->right);
            Mountains[root->down->text] = m;
        }
        else {
            int num = num_operation(root->down->right);
            numVars[root->down->text] = num;
        }
    }
    else if(root->kind == "Draw") {
        if(root->down->kind == ";") {
            Mountain m = concatenation(root->down);
            draw(m);
        }
        else {
            draw(Mountains[root->down->text]);
        }
    }
    evaluate(root->right);
}




int main() {
  root = NULL;
  ANTLR(mountains(&root), stdin);
  evaluate(root->down);
  ASTPrint(root);
  for (map<string,Mountain>::iterator it=Mountains.begin(); it!=Mountains.end(); ++it) {
      cout << it->first << " max_height: " << it->second.max_height << " min_height: " << it->second.min_height << ' ' << endl;
      for(int i = 0; i < it->second.sections.size(); ++i) {
          cout << it->second.sections[i].rep << ' ' << it->second.sections[i].sym << " h: " << it->second.sections[i].height << ' ';
      }
      cout << endl;
  }
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
