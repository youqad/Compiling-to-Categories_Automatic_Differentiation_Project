open DiffCat
include Beta.Make (DiffCat)

let tests =
  assert (epsilon_dapply f 1. epsilon = epsilon)
