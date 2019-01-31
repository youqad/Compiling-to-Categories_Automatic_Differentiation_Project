open List
open Target 

exception Ill_formed_combinator

type intern_node
type seq

type _ flattened_composition =
  | Seq : ok * ok * (intern_node flattened_composition list) -> seq flattened_composition (*  ok input * ok output * (flattened_composition combinator list)  *)
  | Morph : ok * ok * morphism_t -> intern_node flattened_composition 
  | Appl : ok * ok * app_t -> intern_node flattened_composition 
and morphism_t =
  | Identity of ok
  | Apply of ok * ok
  | Exl of ok * ok
  | Exr of ok * ok
  | It of ok
  | UnitArrowLit of ok * Source.literal
  | Primitive of Source.primitive
and app_t =
  | Fork of ok * ok * ok * (seq flattened_composition) * (seq flattened_composition)
  | Curry of ok * ok * ok * (seq flattened_composition)
  | UnCurry of ok * ok * ok * (seq flattened_composition)

(** existential_wrapper *)
type wrapped_flattened = Wrap : _ flattened_composition -> wrapped_flattened

let get_oks : type a. a flattened_composition -> ok * ok = function
  | Seq (ok_in, ok_out, _) -> ok_in, ok_out
  | Morph (ok_in, ok_out, _) -> ok_in, ok_out
  | Appl (ok_in, ok_out, _) -> ok_in, ok_out

let rec flattened_from_combinator : Target.t -> seq flattened_composition = function
  | Identity ok -> Seq (ok, ok, [Morph (ok, ok, Identity ok)])
  | Apply (oka, okb) -> 
    let ok_in = OkPair (OkArrow (oka, okb), oka) in 
    Seq (ok_in, okb, [Morph (ok_in, okb, Apply (oka, okb))])
  | Exl (oka, okb) ->
    let ok_in = OkPair (oka, okb) in 
    Seq (ok_in, oka, [Morph (ok_in, oka, Exl (oka, okb))])
  | Exr (oka, okb) ->
    let ok_in = OkPair (oka, okb) in 
    Seq (ok_in, okb, [Morph (ok_in, okb, Exl (oka, okb))])
  | It ok -> Seq (ok, OkUnit, [Morph (ok, OkUnit, It ok)])
  | Primitive p -> (
      match p with
      | Sin | Cos | Exp | Inv | Neg -> Seq (OkFloat, OkFloat, [Morph (OkFloat, OkFloat, Primitive p)])
      | Add | Mul -> 
        let ok_in = OkArrow (OkFloat, OkFloat) in
        Seq (ok_in, OkFloat, [Morph (ok_in, OkFloat, Primitive p)])
    )
  | App (comb1, comb2) -> (
    (** 4 possbilities, of one of the forms: 
      - (Compose ++ _) ++ _ 
      - (Fork ++ _) ++ _ 
      - Curry ++ _ 
      - UnitArrow ++ (Literal _) 
    *)
    match comb1 with 
      | App (Compose (oka, okb, okc), comb1) -> 
        let Seq (ok1_in, ok1_out, seq1) = flattened_from_combinator comb1 in
        let Seq (ok2_in, ok2_out, seq2) = flattened_from_combinator comb2 in
        assert (oka = ok1_in); 
        assert (okb = ok1_out && okb = ok2_in); 
        assert (okc = ok2_out);
        Seq (oka, okc, seq1 @ seq2)
      | App (Fork (oka, okc, okd), comb1) -> 
        let Seq (ok1_in, ok1_out, _) as s1 = flattened_from_combinator comb1 in
        let Seq (ok2_in, ok2_out, _) as s2 = flattened_from_combinator comb2 in
        assert (oka = ok1_in && oka = ok2_in); 
        assert (okc = ok1_out); assert (okd = ok2_out);
        let fork = Fork (oka, okc, okd, s1, s2) in
        let ok_out = OkPair (okc, okd) in
        Seq (oka, ok_out, [Appl (oka, ok_out, fork)])
      | Curry (oka, okb, okc) -> 
        let Seq (ok2_in, ok2_out, _) as s2 = flattened_from_combinator comb2 in
        assert (OkPair(oka, okb) = ok2_in); assert (okc = ok2_out);
        let curry = Curry (oka, okb, okc, s2) in
        let ok_out = OkArrow (okb, okc) in
        Seq (oka, ok_out, [Appl (oka, ok_out, curry)])
      | UnCurry (oka, okb, okc) -> 
        let Seq (ok2_in, ok2_out, _) as s2 = flattened_from_combinator comb2 in
        assert (oka = ok2_in); assert (OkArrow (okb, okc) = ok2_out);
        let uncurry = UnCurry (oka, okb, okc, s2) in
        let ok_in = OkPair(oka, okb) in
        Seq (ok_in, okc, [Appl (ok_in, okc, uncurry)])
      | UnitArrow ok -> (
        match comb2 with 
        | Literal (Float _ as l) -> Seq (OkUnit, ok, [Morph (OkUnit, ok, UnitArrowLit (ok, l))])
        | _ -> raise Ill_formed_combinator
        )
      | _ -> raise Ill_formed_combinator
    )
  | _ -> raise Ill_formed_combinator


