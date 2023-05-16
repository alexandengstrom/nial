# Nial
Nial is a beginner-friendly, object-oriented programming language written in Ruby. It features an easy-to-read syntax that is specifically designed to make programming accessible for newcomers.

Despite its focus on simplicity, Nial also incorporates advanced features such as polymorphism and inheritance, enabling developers to write more complex and sophisticated programs. The language embraces dynamic typing, allowing for flexibility and adaptability during the development process.

## Installation Guide
To get started with Nial, follow these steps:

1. **Clone the repository:** Begin by cloning the Nial repository to your local machine using the following command:
```
git clone git@github.com:alexandengstrom/nial.git
```
2. **Navigate to the Nial directory**: Change into the cloned repositorys directory by running the following command:
```
cd nial
```
3. **Run the setup script:** Execute the "SETUP.sh" script to install Nial.
```
bash SETUP.sh
```
4. **Test the installation:** To verify that Nial has been successfully installed, run a code file with the following command from any directory:
```
nial example.nial
```

Congratulations! You have successfully installed Nial on your machine. You are now ready to create and run your own Nial programs.

## Usage
To use the Nial programming language, please refer to the full documentation and user manual available in the file nial.pdf. This comprehensive resource provides detailed explanations of the language syntax, features, and usage examples. Please note that the documentation is in Swedish.

Here is an example of the Bubble Sort algorithm in Nial:
```
define function bubblesort(list, func)
  length = call list.length()
  
  count i from 1 to length
    swapped = False
    count j from 1 to length-1
      if call func(list[j], list[j + 1]) then
        swapped = True
        temp = list[j]
        list[j] = list[j + 1]
        list[j + 1] = temp
      stop
    stop

    if not swapped then return list stop
  stop

  return list
stop
```
## Implementation
The Nial programming language is built around three main components: the lexer, parser, and interpreter. These components work together to process and execute Nial source code. Additionally, there is a main program that connects these parts and facilitates the execution of Nial programs.

1. **Lexer**: The lexer plays a crucial role in the Nial system. It scans the source code and translates it into a stream of tokens. Tokens are atomic units of the language, such as keywords, identifiers, operators, and literals. The lexer ensures that the source code is properly segmented for further processing.
2. **Parser**: Once the lexer has generated the stream of tokens, the parser comes into play. The parser takes this token stream and constructs an abstract syntax tree (AST) based on the grammar and rules of the Nial language. The AST represents the structure and hierarchy of the code, capturing the relationships between different language elements.
3. **Interpreter**: The interpreter is responsible for evaluating the abstract syntax tree generated by the parser. It traverses the tree, executing each node and performing the corresponding operations. The interpreter executes statements, evaluates expressions and manage variables and memory.

The sequence diagram below illustrates the process flow from source code to executed program:

