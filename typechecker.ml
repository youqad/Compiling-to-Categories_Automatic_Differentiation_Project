open PPrint
open Source


(** [type_error pos msg] reports a type error and exits. *)
let type_error pos msg =
  Printf.eprintf "%s:\n%s\n"
    (Position.string_of_pos pos)
    msg;
  exit 1

(** [string_of_type ty] returns a human readable representation of a type. *)
let string_of_type t =
  let rec ty = function
    | TyConstant TyFloat ->
       string "float"
    | TyArrow (input, output) ->
       group (mayparen_ty_under_arrow_lhs input) ^^ break 1
       ^^ string "->"
       ^^ break 1 ^^ (group (ty output))
    | TyPair (lhs, rhs) ->
       group (mayparen_ty_under_pair_lhs lhs) ^^ break 1
       ^^ string "* " ^^ group (mayparen_ty_under_pair_rhs rhs)
    and mayparen_ty_under_arrow_lhs = function
      | (TyArrow _) as t ->
         PPrintCombinators.parens (ty t)
      | t ->
         ty t
    and mayparen_ty_under_pair_lhs = function
      | (TyArrow _) as t ->
         PPrintCombinators.parens (ty t)
      | t ->
         ty t
    and mayparen_ty_under_pair_rhs = function
      | (TyArrow _ | TyPair _) as t ->
         PPrintCombinators.parens (ty t)
      | t ->
         ty t
  in
  let b = Buffer.create 13 in
  PPrintEngine.ToBuffer.pretty 0.8 80 b (group (ty t));
  Buffer.contents b

module Identifier = struct
   type t = identifier
   let compare id1 id2 = match id1, id2 with 
      | Id s1, Id s2 -> Pervasives.compare s1 s2
end

module IdMap = Map.Make(Identifier)

let start_err_msg = "Ill-typed term: "

let find_exn id contxt pos msg = match IdMap.find id contxt with
   | typ -> typ
   | exception Not_found -> type_error pos msg


(** [check_program source] returns [source] if it is well-typed or
   reports an error if it is not. *)
let check_program (source : program_with_locations) : program_with_locations =
   let msg_in_which_term top_level_term = match top_level_term with
   | None -> ""
   | Some t' -> "Inside \n" ^ (string_of_term' (Position.value t')) ^ "\n :: " in
   let err_msg ?top_level_term t' typ_t' str_typ_expected =  
      msg_in_which_term top_level_term ^ start_err_msg 
      ^ (string_of_term' (Position.value t'))
      ^ " has type " ^ (string_of_type typ_t') 
      ^ " instead of the expected type " ^ str_typ_expected in
   let err_msg_var ?top_level_term id_var = 
      msg_in_which_term top_level_term ^ start_err_msg 
      ^ " type of variable " ^ id_var ^ " not  specified" in
   let rec get_type ?top_level_term contxt (term: term' Position.located) =
      let get_type_rec = get_type ?top_level_term in
      let pos_term, val_term = Position.position term, Position.value term in
      match Position.value term with
      | Var ((Id id_x) as x) -> find_exn x contxt pos_term (err_msg_var ?top_level_term id_x)
      | Literal (Float _) -> TyConstant TyFloat
      | Primitive p -> ( let ty_float = TyConstant TyFloat in
         match p with
         | Sin | Cos | Exp | Inv | Neg -> TyArrow (ty_float, ty_float)
         | Add | Mul -> TyArrow (ty_float, TyArrow (ty_float, ty_float))
      )  
      | App (a, b) -> 
         let type_err = type_error pos_term in
         let typ_a = get_type_rec contxt a in
         let typ_b = get_type_rec contxt b in
         let typ_a_input, typ_a_output = (
            match typ_a with
            | TyArrow (a_in, a_out) -> a_in, a_out
            | _ -> 
               let str_expected_type = "(" ^ string_of_type typ_b ^ ") -> 'a" in
               type_err (err_msg ?top_level_term a typ_a str_expected_type)
         ) in
         if typ_a_input = typ_b then typ_a_output
         else type_err (err_msg ?top_level_term b typ_b (string_of_type typ_a_input))
      | Lam ((id_b, typ_b), t) -> 
         let new_contxt = IdMap.add id_b typ_b contxt in
         let typ_t = get_type_rec new_contxt t in 
         TyArrow (typ_b, typ_t)
      | Pair (a, b) -> TyPair (get_type_rec contxt a, get_type_rec contxt a)
      | Fst a -> 
         let type_err = type_error pos_term in
         let typ_a = get_type_rec contxt a in (
            match typ_a with
            | TyPair (a_left, _) -> a_left
            | _ ->
               let str_expected_type = "(" ^ string_of_type typ_a ^ ") * 'a" in
               type_err (err_msg ?top_level_term a typ_a str_expected_type)
         )
      | Snd a -> 
         let type_err = type_error pos_term in
         let typ_a = get_type_rec contxt a in (
            match typ_a with
            | TyPair (_, a_right) -> a_right
            | _ -> 
               let str_expected_type = "'a * (" ^ string_of_type typ_a ^ ")" in
               type_err (err_msg ?top_level_term a typ_a str_expected_type)
         )
   in let check_type ?top_level_term contxt (bt: (binding Position.located * term' Position.located)) =
      let b, t = bt in
      let typ_t = get_type ?top_level_term contxt t in
      let typ_expected = snd (Position.value b) in
      if typ_t = typ_expected then bt
      else type_error (Position.position b) (err_msg t typ_t (string_of_type typ_expected))
   in
   fst (List.fold_left (
      fun wt_bts bt -> let well_typed_bts_list, well_typed_bts_map = wt_bts in
         let b, t = bt in
         let _ = check_type ~top_level_term:t  well_typed_bts_map bt in
         let b_id, b_typ = Position.value b in
         bt :: well_typed_bts_list, IdMap.add b_id b_typ well_typed_bts_map
      ) ([], IdMap.empty) source)


(** [eta_expanse source] makes sure that only functions are defined at
    toplevel and turns them into eta-long forms if needed. *)
let eta_expanse : program_with_locations -> program_with_locations =
  fun source -> failwith "Student! This is your job!"

let program : program_with_locations -> program_with_locations = fun source ->
  let xsource = check_program source in
  if !Options.typecheck_only then exit 0;
  eta_expanse xsource
