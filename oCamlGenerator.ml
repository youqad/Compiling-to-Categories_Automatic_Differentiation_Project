open PPrintEngine
open Target

let string_of doc =
  let b = Buffer.create 31 in
  PPrintEngine.ToBuffer.pretty 0.8 120 b doc;
  Buffer.contents b

let h_term = Hashtbl.create 13
let h_ok = Hashtbl.create 13

let fresh_name =
  let r = ref 0 in
  fun () -> incr r; Printf.sprintf "t_%d" !r

let defs = ref []

let introduce_defs () =
  String.concat "\n"
    (List.rev_map
       (fun (x, d) -> Printf.sprintf "let %s = %s\n" x (string_of d))
       !defs)

let memogen h f =
  if not !Options.compact then f
  else fun x ->
  try
    Hashtbl.find h x
  with
  | Not_found ->
     let y = f x in
     let v = fresh_name () in
     defs := (v, y) :: !defs;
     Hashtbl.add h x (string v);
     string v

let string_of_term t =
  let rec term x = (memogen h_term @@ function
    | App (a, b) -> group (term a ^^ break 1 ^^ mayparen_term b)
    | t -> atom t) x
  and atom = function
    | Identity ok -> apply "id" [ok]
    | Curry (oka, okb, okc) -> apply "curry" [oka; okb; okc]
    | UnCurry (oka, okb, okc) -> apply "uncurry" [oka; okb; okc]
    | Apply (oka, okb) -> apply "apply" [oka; okb]
    | Fork (oka, okb, okc) -> apply "fork" [oka; okb; okc]
    | Exl (oka, okb) -> apply "exl" [oka; okb]
    | Exr (oka, okb) -> apply "exr" [oka; okb]
    | Compose (oka, okb, okc) -> apply "compose" [oka; okb; okc]
    | It ok -> apply "it" [ok]
    | UnitArrow ok -> apply "unit_arrow" [ok]
    | Literal l -> string (Source.string_of_literal l)
    | Primitive p -> string (primitive p)
    | _ -> assert false (* By definition of term. *)
  and mayparen_term = function
    | (Literal _ | Primitive _) as t -> term t
    | t -> PPrintCombinators.parens (nest 2 (term t))
  and apply id oks =
    if not !Options.without_oks then
      group (nest 2 (string id ^^ break 1
                     ^^ PPrintCombinators.separate_map (break 1) ok oks))
    else
      string id
  and primitive = Source.(function
    | Add -> "addC"
    | Mul -> "mulC"
    | Neg -> "negC"
    | Sin -> "sinC"
    | Cos -> "cosC"
    | Inv -> "invC"
    | Exp -> "expC"
   )
   and ok x = (memogen h_ok @@ function
    | OkFloat ->
       string "ok_float"
    | OkUnit ->
       string "ok_unit"
    | OkPair (ok1, ok2) ->
       group (PPrintCombinators.parens (
           string "ok_pair"
           ^^ break 1 ^^ ok ok1
           ^^ break 1 ^^ ok ok2
         ))
    | OkArrow (ok1, ok2) ->
       group (PPrintCombinators.parens (
           string "ok_arrow"
           ^^ break 1 ^^ ok ok1
           ^^ break 1 ^^ ok ok2
         ))) x
  in
  let b = Buffer.create 31 in
  PPrintEngine.ToBuffer.pretty 0.8 120 b (nest 2 (term t));
  Buffer.contents b

let string_of_definition ((Source.Id x, _), t) =
  Printf.sprintf "let %s = C.(\n%s\n)" x (string_of_term t)

let string_of_program t =
  let defs = List.map string_of_definition t in
  introduce_defs ()
  ^ String.concat "\n" defs

let generate_functor filename target =
  let cout = open_out filename in
  Printf.fprintf cout "\
open Category
module Make (C : sig
  include CartesianClosedCat
  val ok_float: float ok
  include NumCat
  with type t := float
  with type ('a, 'b) k := ('a, 'b) k
  include FloatingCat
  with type t := float
  with type ('a, 'b) k := ('a, 'b) k
end) = \
struct
  include CartesianCatDerivedOperations (C)
  open C
%s
end
" (string_of_program target);
  close_out cout
