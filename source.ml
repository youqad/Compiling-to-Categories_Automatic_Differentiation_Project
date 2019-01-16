open Position

type program_with_locations =
  (binding located * term' located) list

and program =
  (binding * term) list

and 't t =
  | Var of identifier
  | App of 't * 't
  | Lam of binding * 't
  | Pair of 't * 't
  | Fst of 't
  | Snd of 't
  | Literal of literal
  | Primitive of primitive

and term' = term' Position.located t

and term = term t

and binding = identifier * typ

and typ =
  | TyConstant of type_constant
  | TyArrow of typ * typ
  | TyPair of typ * typ

and literal =
  | Float of float

and primitive =
  | Sin | Cos | Exp | Inv
  | Add | Mul | Neg

and type_constant =
  | TyFloat

and identifier = Id of string

and type_identifier = TyId of string

let rec map f = function
  | App (a, b) -> App (f (map f a), f (map f b))
  | Lam (b, t) -> Lam (b, f (map f t))
  | Pair (a, b) -> Pair (f a, f b)
  | Fst a -> Fst (f a)
  | Snd a -> Snd (f a)
  | Var x -> Var x
  | Literal l -> Literal l
  | Primitive p -> Primitive p

let make_lambda_abstraction_with_locations bs t =
  let rec aux = function
    | [] ->
       t
    | b :: bs ->
       let pos = Position.(join (position b) (position t)) in
       Position.with_pos pos (Lam (value b, aux bs))
  in
  aux bs

let make_lambda_abstraction bs t =
  Position.value (make_lambda_abstraction_with_locations bs t)

let make_let b t1 t2 =
  App (make_lambda_abstraction_with_locations [b] t2, t1)

let rec remove_locations = function
  | App (a, b) -> App (remove_locations' a, remove_locations' b)
  | Lam (b, t) -> Lam (b, remove_locations' t)
  | Pair (a, b) -> Pair (remove_locations' a, remove_locations' b)
  | Fst a -> Fst (remove_locations' a)
  | Snd a -> Snd (remove_locations' a)
  | Var x -> Var x
  | Literal l -> Literal l
  | Primitive p -> Primitive p

and remove_locations' t = remove_locations (Position.value t)

let remove_locations_in_program (p : program_with_locations) : program =
  List.map (fun (b, t) -> Position.(value b, remove_locations (value t))) p

let string_of_literal = function
  | Float f -> string_of_float f

let string_of_primitive = function
  | Sin -> "sin"
  | Cos -> "cos"
  | Exp -> "exp"
  | Inv -> "inv"
  | Add -> "add"
  | Mul -> "mul"
  | Neg -> "neg"

let string_of_term unbox =
PPrintEngine.(
    let rec term = function
      | Var (Id x) ->
         string x
      | Pair (a, b) ->
        PPrintCombinators.(
          parens (group (term' a ^^ comma) ^^ break 1 ^^ term' b)
        )
      | Snd a ->
         group (string "snd" ^^ break 1 ^^ term' a)
      | Fst a ->
         group (string "fst" ^^ break 1 ^^ term' a)
      | App (a, b) ->
         mayparen_term' a ^^ break 1 ^^ term' b
      | Lam (bs, t) ->
         string "fun " ^^ binding bs
         ^^ string " ->" ^^ break 1 ^^ term' t
      | Literal l ->
         string (string_of_literal l)
      | Primitive p ->
         string (string_of_primitive p)
    and term' t = term (unbox t)
    and mayparen_term' p =
      mayparen_term (unbox p)
    and mayparen_term t =
      match t with
      | Lam _ ->
         string "(" ^^ (term t) ^^ string ")"
      | _ ->
         term t
    and binding (Id x, _) =
        string x
    in
    fun t ->
    let b = Buffer.create 37 in
    PPrintEngine.ToBuffer.pretty 0.7 80 b (term t);
    Buffer.contents b
)

let string_of_term' = string_of_term Position.value

let string_of_term = string_of_term (fun x -> x)
