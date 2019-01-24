let (test : (float -> float -> (float -> float) -> float) -> float -> float -> (float -> float) -> float) = 
    fun (x : float -> float -> (float -> float) -> float) -> fun (y : float) -> x y