![sequml](https://github.com/alexandengstrom/nial/assets/123507241/9ffdb70f-afe9-4d00-bc6f-cd40dec8e1f8)

## BNF
Here is the formal grammar of the Nial language, specified using Backus-Naur Form (BNF):

```
  <program>            ::=    <statements>

  <statements>         ::=    <statement> { <statements> } |
                              empty

  <loop statements>    ::=    ( <statement> | ``break'' | ``next'' ) { <loop statements> } |
                              empty

  <func statements>    ::=    ( <statement> | ``return'' [expr] ) { <func statements> } |
                              empty
                              
  <statement>          ::=    <control structure>
                              <type definition>
                              <utility definition>
                              <func definition>
                              <io>
                              <file read>
                              <try block>
                              <import>
                              <expr>
                              <comment>
                              
  <import>             ::=    ``use'' <expr>
                              
  <try block>          ::=    ``try'' <statements>
                              { ``catch'' <type identifier> <statements> }
                              [ ``else'' <statements> ]
                              ``stop''
                              
  <file read>          ::=    ``load'' <expr> ``into'' <identifier>
                              
  <io>                 ::=    <input> | <output>

  <output>             ::=    ``display'' <expr>

  <input>              ::=    ``let user assign'' <identifier>
  
  <control structure>  ::=    <range loop> |
                              <list loop> |
                              <while loop> |
                              <if statement>

  <range loop>         ::=   ``count'' <identifier> ``from'' <expression> ``to'' <expression>
                             <loop statements>
                             ``stop''

  <list loop>          ::=   ``for every'' { ``copy'' }  <identifier> ``in'' <expr>
                             <loop statements>
                             ``stop''

  <while loop>         ::=   ``while'' <logical expression> <loop statements> ``stop''                           
                             
  <if statement>       ::=   ``if'' <condition> ``then'' <loop statements>
                             { ``else if'' <condition> ``then'' <statements> }
                             [ ``else'' <statements> ]
                             ``stop''

  <type definition>    ::=   ``define type'' <type identifier>
                             [``extend'' <type identifier>]
                             {var assign}
                             ``define method'' ``constructor'' ``(`` <params> ``)''
                             <func statements> ``stop''
                             {method definition}
                             ``stop''

  <utility definition> ::=   ``define utility'' <type identifier>
                             { <const assign> } { <method definition> } ``stop''

  
  <method definition>  ::=   ``define method'' <identifier> ``(`` <params> ``)''
                             <func statements> ``stop''


  <func definition>    ::=   ``define function'' <identifier> ``(`` <params> ``)''
                             <func statements> ``stop''
  

  <expr>              ::=    <expr> <assign op> <log expr> |
                             <var assign>
                             <log expr>

  <var assign>        ::=    <identifier> ``='' <expr>

  <const assign>      ::=    <constant> ``='' <expr>
  
  <assign op>         ::=    ``+='' | ``-='' | ``*='' | ``/=''

  <log expr>          ::=    <com expr> <log op> <log expr> |
                             ``not'' <log expr> |
                             <com expr>

  <log op>            ::=    ``and'' | ``or''         

  <com expr>          ::=     <arit expr> <com op> <com expr> |
                              <arit expr>

  <com op>            ::=     ``>'' | ``>='' | ``<'' | ``<='' | ``=='' | ``!=''

  <arit expr>         ::=     <term> <arit op> <arit expr> |
                              <term>

  <arit op>           ::=     ``+'' | ``-'' 

  <term>              ::=     <factor> <term op> <term> |
                              <factor>

  <term op>           ::=     ``*'' | ``/'' | ``%"

  <factor>            ::=    <atom> | ``(`` <expr> ``)''

  <atom>              ::=    <identifier> | <constant> | <number> | <text> | <bool> | <null> |
                             <list> | <dict> | <type init> | <func call> | <method call> |
                             <anon func> | <attr_access>

  <type init>         ::=    ``create'' <type identifier> ``(`` <args> ``)''
                             
  <func call>         ::=    ``call'' ( <identifier> | <anon func> ) ``(`` <args> ``)''

  <anon func>         ::=    ``|'' <params> ``|'' <expr> ``|''

  <method call>       ::=    ``call'' ( <expr> | <type identifier> )
                             ( ``.'' <identifier> ``(`` <args> ``)'' ) +
  
  <list>              ::=    ``[`` <args> ``]''                        

  <params>            ::=    <identifier> { <params> } |
                             empty

  <param>             ::=    ``,'' <identifier>		     

  <args>              ::=    <expr> { <arg> } |
                             empty

  <arg>               ::=    ``,'' <expr>

  <dict>              ::=    ``{`` <dict entries> ``}''

  <dict entries>      ::=    <expr> ``:'' <expr> { <dict entry> } |
                             empty

  <dict entry>        ::=    ``,'' <expr> ``:'' <expr>
  
  <constant>          ::=    /[A-Z]{2}[A-Z_0-9]*\b/
                            
  <type identifier>   ::=    /[A-Z][\w_]*/
  
  <identifier>        ::=    /[a-z][\w_]*/

  <number>            ::=    /[0-9]+/ | /[0-9]+\.[0-9]+/

  <text>              ::=    /"(?:\\.|[^\\"])*"/

  <bool>              ::=    ``True'' | ``False''                          

  <null>              ::=    ``Null''

  <comment>           ::=    ``#'' /.*/ ``\n'' | ``$'' /[.*|\n]*/ ``$''
```
