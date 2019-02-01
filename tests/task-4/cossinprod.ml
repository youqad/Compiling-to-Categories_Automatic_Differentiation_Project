open Category
module Make (C : sig
  include CartesianClosedCat
  val ok_float: float ok
  include NumCat
  with type t := float
  with type ('a, 'b) k := ('a, 'b) k
  include FloatingCat
  with type t := float
  with type ('a, 'b) k := ('a, 'b) k
end) = struct
  include CartesianCatDerivedOperations (C)
  open C
let cossinprod = C.(
fork (ok_pair ok_float ok_float) ok_float ok_float
  (compose (ok_pair ok_float ok_float) ok_float ok_float cosC mulC)
  (compose (ok_pair ok_float ok_float) ok_float ok_float sinC mulC)
)
let sum = C.(
compose (ok_pair ok_float ok_float) (ok_pair ok_float ok_float) ok_float addC
  (fork (ok_pair ok_float ok_float) ok_float ok_float
    (compose (ok_pair ok_float ok_float) ok_float ok_float cosC mulC)
    (compose (ok_pair ok_float ok_float) ok_float ok_float sinC mulC))
)
end
