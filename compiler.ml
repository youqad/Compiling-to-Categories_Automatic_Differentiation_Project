open Source
open Target
open Typechecker

let ( @ ) combinator1 combinator2 = App (combinator1, combinator2)

let rec ok_type = function  
   | TyConstant TyFloat -> OkFloat
   | TyArrow (input, ouput) -> OkArrow (ok_type input, ok_type ouput)
   | TyPair (lhs, rhs) -> OkPair (ok_type lhs, ok_type rhs)

(** left comb tree data type to encode the [ok] properties of the input type *)
type leaf
type node
type node_arrow
type node_pair

type _ ok_input_tree = 
   | Leaf : identifier * ok -> leaf ok_input_tree
   | Node : _ ok_input_tree * ok * leaf ok_input_tree -> node ok_input_tree (*  left subtree * node label * right subtree  *)

(** right comb tree data type to encode the [ok] properties of the output type *)
type _ ok_output_tree =
   | Leaf : ok -> leaf ok_output_tree
   | Node_arrow : leaf ok_output_tree * ok * _ ok_output_tree -> node_arrow ok_output_tree
   | Node_pair : _ ok_output_tree * ok * _ ok_output_tree -> node_pair ok_output_tree

(** existential_wrapper *)
type wrapped_ok_tree = Wrap : _ ok_output_tree -> wrapped_ok_tree


let ok_input_tree_add : type a. a ok_input_tree -> identifier * ok -> node ok_input_tree =
   fun ok_input (id, ok) -> match ok_input with
   | Leaf (id1, ok1) as l -> Node (l, OkPair (ok1, ok), Leaf (id, ok))
   | Node (_, ok1, _) as n ->  Node (n, OkPair (ok1, ok), Leaf (id, ok))

let ok_input_tree_get_ok : type a. a ok_input_tree -> ok =
   fun ok_output -> match ok_output with
   | Leaf (_, ok) -> ok
   | Node (_, ok, _) -> ok

let ok_output_tree_add : type a. a ok_output_tree -> ok -> node_arrow ok_output_tree =
   fun ok_output ok -> match ok_output with
   | Leaf ok1 as l -> Node_arrow (Leaf ok, OkArrow (ok, ok1), l)
   | Node_arrow (_, ok1, _) as n ->  Node_arrow (Leaf ok, OkArrow (ok, ok1), n)
   | Node_pair (_, ok1, _) as n ->  Node_arrow (Leaf ok, OkArrow (ok, ok1), n)

   
let ok_output_tree_get_ok : type a. a ok_output_tree -> ok =
   fun ok_output -> match ok_output with
   | Leaf ok -> ok
   | Node_arrow (_, ok, _) -> ok
   | Node_pair (_, ok, _) -> ok


let rec get_variable_from_input_tree : type a. a ok_input_tree -> identifier -> t * ok = 
   fun ok_input id_x -> match ok_input with
   | Leaf (id, ok) -> Identity ok, ok
   | Node (Leaf (id1, ok1), _, Leaf (id2, ok2)) when id_x = id1 -> Exl (ok1, ok2), ok1 
   | Node (Leaf (id1, ok1), _, Leaf (id2, ok2)) when id_x = id2 -> Exr (ok1, ok2), ok2 
   | Node (Node (_, ok1, _), _, Leaf (id2, ok2)) when id_x = id2 -> Exr (ok1, ok2), ok2
   | Node (Node (_, ok1, _) as left_tree, ok, Leaf (_, ok2)) -> 
      let combinator, ok_var = get_variable_from_input_tree left_tree id_x in
      (Compose (ok, ok1, ok_var) @ combinator) @ Exl (ok1, ok2), ok_var
   | _ -> failwith "Variable not found in context."


