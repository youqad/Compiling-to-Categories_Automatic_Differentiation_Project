(** We need to evaluate [error] defined in [tiny_mlp.j]... *)
module Eval = Tiny_mlp.Make (Category.FloatLambdaCat)
(** ... and we also need the derivative of [error]. *)
module Diff = Tiny_mlp.Make (DiffCat)

(** We study a very small MLP with two inputs, one output
    and no hidden layer. *)
type net = float * float

let make_net wxu wyu = (wxu, wyu)

let update_net (wxu, wyu) dwxu dwyu = make_net (wxu +. dwxu) (wyu +. dwyu)

(** A training set is a list of couples made of inputs and expected outputs. *)
type training_set = ((float * float) * float) list

(** A trained net must minimize the error function defined in tiny_mlp.j. *)
let acceptable_error = 0.01

let eval_net net training_set =
  List.map (fun (input, expectation) ->
      Eval.error ((input, net), expectation)
    ) training_set
  |> List.fold_left max min_float


(** [train training_set] returns a neural network trained for the
    [training_set]. *)
let train : training_set -> net = fun training_set ->
  let learn_rates = (0.1, 0.1) (** learning rates *) in
  let net = ref (make_net 0. 0.) in
  let open DiffCat in 
  while eval_net !net training_set >= acceptable_error do 
    (
      List.iter (fun (input, expectation) ->
      let dwxu = epsilon_dapply (Diff.error) 
        ((input, !net), expectation) (((0., 0.), (fst learn_rates, 0.)), 0.) in 
      let dwyu = epsilon_dapply (Diff.error) 
      ((input, !net), expectation) (((0., 0.), (0., snd learn_rates)), 0.) in 
      net := update_net !net (-.dwxu) (-.dwyu)
      ) training_set
    ) done;
  !net


let test =
  let training_set = [ (0., 1.), 0.; (1., 0.), 1. ] in
  let trained_net = train training_set in
  assert (eval_net trained_net training_set < acceptable_error);
  Printf.printf "Everything went well! 
  Here is the resulting MLP: (%f, %f)" (fst trained_net) (snd trained_net)
