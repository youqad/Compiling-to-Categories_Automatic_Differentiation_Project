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
   failwith "Student! This is your job!"

let test =
  let training_set = [ (0., 1.), 0.; (1., 0.), 1. ] in
  let trained_net = train training_set in
  assert (eval_net trained_net training_set < acceptable_error)