let rec get_combinator_with_context : type a. a ok_input_tree -> term -> Target.t * ok =
   fun ok_input_tree term -> 
   let ok_input = ok_input_tree_get_ok ok_input_tree in
   match term with
   | Var (id_x) -> 
      let combinator, ok_x = get_variable_from_input_tree ok_input_tree id_x in
      combinator, ok_x
   | Literal (Float _ as l) -> 
      let unit_arrow_combinator = UnitArrow OkFloat @ Literal l in
      (Compose (ok_input, OkUnit, OkFloat) @ unit_arrow_combinator) @ It ok_input, 
      OkFloat
   | Primitive p -> 
      let constFun f ok_f_out = 
         let uncurried_combinator = (Compose (OkPair (ok_input, OkFloat), OkFloat, ok_f_out) @ f) @ Exr (ok_input, OkFloat) in
         Curry (ok_input, OkFloat, ok_f_out) @ uncurried_combinator in (
         match p with
         | Sin | Cos | Exp | Inv | Neg -> 
            constFun (Primitive p) OkFloat, 
            OkArrow (OkFloat, OkFloat)
         | Add | Mul -> 
            constFun (Curry (OkFloat, OkFloat, OkFloat) @ (Primitive p)) (OkArrow (OkFloat, OkFloat)), 
            OkArrow (OkFloat, OkArrow (OkFloat, OkFloat))
      )
   | App (a, b) -> 
      let comb_a, ok_a = get_combinator_with_context ok_input_tree a in
      let comb_b, ok_b = get_combinator_with_context ok_input_tree b in
      let ok_a_in, ok_a_out = (
         match ok_a with 
         | OkArrow (ok_in, ok_out) -> ok_in, ok_out
         | _ -> failwith "Typing error: a term which doesn't have application type is applied to another one"
         ) in
      assert (ok_a_in = ok_b);
      (Compose (ok_input, OkPair (ok_a, ok_b), ok_a_out) @ Apply (ok_a_in, ok_a_out)) @ ((Fork (ok_input, ok_a, ok_b) @ comb_a) @ comb_b), 
      ok_a_out
   |  Lam ((id_b, typ_b), t) ->
      let ok_typ_b = ok_type typ_b in
      let comb_t, ok_t = 
         get_combinator_with_context (ok_input_tree_add ok_input_tree (id_b, ok_typ_b)) t in
      Curry (ok_input, ok_typ_b, ok_t) @ comb_t, 
      OkArrow (ok_typ_b, ok_t)
   | Pair (a, b) -> 
      let comb_a, ok_a = get_combinator_with_context ok_input_tree a in
      let comb_b, ok_b = get_combinator_with_context ok_input_tree b in
      (Fork (ok_input, ok_a, ok_b) @ comb_a) @ comb_b, 
      OkPair (ok_a, ok_b)
   | Fst a ->
      let comb_a, ok_a = get_combinator_with_context ok_input_tree a in
      let ok_a_left, ok_a_right = (
         match ok_a with 
         | OkPair (ok_left, ok_right) -> ok_left, ok_right
         | _ -> failwith "Typing error: destructor Fst applied to a term that doesn't have pair type"
         ) in 
      (Compose (ok_input, ok_a, ok_a_left) @ Exl (ok_a_left, ok_a_right)) @ comb_a, 
      ok_a_left 
   | Snd a ->
      let comb_a, ok_a = get_combinator_with_context ok_input_tree a in
      let ok_a_left, ok_a_right = (
         match ok_a with 
         | OkPair (ok_left, ok_right) -> ok_left, ok_right        
         | _ -> failwith "Typing problem: destructor Snd applied to a term that don't have pair type"
         ) in 
      (Compose (ok_input, ok_a, ok_a_right) @ Exr (ok_a_left, ok_a_right)) @ comb_a,
      ok_a_right
  
let get_combinator_init  : term -> t = function
   | Lam ((id_b, typ_b), t) -> fst (get_combinator_with_context (Leaf (id_b, ok_type typ_b)) t)
   | _ as term -> failwith ("Error: term " ^ string_of_term term ^ " not  in eta-expanded form.")
  
type wrapped_input = Wrap : _ ok_input_tree -> wrapped_input
  
(** [source_to_categories translates a [source] in a [target] language
    made of categorical combinators. *)
let source_to_categories : Source.program -> Target.program =
   fun source ->
   fst (List.fold_left (
      fun (target_list, previous_bts_ok_tree) (b, t) -> 
         match t with
         | Lam ((id_x, typ_x), u) -> 
            let id_b, typ_b = b in
            let ok_b = ok_type typ_b in
            let ok_x = ok_type typ_x in (
            match previous_bts_ok_tree with 
            | None -> 
               let combinator, _ = get_combinator_with_context (Leaf (id_x, ok_x)) u in
               (b, combinator) :: target_list, Some (Wrap (Leaf (id_b, ok_b)))
            | Some (Wrap ok_input_tree) -> 
               let combinator, _ = 
                  get_combinator_with_context ok_input_tree t in
               (b, combinator) :: target_list, Some (Wrap (ok_input_tree_add ok_input_tree (id_b, ok_b)))
            )
         | _ -> failwith ("Error: term " ^ string_of_term t ^ " not  in eta-expanded form.")
      ) ([], None) source)