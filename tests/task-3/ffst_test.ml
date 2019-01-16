include Ffst.Make (Category.FloatLambdaCat)

let tests =
  assert (ffst 0. (fun x -> x) = 0.)
