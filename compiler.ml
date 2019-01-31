open Source
open Target
open Typechecker

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


let rec ok_type = function  
   | TyConstant TyFloat -> OkFloat
   | TyArrow (input, ouput) -> OkArrow (ok_type input, ok_type ouput)
   | TyPair (lhs, rhs) -> OkPair (ok_type lhs, ok_type rhs)

(** left comb tree data type to encode the [ok] properties of the input type *)
type leaf
type node

type _ ok_input_tree = 
   | Leaf : identifier * ok -> leaf ok_input_tree
   | Node : _ ok_input_tree * ok * leaf ok_input_tree -> node ok_input_tree (*  left subtree * node label * right subtree  *)

let ok_input_tree_add : type a. a ok_input_tree -> identifier * ok -> node ok_input_tree =
   fun ok_input (id, ok) -> match ok_input with
   | Leaf (id1, ok1) as l -> Node (l, OkPair (ok1, ok), Leaf (id, ok))
   | Node (_, ok1, _) as n ->  Node (n, OkPair (ok1, ok), Leaf (id, ok))

let ok_input_tree_get_ok : type a. a ok_input_tree -> ok =
   fun ok_output -> match ok_output with
   | Leaf (_, ok) -> ok
   | Node (_, ok, _) -> ok

let rec get_variable_from_input_tree : type a. a ok_input_tree -> identifier -> t * ok = 
   fun ok_input id_x -> match ok_input with
   | Leaf (id, ok) -> Identity ok, ok
   | Node (Leaf (id1, ok1), _, Leaf (id2, ok2)) when id_x = id1 -> Exl (ok1, ok2), ok1 
   | Node (Leaf (id1, ok1), _, Leaf (id2, ok2)) when id_x = id2 -> Exr (ok1, ok2), ok2 
   | Node (Node (_, ok1, _), _, Leaf (id2, ok2)) when id_x = id2 -> Exr (ok1, ok2), ok2
   | Node (Node (_, ok1, _) as left_tree, ok, Leaf (_, ok2)) -> 
      let combinator, ok_var = get_variable_from_input_tree left_tree id_x in
      (Compose (ok, ok1, ok_var) ++ combinator) ++ Exl (ok1, ok2), ok_var
   | _ -> failwith "Variable not found in context."


