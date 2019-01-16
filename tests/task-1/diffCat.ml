open Infratest
open Category

module D = Category.DiffCat (Category.AdditiveFunctionsCat)
open D

module AdditiveFloat = struct
  type t = float
  let zero = 0.
  let add = ( +. )
end

let okf : float ok = ((module AdditiveFloat), (module AdditiveFloat))
let okff : (float * float) ok = ok_pair okf okf

let epsilon = 0.01

let af_apply (AdditiveFun f, x) = f x

let apply (D f, x) =
  let y, df = f x in
  (y, af_apply (df, epsilon))

let dapply (D f, x) =
  snd (apply (D f, x))

let ( ** ) f g = compose okf okf okf f g
let ( *** ) f g = compose okf okff okf f g
let ( **** ) f g = compose okf okff okff f g
let id = id okf
let exl = exl okf okf
let exr = exr okf okf
let inl = inl okf okf
let inr = inr okf okf
let jam = jam okf
let pair = pair okf okf okf okf
let dup = dup okf

let const k = D (fun x -> k, AdditiveFun (fun _ -> 0.))

let f = const 1.
let g = id
let h = const 2.

let ( === ) f g x =
  apply (f, x) = apply (g, x)

let ( =^= ) f df x =
  abs_float (dapply (f, x) -. df x) < epsilon /. 10.

let ( @@ ) eq some_values =
  List.for_all eq some_values

let some_floats = [0.; -1.; 1.; 33.; 100.; 10000.]

let some_pairs = [(0., 0.); (1., 1.)]

let test () =

  subtitle "Question 3: Testing DiffCat";

  check "id is a left neutral of compose." (fun () ->

      (f ** id === f)

  @@ some_floats);

  check "id is a right neutral of compose." (fun () ->

      (id ** f === f)

  @@ some_floats);

  check "compose is associative." (fun () ->

      (f ** (g ** h) === (f ** g) ** h)

  @@ some_floats);

  check "exl is a left projection." (fun () ->

      (exl *** dup === id)

  @@ some_floats);

  check "exr is a right projection." (fun () ->

      (exr *** dup === id)

  @@ some_floats);

  check "exl ∘ pair f g ∘ dup = f." (fun () ->

      (exl *** pair f g **** dup === f)

  @@ some_floats);

  check "exr ∘ pair f g ∘ dup = g." (fun () ->

      (exr *** pair f g **** dup === g)

  @@ some_floats);

  check "exl ∘ inl = id." (fun () ->

      (exl *** inl === id)

  @@ some_floats);

  check "exr ∘ inr = id." (fun () ->

      (exr *** inr === id)

  @@ some_floats);

  check "Chain rule." (fun () ->
      (** D (g ** g) = fun x -> x +. 1. *)
      (g ** g =^= fun _ -> epsilon)
  @@ some_floats)
