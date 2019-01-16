let (f : float -> float) =
  (fun (y : float) -> (fun (x : float) -> y) y)