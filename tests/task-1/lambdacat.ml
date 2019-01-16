open Infratest
open Category.LambdaCat

let apply p = apply () () p
let curry f = curry () () () f
let uncurry f = uncurry () () () f
let ( ** ) f g = compose () () () f g
let id x = id () x
let exl p = exl () () p
let exr p = exr () () p
let pair x y = pair () () () () x y
let dup x = dup () x

let f = succ
let g = fun x -> 2 * x
let h = pred
let f2 (x, y) = x + y

let ( === ) f g x =
  apply (f, x) == apply (g, x)

let ( @@ ) eq some_values =
  List.for_all eq some_values

let some_integers = [0; -1; 1; 33]

let some_pairs = [(0, 0); (1, 1)]

let test () =

  subtitle "Question 1: Testing LambdaCat";

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

      (exl ** dup === id)

  @@ some_integers);

  check "exr is a right projection." (fun () ->

      (exr ** dup === id)

  @@ some_integers);

  check "exl ∘ pair f g ∘ dup = f." (fun () ->

      (exl ** pair f g ** dup === f)

  @@ some_integers);

  check "exr ∘ pair f g ∘ dup = g." (fun () ->

      (exr ** pair f g ** dup === g)

  @@ some_integers);

  check "apply (apply (curry f2, x), y) = apply (f2 (x, y))." (fun () ->
  (
      (fun (x, y) -> apply (apply (curry f2, x), y))
      ===
      (fun (x, y) -> apply (f2, (x, y)))
  )
  @@ some_pairs);

  check "apply (uncurry (curry f2), (x, y)) = apply (f2 (x, y))." (fun () ->
  (
      (fun (x, y) -> apply (uncurry (curry f2), (x, y)))
      ===
      (fun (x, y) -> apply (f2, (x, y)))
  )
  @@ some_pairs);
