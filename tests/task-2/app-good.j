let (apply : (float -> float) -> float -> float) =
  fun (f : float -> float) -> fun (x : float) -> f (x)