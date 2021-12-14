grammar Kotlin;

//parser rules

prog : packageHeader? importHeader* declaration* EOF ;

packageHeader
    : (PACKAGE identifier)
    ;

importHeader
    : IMPORT identifier (DOT MULT)? ;
    
identifier
    : Identifier (DOT Identifier)*
    ;

declaration
    : classDeclaration
    | functionDeclaration
    | propertyDeclaration
    ;

propertyDeclaration
    : (VAL | VAR) variableDeclaration ((ASSIGNMENT expr))?
    ;

//class declaration
classDeclaration
    : OPEN? CLASS Identifier        //modifiers, modifier : open 하나
      (LPAREN (classParameter (COMMA classParameter)* (COMMA)?)? RPAREN)?
      (COLON Identifier LPAREN RPAREN)?  // : shape()
      (LCURL (declaration)* RCURL)?  //{var a = (b+c)*2}
    ;

classParameter
    : (VAL | VAR)? Identifier COLON type  //type: Double
    ;


type    //usertype == type
    :Identifier (LANGLE type RANGLE)? (DOT Identifier)*
    | nullableType
    ;

nullableType
    :(Identifier (LANGLE type RANGLE)? (DOT Identifier)*) QUEST
    ;

functionDeclaration
    : FUN Identifier functionValueParameters (COLON type)? (functionBody)?
    ;

functionValueParameters
    : LPAREN (parameter (COMMA parameter)* (COMMA)?)? RPAREN
    ;

parameter
    : Identifier  COLON  type
    ;

functionBody
    :LCURL  statements  RCURL
    | ASSIGNMENT  expr
    ;

statements
    : (statement ( statement)*)?        //한줄 한줄이 statement
    ;

statement
    : ( declaration | assignment | forStatement| whileStatement | expr)
    ;

forStatement
    : FOR LPAREN variableDeclaration IN expr RPAREN  (LCURL  statements  RCURL | statement)?
    ;

whileStatement
    : WHILE LPAREN expr RPAREN (LCURL  statements  RCURL | statement)
    ;

variableDeclaration
    : Identifier (COLON type)?
    ;
 
multiVariableDeclaration
    : LPAREN  variableDeclaration ( COMMA  variableDeclaration)* ( COMMA)?  RPAREN
    ;

assignment
    : Identifier (ASSIGNMENT |  ADD_ASSIGNMENT)  expr
    ;

expr
    :RETURN expr?
    |ifExpression
    |cmpExpr ( CONJ  cmpExpr)*
    ;

cmpExpr
    :isInExpr  ((EQEQ|EXCL_EQ|LANGLE|RANGLE)  isInExpr)*
    ;

isInExpr
    : rangeExpr (identifier  (Integer|Real|Long))* ((IN|NOT_IN)  rangeExpr (identifier  (Integer|Real|Long))* | (IS|NOT_IS)  type)* (LPAREN  (valueArgument ( COMMA  valueArgument)* ( COMMA)?  )? RPAREN)*
    ;

valueArgument   //중요 (함수 안)
    : (identifier ASSIGNMENT )? expr
    ;

rangeExpr
    :addExpr (RANGE NL* addExpr)*
    ;

addExpr
    : multExpr (ADD NL* multExpr)*
    ;

multExpr
    : (SUB|ADD|EXCL)* mainExpr postUnary* (MULT (SUB)* (Integer|Identifier))*
    ;

postUnary
    : INCR
    | LPAREN  (valueArgument ( COMMA  valueArgument)* ( COMMA)?  )? RPAREN
    | DOT Identifier
    ;

mainExpr
    : LPAREN  expr  RPAREN
    | Identifier
    | (Integer|Real|NullLiteral|Long)
    | QUOTE
    | ifExpression
    | RETURN expr?
    ;

ifExpression
    : IF  LPAREN  expr  RPAREN 
      ( (LCURL  statements  RCURL | statement)
      | (LCURL  statements  RCURL | statement)?  ELSE  ((LCURL  statements  RCURL | statement)))
    ;

// lexer rules

// SECTION: separatorsAndOperations
QUOTE: '"' ~('\\' | '"' | '$')* '"';
RANGE: '..';
DOT: '.';
COMMA: ',';
LPAREN: '(';
RPAREN: ')';
LCURL: '{';
RCURL: '}';
MULT: '*';
ADD: '+';
SUB: '-';
INCR: '++';
CONJ: '&&';
COLON: ':';
ASSIGNMENT: '=';
ADD_ASSIGNMENT: '+=';
QUEST: '?' ;
LANGLE: '<';
RANGLE: '>';
EXCL_EQ: '!=';
EQEQ: '==';
EXCL: '!';
NL: [\r\n]+ ->skip;
DelimitedComment : '/*' (.)*? '*/' -> skip ;
PACKAGE: 'package';
IMPORT: 'import';
CLASS: 'class';
FUN: 'fun';
OBJECT: 'object';
VAL: 'val';
VAR: 'var';
NullLiteral: 'null';
FOR: 'for';
RETURN: 'return';
NOT_IS: '!is';
NOT_IN: '!in';
IS: 'is';
IN: 'in';
IF: 'if';
ELSE: 'else';
WHILE: 'while';
OPEN: 'open';
Real : [0-9]+ '.' [0-9]+ ;
Integer : [0-9]+ ;
Long : Integer 'L' ;
Identifier : [a-zA-Z] [a-zA-Z0-9]* ;
//LineStrText : ~('\\' | '"' | '$')+ ;
LineComment : ('//' ~[\r\n]*) -> skip ;
WS  :  ([ \t]+) -> skip ;