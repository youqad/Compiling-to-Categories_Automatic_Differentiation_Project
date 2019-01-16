include Pair2.Make (Category.FloatLambdaCat)

let tests =
  assert (f 0. = ((0., 0.), 0.))
