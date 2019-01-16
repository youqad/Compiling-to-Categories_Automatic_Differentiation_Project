let (cossinprod : float * float -> float * float) =
    fun (p : float * float) ->
    let (x : float) = fst p in
    let (y : float) = snd p in
    let (z : float) = x * y in
    (cos z, sin z)