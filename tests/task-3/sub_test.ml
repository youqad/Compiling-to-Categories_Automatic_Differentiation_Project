include Sub.Make (Category.FloatLambdaCat)

let tests =
  assert (sub (1., 0.) = -.1.)
