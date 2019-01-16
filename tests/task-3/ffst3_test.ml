include Ffst3.Make (Category.FloatLambdaCat)

let tests =
  assert (ffst 0. (fun x -> x) (0., 0.) = 0.)
