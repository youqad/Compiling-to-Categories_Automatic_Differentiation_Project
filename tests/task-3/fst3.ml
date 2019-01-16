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
let fst = C.(
curry ok_float (ok_arrow ok_float ok_float) (ok_arrow (ok_pair ok_float ok_float) ok_float)
(curry (ok_pair ok_float (ok_arrow ok_float ok_float)) (ok_pair ok_float ok_float) ok_float
  (compose
      (ok_pair (ok_pair ok_float (ok_arrow ok_float ok_float)) (ok_pair ok_float ok_float))
      (ok_pair ok_float (ok_arrow ok_float ok_float))
      ok_float
    (compose (ok_pair ok_float (ok_arrow ok_float ok_float)) ok_float ok_float (id ok_float)
      (exl ok_float (ok_arrow ok_float ok_float)))
    (exl (ok_pair ok_float (ok_arrow ok_float ok_float)) (ok_pair ok_float ok_float))))
)
end