let rec get_combinator_with_context : type a. a ok_input_tree -> term -> (Target.t * ok) IdMap.t -> Target.t * ok =
   fun ok_input_tree term previous_terms_map -> 
   let ok_input = ok_input_tree_get_ok ok_input_tree in
   let constFun f ok_f_in ok_f_out = 
      let uncurried_combinator = (Compose (OkPair (ok_input, ok_f_in), ok_f_in, ok_f_out) ++ f) ++ Exr (ok_input, ok_f_in) in
      Curry (ok_input, ok_f_in, ok_f_out) ++ uncurried_combinator 
   in
   match term with
   | Var (id_x) -> (
      match IdMap.find id_x previous_terms_map with
      | combinator, ok -> (
         match ok with
         | OkArrow(ok_in, ok_out) -> constFun combinator ok_in ok_out, ok
         | _ -> failwith ("Term " ^ string_of_term term ^ " should have an arrow type")
      )
      | exception Not_found -> 
         let combinator, ok_x = get_variable_from_input_tree ok_input_tree id_x in
         combinator, ok_x
   )
   | Literal (Float _ as l) -> 
      let unit_arrow_combinator = UnitArrow OkFloat ++ Literal l in
      (Compose (ok_input, OkUnit, OkFloat) ++ unit_arrow_combinator) ++ It ok_input, 
      OkFloat
   | Primitive p -> (
         match p with
         | Sin | Cos | Exp | Inv | Neg -> 
            constFun (Primitive p) OkFloat OkFloat, 
            OkArrow (OkFloat, OkFloat)
         | Add | Mul -> 
            constFun (Curry (OkFloat, OkFloat, OkFloat) ++ (Primitive p)) OkFloat (OkArrow (OkFloat, OkFloat)), 
            OkArrow (OkFloat, OkArrow (OkFloat, OkFloat))
      )
   | App (a, b) -> 
      let comb_a, ok_a = get_combinator_with_context ok_input_tree a previous_terms_map in
      let comb_b, ok_b = get_combinator_with_context ok_input_tree b previous_terms_map in
      let ok_a_in, ok_a_out = (
         match ok_a with 
         | OkArrow (ok_in, ok_out) -> ok_in, ok_out
         | _ -> 
            failwith ("Typing error: term a = " ^ string_of_term a ^ " (ok_a = " ^  string_of_ok ok_a ^ ") 
            which doesn't have application type is applied to b = " 
            ^ string_of_ok ok_b ^ " (ok_b = " ^ string_of_ok ok_b ^ ")")
         ) in
      assert (ok_a_in = ok_b);
      (Compose (ok_input, OkPair (ok_a, ok_b), ok_a_out) ++ Apply (ok_a_in, ok_a_out)) ++ ((Fork (ok_input, ok_a, ok_b) ++ comb_a) ++ comb_b), 
      ok_a_out
   |  Lam ((id_b, typ_b), t) ->
      let ok_typ_b = ok_type typ_b in
      let comb_t, ok_t = 
         get_combinator_with_context (ok_input_tree_add ok_input_tree (id_b, ok_typ_b)) t previous_terms_map in
      Curry (ok_input, ok_typ_b, ok_t) ++ comb_t, 
      OkArrow (ok_typ_b, ok_t)
   | Pair (a, b) -> 
      let comb_a, ok_a = get_combinator_with_context ok_input_tree a previous_terms_map in
      let comb_b, ok_b = get_combinator_with_context ok_input_tree b previous_terms_map in
      (Fork (ok_input, ok_a, ok_b) ++ comb_a) ++ comb_b, 
      OkPair (ok_a, ok_b)
   | Fst a ->
      let comb_a, ok_a = get_combinator_with_context ok_input_tree a previous_terms_map in
      let ok_a_left, ok_a_right = (
         match ok_a with 
         | OkPair (ok_left, ok_right) -> ok_left, ok_right
         | _ -> 
            failwith ("Typing error: destructor Fst applied to the term a = " 
            ^ string_of_term a ^ " (ok_a = " ^  string_of_ok ok_a ^ ") which doesn't have pair type")
         ) in 
      (Compose (ok_input, ok_a, ok_a_left) ++ Exl (ok_a_left, ok_a_right)) ++ comb_a, 
      ok_a_left 
   | Snd a ->
      let comb_a, ok_a = get_combinator_with_context ok_input_tree a previous_terms_map in
      let ok_a_left, ok_a_right = (
         match ok_a with 
         | OkPair (ok_left, ok_right) -> ok_left, ok_right        
         | _ -> 
            failwith ("Typing error: destructor Snd applied to the term a = " 
            ^ string_of_term a ^ " (ok_a = " ^  string_of_ok ok_a ^ ") which doesn't have pair type")
         ) in 
      (Compose (ok_input, ok_a, ok_a_right) ++ Exr (ok_a_left, ok_a_right)) ++ comb_a,
      ok_a_right

(** existential_wrapper *)
type wrapped_input = Wrap : _ ok_input_tree -> wrapped_input
  
(** [source_to_categories translates a [source] in a [target] language
    made of categorical combinators. *)
let source_to_categories : Source.program -> Target.program =
   fun source ->
   List.rev (fst (List.fold_left (
      fun (target_list, previous_terms_map) (b, t) -> 
         let id_b, typ_b = b in
         let ok_t = ok_type typ_b in
         match t with
         | Lam ((id_x, typ_x), u) -> 
            let ok_x = ok_type typ_x in 
            let combinator, _ = get_combinator_with_context (Leaf (id_x, ok_x)) u previous_terms_map in
               (b, combinator) :: target_list, 
               IdMap.add id_b (combinator, ok_t) previous_terms_map
         | _ -> failwith ("Error: term " ^ string_of_term t ^ " not  in eta-expanded form.")
      )
      ([], IdMap.empty) source))