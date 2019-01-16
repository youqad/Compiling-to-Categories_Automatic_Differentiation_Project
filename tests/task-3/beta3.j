let (f : float -> float) =
  (fun (x : float) -> (fun (x : float) -> fun (y : float) -> y) x x)