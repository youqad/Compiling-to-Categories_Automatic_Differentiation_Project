open DiffCat
include Fsnd.Make (DiffCat)

let tests =
  assert (epsilon_dapply fsnd (0., 2.) (0., epsilon) = epsilon)
