open DiffCat
include Cossinprod.Make (DiffCat)

let x = 37.
let y = 73.
let dx = epsilon
let dy = epsilon

let epsilon_dapply_x = epsilon_dapply sum (x, y) (dx, 0.)

let epsilon_dapply_y = epsilon_dapply sum (x, y) (0., dy)


let tests =
  (* print_float (epsilon_dapply sum (x, y) (dx, 0.)); print_newline ();
  print_float (-. sin (x *. y) *. y *. dx +. cos (x *. y) *. y *. dx);
  print_newline (); print_string "\n ----- \n"; print_newline ();
  print_float (epsilon_dapply sum (x, y) (0., dy)); print_newline ();
  print_float (-. sin (x *. y) *. x *. dy +. cos (x *. y) *. x *. dy); *)
  assert (abs_float (epsilon_dapply_x -. (-. sin (x *. y) *. y *. dx +. cos (x *. y) *. y *. dx)) 
          < 0.0000001);
  assert (abs_float (epsilon_dapply_y -. (-. sin (x *. y) *. x *. dy +. cos (x *. y) *. x *. dy))
          < 0.0000001)
