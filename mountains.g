#header
<<
#include <string>
#include <iostream>
#include <stdlib.h>
#include <map>
#include <vector>
#include <queue>
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

//Definitions of colours
#define RESET   "\033[0m"
#define GREEN   "\033[32m"      /* Green */
#define WHITE   "\033[37m"      /* White */
#define CYAN    "\033[36m"      /* Cyan */
#define RED     "\033[31m"      /* Red */



//Contador de lineas
int line_count = 0;

//control stat
bool stat;

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

typedef struct {
    string description;
    int inst;
} Error;

//Diccionary that contain mountains and associates
//mountains with her name variable
map< string, Mountain > Mountains;

//Struct that contain numeric variables and associates
//numeric variables with her name variable
map< string, int> numVars;

//Struct that contain a syntactic erros of code
queue<Error> errors;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                      Functions to work with mountains
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


void draw(Mountain m, string name) {
    //for(int i = 0; i < m.sections.size(); ++i) cout << m.sections[i].sym << ' ' << m.sections[i].height  << ' ';
    //cout << endl;
    cout << m.max_height << ' ' << m.min_height << endl;
    for(int i = 0; i < m.sections.size(); ++i) cout << m.sections[i].sym << ' ' << m.sections[i].height << ' ';
    cout << endl;
    for(int i = m.max_height + 1; i > m.min_height and stat; --i) {
        bool up;
        up =  false;
        for(int j = 0; j < m.sections.size(); ++j) {
            int dh;
            if(m.sections[j].sym == '/')  {
                dh = 1;
                up = true;
            }
            else if(m.sections[j].sym == '-') dh = 0;
            else dh = -1;
            int h;
            if(j == 0) h = 1;
            else {
                if(dh == 0) {
                    if(m.sections[j - 1].sym == '/') h = m.sections[j - 1].height + 1;
                    else h = m.sections[j - 1].height - 1;
                }
                else if(dh == -1) h = m.sections[j - 1].height - 1;
                else h = m.sections[j - 1].height;
            }
            int k = 0;
            while(k < m.sections[j].rep) {
                if(i == h + (k * dh)){
                    if(m.sections[j].sym == '-') cout << WHITE <<  m.sections[j].sym << RESET;
                    else if(up) cout << GREEN <<  m.sections[j].sym << RESET;
                }
                else
                {
                    if(i < h + (k * dh)) cout << GREEN << '#' << RESET;
                    else cout << CYAN << '#' << RESET;
                }
                ++k;
            }
        }
        cout << endl;
    }
    if(stat) cout << "l'altitud final de " <<  name <<  " és: " << m.max_height << endl;

}

Mountain complete(AST *a) {
    Mountain m;
    if (Mountains.find(a->text) == Mountains.end() ) {
        m = Mountains[a->text];
        bool top, down, up;
        top = down = up = false;
        int i = 0;
        while(i < m.sections.size()) {
            if(m.sections[i].sym == '/') up = true;
            else if(m.sections[i].sym == '-') top = true;
            else if(m.sections[i].sym == '\\') down = true;
            ++i;
        }
        Section s;
        int hant = m.sections[m.sections.size() - 1].height;
        if(not top) {
            s.sym = '-';
            s.rep = 1;
            if(m.sections[m.sections.size() - 1].sym == '/') s.height = hant + 1;
            else s.height = hant - 1;
            hant = s.height;
            m.sections.push_back(s);
        }
        if(not down) {
            s.sym = '\\';
            s.rep = 1;
            s.height = hant - 1;
            hant = s.height;
            m.sections.push_back(s);
        }
        if(not up) {
            s.sym = '/';
            s.rep = 1;
            s.height = hant + 1;
            hant = s.height;
            m.sections.push_back(s);
        }
    }
    return m;
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
    return a.max_height == b.max_height;
}

