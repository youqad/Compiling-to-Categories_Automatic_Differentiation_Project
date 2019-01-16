include Cossinprod.Make (Category.FloatLambdaCat)

let tests =
  let ref_cossinprod (x, y) = let z = x *. y in (cos z, sin z) in
  assert (cossinprod (0.5, 0.5) = ref_cossinprod (0.5, 0.5))
