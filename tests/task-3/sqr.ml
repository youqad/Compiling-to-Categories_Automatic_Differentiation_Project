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
let sqr = C.(
id ok_float (id ok_float) (id ok_float (id ok_float))
  (id ok_float (id ok_float) (id ok_float (id ok_float)))
  (id ok_float (id ok_float) (id ok_float (id ok_float))
    (id ok_float (id ok_float) (id ok_float (id ok_float))))
)
end
