open Source
open Target
open Typechecker

let ( @ ) combinator1 combinator1 = App (combinator1, combinator1)

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

let ok_intput_tree_get_ok : type a. a ok_input_tree -> ok =
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
      Compose (ok, ok1, ok_var) @ combinator @ Exl (ok1, ok2), ok_var
   | _ -> failwith "Variable not found in context."


let rec get_combinator_with_context : type a. a ok_input_tree -> term -> Target.t * (wrapped_ok_tree) =
   fun ok_input_tree term -> 
   let ok_input = ok_intput_tree_get_ok ok_input_tree in
   match term with
   | Var (id_x) -> 
      let combinator, ok_x = get_variable_from_input_tree ok_input_tree id_x in
      combinator, Wrap (Leaf ok_x)
   | Literal (Float _ as l) -> Literal l, Wrap (Leaf OkFloat)
   | Primitive p -> Primitive p, 
      (match p with
         | Sin | Cos | Exp | Inv | Neg -> Wrap (Leaf (OkArrow (OkFloat, OkFloat)))
         | Add | Mul -> Wrap (Leaf (OkArrow (OkFloat, OkArrow (OkFloat, OkFloat))))
      )
   | App (a, b) -> 
      let comb_a, Wrap ok_output_tree_a = get_combinator_with_context ok_input_tree a in
      let comb_b, Wrap ok_output_tree_b = get_combinator_with_context ok_input_tree b in
      let ok_b = ok_output_tree_get_ok ok_output_tree_b in 
      let ok_a, ok_a_in, ok_a_out, wrap_ok_a_out_tree = (
         match ok_output_tree_a with 
         | Node_arrow (Leaf ok_in, ok, out_tree) -> ok, ok_in, ok_output_tree_get_ok out_tree, Wrap out_tree 
         | Leaf (OkArrow (ok_in, ok_out) as ok) -> ok, ok_in, ok_out, Wrap (Leaf (ok_out))
         | _ -> failwith "Typing error: a term which doesn't have application type is applied to another one"
         ) in
      assert (ok_a_in = ok_b);
      Compose (ok_input, OkPair (ok_a, ok_b), ok_b) @ Apply (ok_a_in, ok_a_out) @ (Fork (ok_input, ok_a, ok_b) @ comb_a @ comb_b), wrap_ok_a_out_tree
   |  Lam ((id_b, typ_b), t) ->
      let ok_typ_b = ok_type typ_b in
      let comb_t, Wrap ok_output_tree_t = 
         get_combinator_with_context (ok_input_tree_add ok_input_tree (id_b, ok_typ_b)) t in
      let ok_t = ok_output_tree_get_ok ok_output_tree_t in 
      Curry (ok_input, ok_typ_b, ok_t) @ comb_t, 
      Wrap (ok_output_tree_add ok_output_tree_t ok_typ_b)
   | Pair (a, b) -> 
      let comb_a, Wrap ok_output_tree_a = get_combinator_with_context ok_input_tree a in
      let comb_b, Wrap ok_output_tree_b = get_combinator_with_context ok_input_tree b in
      let ok_a = ok_output_tree_get_ok ok_output_tree_a in 
      let ok_b = ok_output_tree_get_ok ok_output_tree_b in 
      Fork (ok_input, ok_a, ok_b) @ comb_a @ comb_b, 
      Wrap (Node_pair (ok_output_tree_a, OkPair (ok_a, ok_b), ok_output_tree_b))
   | Fst a ->
      let comb_a, Wrap ok_output_tree_a = get_combinator_with_context ok_input_tree a in
      let ok_a = ok_output_tree_get_ok ok_output_tree_a in 
      let ok_a_left, ok_a_right, wrap_ok_a_left = (
         match ok_output_tree_a with 
         | Node_pair (left_tree, ok, right_tree) -> ok_output_tree_get_ok left_tree, ok_output_tree_get_ok right_tree, Wrap left_tree
         | Leaf (OkPair (ok_left, ok_right)) -> ok_left, ok_right, Wrap (Leaf (ok_left))
         | _ -> failwith "Typing error: destructor Fst applied to a term that doesn't have pair type"
         ) in 
      Compose (ok_input, ok_a, ok_a_left) @ Exl (ok_a_left, ok_a_right) @ comb_a, 
      wrap_ok_a_left 
   | Snd a ->
      let comb_a, Wrap ok_output_tree_a = get_combinator_with_context ok_input_tree a in
      let ok_a = ok_output_tree_get_ok ok_output_tree_a in 
      let ok_a_left, ok_a_right, wrap_ok_a_right = (
         match ok_output_tree_a with 
         | Node_pair (left_tree, ok, right_tree) -> ok_output_tree_get_ok left_tree, ok_output_tree_get_ok right_tree, Wrap right_tree 
         | Leaf (OkPair (ok_left, ok_right)) -> ok_left, ok_right, Wrap (Leaf (ok_right))         
         | _ -> failwith "Typing problem: destructor Snd applied to a term that don't have pair type"
         ) in 
      Compose (ok_input, ok_a, ok_a_right) @ Exr (ok_a_left, ok_a_right) @ comb_a,
      wrap_ok_a_right
  
let get_combinator : term -> t = function
   | Lam ((id_b, typ_b), t) -> fst (get_combinator_with_context (Leaf (id_b, ok_type typ_b)) t)
   | _ as term -> failwith ("Error: term " ^ string_of_term term ^ " not  in eta-expanded form.")
  
(** [source_to_categories translates a [source] in a [target] language
    made of categorical combinators. *)
let source_to_categories : Source.program -> Target.program =
   List.map (fun (b,t) -> (b, get_combinator t))
