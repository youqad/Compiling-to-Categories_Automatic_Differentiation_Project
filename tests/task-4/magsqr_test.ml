open DiffCat
include Magsqr.Make (DiffCat)

let x = 37.

let y = 73.

let tests =
  assert (epsilon_dapply magsqr (x, y) (epsilon, 0.) = 2. *. epsilon *. x);
  assert (epsilon_dapply magsqr (x, y) (0., epsilon) = 2. *. epsilon *. y);
  assert (epsilon_dapply magsqr (x, y) (epsilon, epsilon) =
            2. *. epsilon *. x +. 2. *. epsilon *. y);
