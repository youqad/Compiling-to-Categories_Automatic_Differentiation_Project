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
let incr = C.(
compose ok_float (ok_pair ok_float ok_float) ok_float addC
  (fork ok_float ok_float ok_float
    (compose ok_float ok_unit ok_float (unit_arrow ok_float 1.) (it ok_float))
    (id ok_float))
)
end
