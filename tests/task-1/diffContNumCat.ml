open Infratest
open Category

module A = GoodScalableFloatingAdditiveFunctionsCat

module GoodScalableFloatingAdditiveCPSNumFunctionsCat =
  GoodScalableFloatingAdditiveCPSFunctionsCat (
      struct
        type t = float
        let okr : t AdditiveFunctionsCat.ok = (module AdditiveFloat)
      end)

module C = GoodScalableFloatingAdditiveCPSNumFunctionsCat
module D = Category.DiffNumCat (C) (FloatingFloat)
open D

let okf : float ok = ((module AdditiveFloat), (module AdditiveFloat))
let okff : (float * float) ok = ok_pair okf okf
let okffff = ok_pair okff okff

let cokf : float C.cok = (module AdditiveFloat)

let af_apply (AdditiveFun f, x) =
  f x

let caf_apply (C.Cont f, x) =
  af_apply (f (A.id cokf), x)

let apply (D f, x) epsilon =
  let y, df = f x in
  (y, caf_apply (df, epsilon))

let dapply (D f, x) epsilon =
  snd (apply (D f, x) epsilon)

let ( ** ) f g = compose okf okf okf f g
let ( *** ) f g = compose okf okff okf f g
let ( **** ) f g = compose okf okff okff f g
let ( ***** ) f g = compose okff okffff okff f g
let id = id okf
let exl = exl okf okf
let exr = exr okf okf
let inl = inl okf okf
let inr = inr okf okf
let jam = jam okf
let pair2 = pair okff okff okf okf
let pair = pair okf okf okf okf
let dup2 = dup okff
let dup = dup okf

let const k = D (fun x -> k, C.cont cokf cokf (AdditiveFun (fun _ -> 0.)))

let f = addC *** pair id (const 1.) **** dup

let g = mulC *** dup

let h = addC *** pair id (const (-5.)) **** dup

(** This is the function [λ(x, y). x * y + sin x]! *)
let z = compose okff okff okf addC
          ((pair2 (compose okff okf okf sinC exl) mulC) ***** dup2)

let epsilon = 0.1

let ( === ) f g x =
  apply (f, x) epsilon = apply (g, x) epsilon

let equal_float x y =
  x = y || (abs_float (x -. y) /. min x y < epsilon_float)

let equal_float' x y =
  x = y || (abs_float (x -. y) /. min x y < 0.000000001)

let ( =^= ) f df x =
  let dfx = dapply (f, x) epsilon in
  let dfx' = df x in
  let result = equal_float dfx dfx'  in
  if not result then
    notice (Printf.sprintf "Failure on %f: %f <> %f" x dfx dfx');
  result

let ( =^^= ) f df x =
  let dfx = dapply (f, x) epsilon in
  let dfx' = df x in
  let result = equal_float' dfx dfx'  in
  if not result then
    notice (Printf.sprintf "Failure on %f: %f <> %f" x dfx dfx');
  result

let ( @@ ) eq some_values =
  List.for_all eq some_values

let some_floats = [0.; -1.; 1.; 33.; 100.; 10000.]

let some_floats_sigmoid = [0.; -1.; 1.; 0.5; 0.3; 0.7; 0.8; 0.1; -0.4]


let some_pairs = [(0., 0.); (1., 1.)]

let sigmoid x dx =
  let s x = 1. /. (1. +. exp (-.x)) in
  dx *. s x *. (1. -. s x)

let test () =

  subtitle "Question 5: Testing Reverse-Mode differentiation";

  check "Derivative of x -> x + 1" (fun () ->
      (** D f = fun x -> epsilon *)
      (f =^= fun x -> epsilon)
  @@ some_floats);

  check "Derivative of x -> x * x" (fun () ->
      (** D g =  *)
      (     g =^= fun x -> epsilon *. x +. x *. epsilon)
  @@ some_floats);

  check "Derivative of x -> x * x + 1" (fun () ->
      (** D (f ** g) = *)
      (      f ** g =^= fun x -> epsilon *. x +. x *. epsilon)
  @@ some_floats);

  check "Derivative of neg" (fun () ->
      (** D (neg) = *)
      (      negC =^= fun x -> -. epsilon)
  @@ some_floats);

  check "Derivative of cos" (fun () ->
      (** D (cos) = *)
      (      cosC =^= fun x -> -.sin x *. epsilon)
  @@ some_floats);

  check "Derivative of sin" (fun () ->
      (** D (sin) = *)
      (      sinC =^= fun x -> cos x *. epsilon)
  @@ some_floats);

  check "Derivative of exp" (fun () ->
      (** D (exp) = *)
      (      expC =^= fun x -> exp x *. epsilon)
  @@ some_floats);

  check "Derivative of cos ∘ sin" (fun () ->
      (** D (cos ** sin) = *)
      (      cosC ** sinC =^= fun x -> -.sin (sin x) *. cos (x) *. epsilon)
  @@ some_floats);

  check "Derivative of λ(x, y). x * y + sin x" (fun () ->
      (** D (λ(x, y). x * y + sin x) = *)
      (fun ((x, y), (dx, dy)) ->
        snd (apply (z, (x, y)) (dx, dy)) =
          x *. dy +. y *. dx +. cos x *. dx
      ) @@
        [ ((1., 1.), (epsilon, epsilon));
          ((1., 1.), (epsilon, 0.));
          ((1., 1.), (0., epsilon));
          ((0., 1.), (epsilon, epsilon));
          ((0., 1.), (epsilon, 0.));
          ((0., 1.), (0., epsilon));
          ((1., 0.), (epsilon, epsilon));
          ((1., 0.), (epsilon, 0.));
          ((1., 0.), (0., epsilon))
        ]
  );
  check "Derivative of exp(-.) + 1" (fun () ->
      (** D (exp(-.) + 1) = *)
      (      addC *** pair (expC ** negC) (const 1.) **** dup 
              =^= fun x -> -. exp (-. x) *. epsilon)
      @@ some_floats);

  check "Derivative of Sigmoid: inv(exp(-.) + 1)" (fun () ->
  (** D (exp(-.) + 1) = *)
  (      invC ** (addC *** pair (expC ** negC) (const 1.) **** dup) 
          =^^= fun x -> sigmoid x epsilon)
  @@ some_floats_sigmoid);
  

