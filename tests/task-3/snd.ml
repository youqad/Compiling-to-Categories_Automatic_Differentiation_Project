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
let f = C.(
compose (ok_pair ok_float ok_float) (ok_pair ok_float ok_float) ok_float (exr ok_float ok_float)
  (id (ok_pair ok_float ok_float))
)
end
