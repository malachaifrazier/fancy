%{
#include "ruby.h"
#include "parser.h"

int yyerror(char *s);
%}

%option yylineno

digit		[0-9]
capital         [A-Z]
lower           [a-z]
letter          [A-Za-z]
special         [-+?!_=*/^><%&~]
operator        ({special}+|"||"{special}*)
int_lit 	-?({digit}|_)+
double_lit      {int_lit}\.{digit}+
string_lit      \"[^\"\n]*\"
doc_string      \"\"\"[^\"]*\"\"\"
lparen          \(
rparen          \)
lcurly          "{"
rcurly          "}"
lbracket        "["
rbracket        "]"
lhash           "<["
rhash           "]>"
stab            "|"
arrow           "=>"
delimiter       [ \n\r\t\(\)]
return_local    "return_local"
return          "return"
require         "require:"
try             "try"
catch           "catch"
finally         "finally"
retry           "retry"
super           "super"
private         "private"
protected       "protected"
self            "self"
identifier      @?@?({lower}|[_&*])({letter}|{digit}|{special})*
constant        {capital}({letter}|{digit}|{special})*
nested_constant ({constant}::)+{constant}
symbol_lit      \'({identifier}|{operator}|:|"[]")+
regexp_lit      "r{".*"}"
comma           ,

semi            ;
equals          =
colon           :
class           "class"
def             "def"
dot             "."
dollar          "$"
comment         #[^\n]*

%%

{class}         { return CLASS; }
{def}           { return DEF; }
{int_lit}	{
                  yylval.object = rb_str_new2(yytext);
                  return INTEGER_LITERAL;
                }
{double_lit}    {
                  yylval.object = rb_str_new2(yytext);
                  return DOUBLE_LITERAL;
                }
{string_lit}	{
                  yylval.object = rb_str_new2(yytext);
                  return STRING_LITERAL;
                }
{doc_string}	{
                  yylval.object = rb_str_new2(yytext);
                  return STRING_LITERAL;
                }
{lparen}        { return LPAREN; }
{rparen}        { return RPAREN; }
{lcurly}        { return LCURLY; }
{rcurly}        { return RCURLY; }
{lbracket}      { return LBRACKET; }
{rbracket}      { return RBRACKET; }
{lhash}         { return LHASH; }
{rhash}         { return RHASH; }
{stab}          { return STAB; }
{arrow}         { return ARROW; }
{equals}        { return EQUALS; }
{operator}      {
                  yylval.object = rb_str_new2(yytext);
                  return OPERATOR;
                }
{return_local}  { return RETURN_LOCAL; }
{return}        { return RETURN; }
{require}       { return REQUIRE; }
{try}           { return TRY; }
{catch}         { return CATCH; }
{finally}       { return FINALLY; }
{retry}         { return RETRY; }
{super}         { return SUPER; }
{private}       { return PRIVATE; }
{protected}     { return PROTECTED; }
{self}          {
                  yylval.object = rb_str_new2(yytext);
                  return IDENTIFIER; }
{identifier}    {
                  yylval.object = rb_str_new2(yytext);
                  return IDENTIFIER;
                }
{constant}      {
                  yylval.object = rb_str_new2(yytext);
                  return CONSTANT;
                }
{nested_constant} {
                  yylval.object = rb_str_new2(yytext);
                  return CONSTANT;
                }
{symbol_lit}    {
                  yylval.object = rb_str_new2(yytext);
                  return SYMBOL_LITERAL;
                }
{regexp_lit}    {
                  yylval.object = rb_str_new2(yytext);
                  return REGEX_LITERAL;
                }
{comma}         { return COMMA; }
{semi}          { return SEMI; }
{colon}         { return COLON; }
{dot}           { return DOT; }
{dollar}        { return DOLLAR; }

{comment}       {}

[ \t]*		{}
[\n]		{ return NL; }

.		{ fprintf(stderr, "SCANNER %d", yyerror("")); exit(1);	}

