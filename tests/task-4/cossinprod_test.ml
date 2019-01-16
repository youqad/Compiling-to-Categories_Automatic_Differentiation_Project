open DiffCat
include Cossinprod.Make (DiffCat)

let x = 37.
let y = 73.
let dx = epsilon
let dy = epsilon

let tests =
  assert (epsilon_dapply sum (x, y) (dx, 0.) =
            -. sin (x *. y) *. y *. dx +. cos (x *. y) *. y *. dx);
  assert (epsilon_dapply sum (x, y) (0., dy) =
            -. sin (x *. y) *. x *. dy +. cos (x *. y) *. x *. dy)
