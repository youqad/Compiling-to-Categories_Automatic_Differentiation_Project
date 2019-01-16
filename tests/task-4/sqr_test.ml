open DiffCat
include Sqr.Make (DiffCat)

let tests =
  let x = 37. in
  assert (epsilon_dapply sqr x epsilon = x *. epsilon *. 2.)
