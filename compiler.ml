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

type _ ok_input_tree = 
   | Leaf : identifier * ok -> leaf ok_input_tree
   | Node : _ ok_input_tree * ok * leaf ok_input_tree -> node ok_input_tree (*  left subtree * node label * right subtree  *)

(** right comb tree data type to encode the [ok] properties of the output type *)
type _ ok_output_tree =
   | Leaf : ok -> leaf ok_output_tree
   | Node : leaf ok_output_tree * ok * _ ok_output_tree -> node ok_output_tree

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

let ok_output_tree_add : type a. a ok_output_tree -> ok -> node ok_output_tree =
   fun ok_output ok -> match ok_output with
   | Leaf ok1 as l -> Node (Leaf ok, OkPair (ok1, ok), l)
   | Node (_, ok1, _) as n ->  Node (Leaf ok, OkArrow (ok1, ok), n)
   
let ok_output_tree_get_ok : type a. a ok_output_tree -> ok =
   fun ok_output -> match ok_output with
   | Leaf ok -> ok
   | Node (_, ok, _) -> ok


let rec get_variable_from_input_tree : type a. a ok_input_tree -> identifier -> t * ok = 
   fun ok_input id_x -> match ok_input with
   | Leaf (id, ok) -> Identity ok, ok
   | Node (Leaf (id1, ok1), _, Leaf (id2, ok2)) when id_x = id1 -> Exl (ok1, ok2), ok1 
   | Node (Leaf (id1, ok1), _, Leaf (id2, ok2)) when id_x = id2 -> Exr (ok1, ok2), ok2 
   | Node (Node (_, ok1, _), _, Leaf (id2, ok2)) when id_x = id2 -> Exr (ok1, ok2), ok2
   | Node (Node (_, ok1, _) as left_tree, _, Leaf (_, ok2)) -> 
      let combinator, ok_var = get_variable_from_input_tree left_tree id_x in
      combinator @ Exl (ok1, ok2), ok_var
   | _ -> failwith "Variable not found in context."


let check_program (source : program) : program =
   let rec get_combinator : type a. a ok_input_tree -> term -> Target.t * (wrapped_ok_tree) =
      fun ok_input_tree term -> 
      match term with
      | Var (id_x) -> 
         let combinator, ok_x = get_variable_from_input_tree ok_input_tree id_x in
         combinator, Wrap (Leaf ok_x)
      | Literal (Float _ as l) -> Literal l, Wrap (Leaf OkFloat)
      | Primitive p -> Primitive p, Wrap (Leaf (OkArrow (OkFloat, OkFloat)))
      | App (a, b) -> 
         let ok_input = ok_intput_tree_get_ok ok_input_tree in
         let comb_a, Wrap ok_output_tree_a = get_combinator ok_input_tree a in
         let comb_b, Wrap ok_output_tree_b = get_combinator ok_input_tree b in
         let ok_b = ok_output_tree_get_ok ok_output_tree_b in 
         let ok_a, ok_a_in, ok_a_out, wrap_ok_a_out_tree = (
            match ok_output_tree_a with 
            | Node (Leaf ok_in, ok, (Leaf ok_out as out_tree)) -> ok, ok_in, ok_out, Wrap out_tree 
            | Node (Leaf ok_in, ok, (Node(_, ok_out, _) as out_tree)) -> ok, ok_in, ok_out, Wrap out_tree
            | _ -> failwith "Typing problem: a term that don't have application type is applied to another one"
            ) in
         assert (ok_a_in = ok_b);
         Apply (ok_a_in, ok_a_out) @ (Fork (ok_input, ok_a, ok_b) @ comb_a @ comb_b), wrap_ok_a_out_tree
      |  Lam ((id_b, typ_b), t) ->
         let ok_input = ok_intput_tree_get_ok ok_input_tree in
         let ok_typ_b = ok_type typ_b in
         let comb_t, Wrap ok_output_tree_t = 
            get_combinator (ok_input_tree_add ok_input_tree (id_b, ok_typ_b)) t in
         let ok_t = ok_output_tree_get_ok ok_output_tree_t in 
         Curry (ok_input, ok_typ_b, ok_t) @ comb_t, Wrap (ok_output_tree_add ok_output_tree_t ok_typ_b)
      | _ -> failwith "test" in failwith "test"
      (* | Lam ((id_b, typ_b), t) -> 
         let new_contxt = IdMap.add id_b typ_b contxt in
         let typ_t = get_combinator_rec new_contxt t in 
         TyArrow (typ_b, typ_t)
      | Pair (a, b) -> TyPair (get_combinator_rec contxt a, get_combinator_rec contxt b)
      | Fst a -> 
         let type_err = type_error pos_term in
         let typ_a = get_combinator_rec contxt a in (
            match typ_a with
            | TyPair (a_left, _) -> a_left
            | _ ->
               let str_expected_type = "(" ^ string_of_type typ_a ^ ") * 'a" in
               type_err (err_msg ?toplevel_term' a typ_a str_expected_type)
         )
      | Snd a -> 
         let type_err = type_error pos_term in
         let typ_a = get_combinator_rec contxt a in (
            match typ_a with
            | TyPair (_, a_right) -> a_right
            | _ -> 
               let str_expected_type = "'a * (" ^ string_of_type typ_a ^ ")" in
               type_err (err_msg ?toplevel_term' a typ_a str_expected_type)
         )
   in let check_type ?toplevel_term' contxt (bt': (binding Position.located * term' Position.located)) =
      let b, t = bt' in
      let typ_expected = get_combinator ?toplevel_term' contxt t in
      let typ_t = snd (Position.value b) in
      if typ_t = typ_expected then bt'
      else type_error (Position.position b) (err_msg t typ_t (string_of_type typ_expected))

let rec term_to_categories (term: term) : t * ok =
   let (id_arg, typ_arg), body = 
      match term with
      | Lam ((id_b, typ_b), t) -> (id_b, typ_b), t
      | _ -> failwith ("Error: term " ^ string_of_term term ^ " not  in eta-expanded form.") *)


(** [source_to_categories translates a [source] in a [target] language
    made of categorical combinators. *)
let source_to_categories : Source.program -> Target.program = fun source ->
   failwith "Student! This is your job!"