let rec apply_rewriting_rules_once (seq_list: intern_node flattened_composition list) =
  let apply_unary_rules_once = function
    | Appl (ok_in, ok_out, Fork (_, _, _, 
      Seq (_, _, [Morph (_, _, Exl (_, _))]),
      Seq (_, _, [Morph (_, _, Exr (_, _))]))) (** Exl Δ Exr = id *)
    | Appl (ok_in, ok_out, Curry (_, _, _, 
      Seq (_, _, [Morph (_, _, Apply (_, _))]))) (** Curry(apply) = id *) 
      -> 
      assert (ok_in = ok_out); 
      Some (Morph (ok_in, ok_in, Identity ok_in))
    | Morph (ok_in, OkUnit, _) as morph -> 
      let it = Morph (ok_in, OkUnit, It ok_in) in 
      if it = morph then None
      else Some it
    | _ -> None 
    in
  let apply_binary_rules_once morph1 morph2 = match morph1, morph2 with
    | f, Morph (_, _, Identity _)
    | Morph (_, _, Identity _), f -> 
      Some (Wrap f)
    | Morph (_, _, Exl (_, _)), Appl (_, _, Fork (_, _, _, seq, _)) -> 
      Some (Wrap seq)
    | Morph (_, _, Exr (_, _)), Appl (_, _, Fork (_, _, _, _, seq)) -> 
      Some (Wrap seq)
    | Appl (ok_in, ok_out, Fork (oka, okc, okd, seqf, seqg)), (Morph (okh_in, okh_out, _) as h) -> 
      let Seq (okf_in, okf_out, seqf_list) = seqf in
      let Seq (okg_in, okg_out, seqg_list) = seqg in
      let new_seqf = Seq (okh_in, okf_out, seqf_list @ [h]) in
      let new_seqg = Seq (okh_in, okg_out, seqg_list @ [h]) in
      assert (okh_out = oka && okh_out = ok_in && okh_out = okf_in && okh_out = okg_in); 
      Some (Wrap (Appl (okh_in, ok_out, Fork (okh_in, okc, okd, new_seqf, new_seqg)))) 
    | Morph (_, ok_out, Apply _), 
      Appl (ok_in, _, Fork (_, _, _, Seq (_, _, [Appl (_, _, Curry (_, _, _, seqf))]), seqg)) 
      ->
      let Seq (okf_in, okf_out, seqf_list) = seqf in
      let Seq (_, okg_out, _) = seqg in
      let fork_id_g = 
        Appl (ok_in, okf_in, Fork (ok_in, ok_in, okg_out, Seq (ok_in, ok_in, [Morph (ok_in, ok_in, Identity ok_in)]), seqg)) in
      Some (Wrap (Seq (ok_in, ok_out, seqf_list @ [fork_id_g])))
    | Appl (_, okcurry_out, Curry (_, okb, _, seqf)), (Morph (okg_in, okg_out, _) as g) -> 
      let Seq (okf_in, okf_out, seqf_list) = seqf in
      let okgExl_in = OkPair (okg_in, okb) in
      let seqgExl = Seq (okgExl_in, okg_out, [g; Morph (okgExl_in, okg_in, Exl (okg_in, okb))]) in
      let seqExr = Seq (okgExl_in, okb, [Morph (okgExl_in, okb, Exr (okg_in, okb))]) in
      let fork_gExl_Exr = 
        Appl (okgExl_in, okf_in, Fork (okgExl_in, okg_out, okb, seqgExl, seqExr)) in
      let seqf_fork_gExl_Exr = 
        Seq (okgExl_in, okf_out, seqf_list @ [fork_gExl_Exr]) in
      Some (Wrap (Appl (okg_in, okcurry_out, Curry (okg_in, okb, okf_out, seqf_fork_gExl_Exr))))
    | _ -> None
    in
  let seq_list_has_been_modified = ref false in
  let seq_list' = List.map (
    fun node -> 
      let node' = apply_unary_rules_once node in
      match node' with 
      | None -> node
      | Some node'' -> seq_list_has_been_modified := true; node''
    ) seq_list in
  match seq_list' with
  | [] | [_] -> if !seq_list_has_been_modified then Some seq_list' else None
  | h1 :: (h2 :: t as l) -> 
    let h' = apply_binary_rules_once h1 h2 in ( 
    match h' with
    | None -> let h2t' = apply_rewriting_rules_once l in (
      match h2t' with 
      | None -> None
      | Some t' -> Some (h1 :: t')
      )
    | Some (Wrap h') -> 
      let t' = apply_rewriting_rules_once t in
      let t'' = (match t' with None -> t | Some t'' -> t'') in (
      match h' with
      | Seq (_, _, seq_list) -> Some (seq_list @ t'')
      | Morph _ -> Some (h' :: t'')
      | Appl _  -> Some (h' :: t'')
      )
    )

let rec apply_rewriting_rules (seq: seq flattened_composition) = 
  let Seq (ok_in, ok_out, seq_list) = seq in
  let seq_list' =
  List.map (
    function
      | (Morph _) as node -> node
      | Appl (ok_in, ok_out, app_t) -> (
        match app_t with
        | Curry (oka, okb, okc, seq') -> 
          let new_seq' = apply_rewriting_rules seq' in 
          Appl (ok_in, ok_out, Curry (oka, okb, okc, new_seq'))
        | UnCurry (oka, okb, okc, seq') ->
          let new_seq' = apply_rewriting_rules seq' in 
          Appl (ok_in, ok_out, UnCurry (oka, okb, okc, new_seq'))
        | Fork (oka, okc, okd, seq', seq'') -> 
          let new_seq' = apply_rewriting_rules seq' in 
          let new_seq'' = apply_rewriting_rules seq'' in 
          Appl (ok_in, ok_out, Fork (oka, okc, okd, new_seq', new_seq''))
      ) 
  ) seq_list in
  let has_been_modified = ref true in 
  let seq_list_ref = ref seq_list' in
  while !has_been_modified do
    let new_seq_list = apply_rewriting_rules_once !seq_list_ref in (
      match new_seq_list with 
      | None -> has_been_modified := false
      | Some seq_list'' -> seq_list_ref := seq_list''
    )
  done; 
  Seq (ok_in, ok_out, !seq_list_ref)

let rec combinator_from_flattened : type a. a flattened_composition -> Target.t = function
  | Seq (ok_in, ok_out, seq_list) -> (
    match seq_list with
    | [] -> Identity ok_in
    | [node] -> combinator_from_flattened node
    | h1 :: t -> 
      let okh1_in, okh1_out = get_oks h1 in
      let h1_comb = combinator_from_flattened h1 in
      let t_comb = combinator_from_flattened (Seq (ok_in, okh1_in, t)) in
      assert (okh1_out = ok_out); 
      (Compose (ok_in, okh1_in, ok_out) ++ h1_comb) ++ t_comb
    )
  | Morph (ok_in, ok_out, morph) -> (
    match morph with
    | Identity ok -> Identity ok
    | Apply (oka, okb) -> Apply (oka, okb)
    | Exl (oka, okb) -> Exl (oka, okb)
    | Exr (oka, okb) -> Exr (oka, okb)
    | It ok -> It ok
    | UnitArrowLit (ok, lit) -> UnitArrow OkFloat ++ Literal lit
    | Primitive p -> Primitive p
    )
  | Appl (ok_in, ok_out, app) -> (
    match app with 
    | Fork (oka, okc, okd, seq1, seq2) -> 
      let okseq1_in, okseq1_out = get_oks seq1 in
      let okseq2_in, okseq2_out = get_oks seq2 in
      let seq1_comb = combinator_from_flattened seq1 in
      let seq2_comb = combinator_from_flattened seq2 in
      assert (oka = okseq1_in && oka = okseq2_in); 
      assert (okc = okseq1_out); assert (okd = okseq2_out);
      (Fork (oka, okc, okd) ++ seq1_comb) ++ seq2_comb 
    | Curry (oka, okb, okc, seq) -> 
      let okseq_in, okseq_out = get_oks seq in
      let seq_comb = combinator_from_flattened seq in
      assert (okseq_in = OkPair(oka, okb)); 
      assert (okseq_out = okc);
      Curry (oka, okb, okc) ++ seq_comb
    | UnCurry (oka, okb, okc, seq) -> 
      let okseq_in, okseq_out = get_oks seq in
      let seq_comb = combinator_from_flattened seq in
      assert (okseq_in = oka); 
      assert (okseq_out = OkArrow(okb, okc));
      UnCurry (oka, okb, okc) ++ seq_comb
    )


(** [rewrite defs] applies category laws to remove [apply] and [curry]
    from the compiled programs. *)
let rewrite : Target.program -> Target.program = fun defs ->
  if !Options.simplify then
    failwith "Student! This is your job!"
  else
    defs
