include Pair.Make (Category.FloatLambdaCat)

let tests =
  assert (f 0. = (0., 0.))
