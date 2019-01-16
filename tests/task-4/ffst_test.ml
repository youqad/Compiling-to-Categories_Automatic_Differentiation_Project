open DiffCat
include Ffst.Make (DiffCat)

let tests =
  assert (epsilon_dapply ffst (0., 2.) (epsilon, 0.) = epsilon)
