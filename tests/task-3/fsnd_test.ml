include Fsnd.Make (Category.FloatLambdaCat)

let tests =
  assert (fsnd (fun x -> x) 0. = 0.)
