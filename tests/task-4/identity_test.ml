open DiffCat
include Identity.Make (DiffCat)

let tests =
  assert (epsilon_dapply identity 2. epsilon = epsilon)