bool wellformed(const Mountain& a) {
    bool up, down, top;
    up = down = top = false;
    int i = 0;
    while((not up or not down or not top) and i < a.sections.size()) {
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
    if(a->kind == ";") {
        Mountain l = concatenation(a->down);
        Mountain r = concatenation(a->down->right);
        if(l.max_height < r.max_height) l.max_height = r.max_height;
        if(l.min_height > r.min_height) l.min_height = l.max_height + r.min_height;
        if(r.sections[0].sym == '-') {
            if(l.sections[l.sections.size() - 1].sym == '/') r.sections[0].height = 1;
            else r.sections[0].height = -1;
        }
        else if(r.sections[0].sym == '/') {
            if(l.sections[l.sections.size() - 1].sym == '\\') {
                --r.sections[0].height;
                l.min_height = r.min_height;

            }
        }
        r.sections[0].height += l.sections[l.sections.size() - 1].height;
        l.sections.insert(l.sections.end(), r.sections.begin(), r.sections.end());
        return l;
    }
    else if(a->kind == "*") {
        Section s;
        s.rep = atoi((a->down->text).c_str());
        s.sym = a->down->right->kind.c_str()[0];
        if(s.sym == '/') {
            s.height = s.rep;
        }
        else if(s.sym == '-') {
            s.height = 0;
        }
        else {
            s.height = -s.rep;
        }

        Mountain m;
        if(s.height > 0) {
            m.max_height = s.height;
            m.min_height = 0;
        }
        else if(s.height == 0) {
            m.max_height = 0;
            m.min_height = 0;
        }
        else {
            m.max_height = 0;
            m.min_height = s.height;
        }
        m.sections.push_back(s);
        return m;
    }
    else {
        if (Mountains.find(a->text) == Mountains.end() ) {
            Mountain m;
            return m;
        }
        return Mountains[a->text];
    }
}

//Print all the mountains
void print() {
    for (map<string,Mountain>::iterator it=Mountains.begin(); it!=Mountains.end(); ++it) {
        if(wellformed(it->second)) draw(it->second, it->first);
        cout << endl;
    }

}


//Guardar altura en cada punto para hacer el  y luego hacer ir una función recursiva en funcion de la altura máxima

//Evaluate the AST tree and perform syntactic analysis
void evaluate(AST *root) {
    ++line_count;
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
            if(m.sections.size() > 0) Mountains[root->down->text] = m;
            else {
                stat = false;
                Error e;
                e.inst = line_count;
                e.description = "The mountain " + root->down->text + " doesn't exist.";
                errors.push(e);
                //cout << RED << "error: " << RESET <<   << root->down->text << " doesn't exist." << endl << RESET;
            }
        }
        else if(root->down->right->kind == "*" and root->down->right->down->right->kind != "intconst") {
            Mountain m  = concatenation(root->down->right);
            Mountains[root->down->text] = m;
        }
        else {
            int num = num_operation(root->down->right);
            numVars[root->down->text] = num;
        }
    }
    else if(root->kind == "if") {
        if(bool_operation(root->down)) evaluate(root->down->right->down);
    }
    else if(root->kind == "Complete") {
        Mountain m = complete(root->down);
        if(m.sections.size() > 0) Mountains[root->down->text] = m;
        else {
            stat = false;
            Error e;
            e.inst = line_count;
            e.description = "The mountain " + root->down->text + " doesn't exist.";
            errors.push(e);
            //cout << RED << "error: " << RESET << "The mountain " << root->down->text << " doesn't exist." << endl;
        }
    }
    else if(root->kind == "while") {
        while(bool_operation(root->down)) evaluate(root->down->right->down);
    }
    else if(root->kind == "Draw") {
        if(root->down->kind == ";") {
            Mountain m = concatenation(root->down);
            draw(m, "M");
        }
        else {
            if(Mountains[root->down->text].sections.size() > 0) draw(Mountains[root->down->text],root->down->text);
            else {
                stat = false;
                Error e;
                e.inst = line_count;
                e.description = "The mountain " + root->down->text + " doesn't exist.";
                errors.push(e);
                //cout << RED << "error: " << RESET << "The mountain " << root->down->text << " doesn't exist." << endl;
            }
        }
    }
    evaluate(root->right);
}

void print_errors(){
    while(not errors.empty()) {
        cout << line_count << ": ";
        cout << RED << "error: " << RESET << errors.front().description << endl;
        errors.pop();
    }
    cout << endl;
}

int main() {
  root = NULL;
  stat = true;
  ANTLR(mountains(&root), stdin);
  evaluate(root->down);
  stat = true;
  print_errors();
  ASTPrint(root);
  print();
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
#token COMP "Complete"
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
#token PAD "\#"
#token PARO "\("
#token PARC "\)"
#token COM "\,"
#token PLUS "\+"
#token SPACE "[\ \t \n]" << zzskip(); >>

mountains: (assign | draw | complete | condic | iter)* <<#0=createASTlist(_sibling);>>;
draw: DR^ PARO! mountoperation PARC!;
complete: COMP^ PARO! VAR PARC!;
condic: IF^ PARO! queries PARC! mountains ENDIF!;
queries: queriesand (OR^ queriesand)*;
queriesand: queriesnot (AND^ queriesnot)*;
queriesnot: (NOT^ |) query;
query:  WEF^ PARO! VAR PARC! | MAT^ PARO! PAD! VAR COM! PAD! VAR PARC! | height (EQU^ | LESS^ | GREAT^ | ) numoperation | numoperation (EQU^ | LESS^ | GREAT^ | ) numoperation;
height: HEI^ PARO! PAD! VAR PARC!;


assign: VAR IS^ mountoperation;
mountoperation: (concatenation | component) (CON^ (concatenation | component))*;
component: (PE^ | VA^) PARO! numoperation COM! numoperation COM! numoperation PARC!;
concatenation: NUM (SEP^ (UP | DOWN | TOP))* | PAD! VAR;
numoperation: (numoperationlow)  ((PLUS^ | TOP^) (numoperationlow))*;
numoperationlow: (VAR |NUM) ((UP^ | SEP^) (VAR |NUM))*;
iter: WH^ PARO! queries PARC! mountains ENDWH!;
