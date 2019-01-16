include Snd.Make (Category.FloatLambdaCat)

let tests =
  assert (snd (0., 1.) = 1.)
