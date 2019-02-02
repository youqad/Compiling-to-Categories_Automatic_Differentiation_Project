open DiffCat
include Sigmoid.Make (DiffCat)

let x = 2.

let dx = epsilon

let dsigmoid x dx =
  epsilon_dapply sigmoid x dx

let dsigmoid_ref x dx =
  let s x = 1. /. (1. +. exp (-.x)) in
  dx *. s x *. (1. -. s x)

let ( =?= ) x y =
  abs_float (x -. y) < epsilon_float

let tests =
  assert (dsigmoid x dx =?= dsigmoid_ref x dx)
