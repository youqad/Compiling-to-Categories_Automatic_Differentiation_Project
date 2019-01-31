type program = (Source.binding * t) list

and t =
  | App of t * t
  | Identity of ok
  | Curry of ok * ok * ok
  | UnCurry of ok * ok * ok
  | Apply of ok * ok
  | Fork of ok * ok * ok
  | Exl of ok * ok
  | Exr of ok * ok
  | UnitArrow of ok
  | It of ok
  | Compose of ok * ok * ok
  | Literal of Source.literal
  | Primitive of Source.primitive
and ok =
  | OkFloat
  | OkUnit
  | OkPair of ok * ok
  | OkArrow of ok * ok

let ( ++ ) combinator1 combinator2 = App (combinator1, combinator2)

let string_of_ok t =
  let open PPrint in
  let rec ty = function
    | OkFloat ->
       string "float"
    | OkUnit ->
       string "unit"
    | OkArrow (input, output) ->
       group (mayparen_ty_under_arrow_lhs input) ^^ break 1
       ^^ string "->"
       ^^ break 1 ^^ (group (ty output))
    | OkPair (lhs, rhs) ->
       group (mayparen_ty_under_pair_lhs lhs) ^^ break 1
       ^^ string "* " ^^ group (mayparen_ty_under_pair_rhs rhs)
    and mayparen_ty_under_arrow_lhs = function
      | (OkArrow _) as t ->
         PPrintCombinators.parens (ty t)
      | t ->
         ty t
    and mayparen_ty_under_pair_lhs = function
      | (OkArrow _) as t ->
         PPrintCombinators.parens (ty t)
      | t ->
         ty t
    and mayparen_ty_under_pair_rhs = function
      | (OkArrow _ | OkPair _) as t ->
         PPrintCombinators.parens (ty t)
      | t ->
         ty t
  in
  let b = Buffer.create 13 in
  PPrintEngine.ToBuffer.pretty 0.8 80 b (group (ty t));
  Buffer.contents b
