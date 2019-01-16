let (ffst : float -> (float -> float) -> (float * float) -> float) =
    fun (x : float) ->
    fun (f : float -> float) ->
    fun (p : float * float) ->
    x