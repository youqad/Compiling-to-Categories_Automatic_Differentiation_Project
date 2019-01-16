include Fst.Make (Category.FloatLambdaCat)

let tests =
  assert (fst (0., 1.) = 0.)
