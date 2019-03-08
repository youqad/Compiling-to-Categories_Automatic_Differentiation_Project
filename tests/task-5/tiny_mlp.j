
(*

  [nn ((x, y), (wxu, wyu))] returns the output [u] of the Multi-Layer Perceptron
  with inputs (x, y) and weights (wxu, wyu). [wxu] is the weight from [x] to
  [u] and [wyu] is the weigth from [y] to [u]. We suggest you use the sigmoid
  as activation function :

					   1
				 x ↦ ————————————–——
				       1 + e^{-x}

*)
let nn (p :
       (* inputs  *) (float * float) *
       (* weights *) (float * float))
       (* output  *) : float
=
   let (sigmoid : float -> float) =
    fun (x : float) ->
      inv (1 + exp (neg x)) in
   let (x : float) = fst (fst p) in
   let (y : float) = snd (fst p) in
   let (wxu : float) = fst (snd p) in
   let (wyu : float) = snd (snd p) in
   sigmoid (x * wxu + y * wyu)

(*

   For a given input, the [error] function evaluates the distance
   between the neural network output and the expected output.

*)
let error (p :
     (* inputs      *) (float * float) *
     (* weights     *) (float * float) *
     (* expectation *) float)
     : float
=
  let (xu : float) = snd p in
  let (u : float) = nn (fst p) in
  let (d : float) = -u + xu in
  0.5 * d * d

