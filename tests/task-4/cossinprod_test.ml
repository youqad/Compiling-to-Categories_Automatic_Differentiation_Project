open DiffCat
include Cossinprod.Make (DiffCat)

let x = 37.
let y = 73.
let dx = epsilon
let dy = epsilon

let tests =
  print_float (epsilon_dapply sum (x, y) (dx, 0.)); print_newline ();
  print_float (-. sin (x *. y) *. y *. dx +. cos (x *. y) *. y *. dx);
  print_newline (); print_string "\n ----- \n"; print_newline ();
  print_float (epsilon_dapply sum (x, y) (0., dy)); print_newline ();
  print_float (-. sin (x *. y) *. x *. dy +. cos (x *. y) *. x *. dy);
  assert (epsilon_dapply sum (x, y) (dx, 0.) =
            -. sin (x *. y) *. y *. dx +. cos (x *. y) *. y *. dx);
  assert (epsilon_dapply sum (x, y) (0., dy) =
            -. sin (x *. y) *. x *. dy +. cos (x *. y) *. x *. dy)
