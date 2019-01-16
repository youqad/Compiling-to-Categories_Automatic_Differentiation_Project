let (compose : (float -> float) -> (float -> float) -> float -> float) =
    fun (f : float -> float) ->
    fun (g : float -> float) ->
    fun (x : float) ->
    f (g x)