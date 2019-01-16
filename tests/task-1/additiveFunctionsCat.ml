open Infratest
open Category
open Category.AdditiveFunctionsCat

module AdditiveInt = struct
  type t = int
  let zero = 0
  let add = ( + )
end

let oki : int ok = (module AdditiveInt)
let okii : (int * int) ok = ok_pair oki oki

let apply (AdditiveFun f, x) = f x
let ( ** ) f g = compose oki oki oki f g
let ( *** ) f g = compose oki okii oki f g
let ( **** ) f g = compose oki okii okii f g
let id = id oki
let exl = exl oki oki
let exr = exr oki oki
let inl = inl oki oki
let inr = inr oki oki
let jam = jam oki
let pair = pair oki oki oki oki
let dup = dup oki

let f = AdditiveFun succ
let g = AdditiveFun (fun x -> 2 * x)
let h = AdditiveFun pred
let f2 = AdditiveFun (fun (x, y) -> x + y)

let ( === ) f g x =
  apply (f, x) == apply (g, x)

let ( @@ ) eq some_values =
  List.for_all eq some_values

let some_integers = [0; -1; 1; 33]

let some_pairs = [(0, 0); (1, 1)]

let test () =

  subtitle "Question 2: Testing AdditiveFunctionsCat";

  check "id is a left neutral of compose." (fun () ->

      (f ** id === f)

  @@ some_integers);

  check "id is a right neutral of compose." (fun () ->

      (id ** f === f)

  @@ some_integers);

  check "compose is associative." (fun () ->

      (f ** (g ** h) === (f ** g) ** h)

  @@ some_integers);

  check "exl is a left projection." (fun () ->

      (exl *** dup === id)

  @@ some_integers);

  check "exr is a right projection." (fun () ->

      (exr *** dup === id)

  @@ some_integers);

  check "exl ∘ pair f g ∘ dup = f." (fun () ->

      (exl *** pair f g **** dup === f)

  @@ some_integers);

  check "exr ∘ pair f g ∘ dup = g." (fun () ->

      (exr *** pair f g **** dup === g)

  @@ some_integers);

  check "exl ∘ inl = id." (fun () ->

      (exl *** inl === id)

  @@ some_integers);

  check "exr ∘ inr = id." (fun () ->

      (exr *** inr === id)

  @@ some_integers)
