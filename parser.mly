%{ (* Emacs, use -*- tuareg -*- to open this file. *)

   open Source

   let parsing_error pos msg =
     Printf.eprintf "%s:\n  %s\n" (Position.string_of_pos pos) msg;
     exit 1

   let var_or_primitive = function
     | Id "cos" -> Primitive Cos
     | Id "sin" -> Primitive Sin
     | Id "exp" -> Primitive Exp
     | Id "inv" -> Primitive Inv
     | Id "neg" -> Primitive Neg
     | x -> Var x

   let last xs = List.(hd (rev xs))

   let rec tuple = function
     | [] -> assert false (* By syntax. *)
     | [x] -> x
     | x :: xs -> Position.(
         let pos = join (position x) (position (last xs)) in
         with_pos pos (Pair (tuple xs, x))
     )

   let tuple xs = tuple (List.rev xs)

%}

%token EOF
%token FUN LET IN FLOAT FST SND
%token ARROW LPAREN RPAREN COLON EQUAL COMMA
%token TIMES PLUS MINUS
%token<string> ID
%token<float> LFLOAT

%type<Source.term'> term
%start<Source.program_with_locations> program

%right ARROW IN
%left PLUS
%left TIMES

%%

program: a=definition* EOF
{
  a
}
| error {
  parsing_error (Position.lex_join $startpos $endpos) "Syntax error."
}

term: a=abstraction {
  a
}
| d=definition IN t=located(term)
{
  make_let (fst d) (snd d) t
}
| lhs=located(term) b=located(binop) rhs=located(term)
{
  let with_pos = Position.(with_pos (join (position lhs) (position b))) in
  let b = Position.(with_pos (position b) (Primitive (value b))) in
  App (with_pos (App (b, lhs)), rhs)
}
| t=simple_term
{
  t
}

simple_term:
  a=located(simple_term) b=located(atomic_term)
{
  App (a, b)
}
| FST a=located(atomic_term)
{
  Fst a
}
| SND a=located(atomic_term)
{
  Snd a
}
| m=located(MINUS) t=located(atomic_term)
{
  let with_pos = Position.(with_pos (position m)) in
  App (with_pos (Primitive Neg), t)
}
| a=atomic_term
{
  a
}

atomic_term:
x=identifier {
  var_or_primitive x
}
| l=literal {
  Literal l
}
| LPAREN ts=separated_nonempty_list(COMMA, located (term)) RPAREN {
  Position.value (tuple ts)
}

literal:
  f=LFLOAT
{
  Float f
}

%inline abstraction: FUN bs=located(binding)+ ARROW t=located(term)
{
  make_lambda_abstraction bs t
}

%inline definition: LET b=located(binding) EQUAL t=located(term)
{
  (b, t)
}
| LET x=located(identifier) arg=located(binding)
  COLON oty=typ
  EQUAL t=located(term)
{
  let pos = Position.position x in
  let x = Position.value x in
  let b = Position.with_pos pos (x, TyArrow (snd (Position.value arg), oty)) in
  (b, Position.(with_pos (position t) (make_lambda_abstraction [arg] t)))
}

%inline binop :
| PLUS  { Add }
| TIMES { Mul }

binding: LPAREN x=identifier COLON ty=typ RPAREN
{
  (x, ty)
}

identifier: x=ID
{
  Id x
}

typ: x=type_constant
{
  TyConstant x
}
| lhs=typ ARROW rhs=typ
{
  TyArrow (lhs, rhs)
}
| lhs=typ TIMES rhs=typ
{
  TyPair (lhs, rhs)
}
| LPAREN t=typ RPAREN
{
  t
}

type_constant:
  FLOAT
{
  TyFloat
}

%inline located(X): x=X {
  Position.with_poss $startpos $endpos x
}
