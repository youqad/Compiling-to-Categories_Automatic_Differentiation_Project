include Floating.Make (Category.FloatLambdaCat)

let tests =
  assert (cossin 0.5 = cos 0.5 *. sin 0.5)
