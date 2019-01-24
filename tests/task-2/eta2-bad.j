let (test : (float -> float -> (float -> float) -> float) -> float -> float -> (float -> float) -> float) = 
    fun (x : float -> float -> (float -> float) -> float) -> fun (y : float) -> x y
let (non_function: float * float * float) = (2.,3.,4.)