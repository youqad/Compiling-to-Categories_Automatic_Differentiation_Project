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
let apply = C.(
exr (ok_arrow ok_float ok_float) ok_float (exr (ok_arrow ok_float ok_float) ok_float)
  (exr (ok_arrow ok_float ok_float) ok_float (exr (ok_arrow ok_float ok_float) ok_float))
  (exr (ok_arrow ok_float ok_float) ok_float (exr (ok_arrow ok_float ok_float) ok_float)
    (exr (ok_arrow ok_float ok_float) ok_float (exr (ok_arrow ok_float ok_float) ok_float)))
  (exr (ok_arrow ok_float ok_float) ok_float (exr (ok_arrow ok_float ok_float) ok_float)
    (exr (ok_arrow ok_float ok_float) ok_float (exr (ok_arrow ok_float ok_float) ok_float))
    (exr (ok_arrow ok_float ok_float) ok_float (exr (ok_arrow ok_float ok_float) ok_float)
      (exr (ok_arrow ok_float ok_float) ok_float (exr (ok_arrow ok_float ok_float) ok_float))))
  (exr (ok_arrow ok_float ok_float) ok_float (exr (ok_arrow ok_float ok_float) ok_float)
    (exr (ok_arrow ok_float ok_float) ok_float (exr (ok_arrow ok_float ok_float) ok_float))
    (exr (ok_arrow ok_float ok_float) ok_float (exr (ok_arrow ok_float ok_float) ok_float)
      (exr (ok_arrow ok_float ok_float) ok_float (exr (ok_arrow ok_float ok_float) ok_float)))
    (exr (ok_arrow ok_float ok_float) ok_float (exr (ok_arrow ok_float ok_float) ok_float)
      (exr (ok_arrow ok_float ok_float) ok_float (exr (ok_arrow ok_float ok_float) ok_float))
      (exr (ok_arrow ok_float ok_float) ok_float (exr (ok_arrow ok_float ok_float) ok_float)
        (exr (ok_arrow ok_float ok_float) ok_float (exr (ok_arrow ok_float ok_float) ok_float)))))
)
end
