let (sub : float * float -> float) =
    fun (p : float * float) ->
    let (x : float) = fst p in
    let (y : float) = snd p in
    -x + y