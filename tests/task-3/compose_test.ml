include Compose.Make (Category.FloatLambdaCat)

let tests =
  assert (compose (fun x -> -.x) (fun x -> -.x) 1. = 1.)
