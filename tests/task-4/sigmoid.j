let (sigmoid : float -> float) =
    fun (x : float) ->
      inv (1 + exp (neg x))
