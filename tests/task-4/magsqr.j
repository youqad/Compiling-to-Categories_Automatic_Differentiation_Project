let (sqr : float -> float) =
   fun (x : float) ->
   x * x

let (magsqr : float * float -> float) =
   fun (p : float * float) ->
   let (a : float) = fst p in
   let (b : float) = snd p in
   sqr a + sqr b
