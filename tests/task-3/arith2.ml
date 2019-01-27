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
compose ok_float (ok_pair (ok_arrow ok_float ok_float) ok_float) ok_float
  (apply ok_float ok_float)
  (fork ok_float (ok_arrow ok_float ok_float) ok_float
    (compose
        ok_float
        (ok_pair (ok_arrow ok_float (ok_arrow ok_float ok_float)) ok_float)
        (ok_arrow ok_float ok_float)
      (apply ok_float (ok_arrow ok_float ok_float))
      (fork ok_float (ok_arrow ok_float (ok_arrow ok_float ok_float)) ok_float
        (curry ok_float ok_float (ok_arrow ok_float ok_float)
          (compose (ok_pair ok_float ok_float) ok_float (ok_arrow ok_float ok_float)
            (curry ok_float ok_float ok_float mulC)
            (exr ok_float ok_float)))
        (id ok_float)))
    (id ok_float))
)
let mag_sqr = C.(
compose ok_float (ok_pair (ok_arrow ok_float ok_float) ok_float) ok_float
  (apply ok_float ok_float)
  (fork ok_float (ok_arrow ok_float ok_float) ok_float
    (compose
        ok_float
        (ok_pair (ok_arrow ok_float (ok_arrow ok_float ok_float)) ok_float)
        (ok_arrow ok_float ok_float)
      (apply ok_float (ok_arrow ok_float ok_float))
      (fork ok_float (ok_arrow ok_float (ok_arrow ok_float ok_float)) ok_float
        (curry ok_float ok_float (ok_arrow ok_float ok_float)
          (compose (ok_pair ok_float ok_float) ok_float (ok_arrow ok_float ok_float)
            (curry ok_float ok_float ok_float addC)
            (exr ok_float ok_float)))
        (compose ok_float (ok_pair (ok_arrow ok_float ok_float) ok_float) ok_float
          (apply ok_float ok_float)
          (fork ok_float (ok_arrow ok_float ok_float) ok_float
            (curry ok_float ok_float ok_float
              (compose (ok_pair ok_float ok_float) ok_float ok_float
                (compose ok_float (ok_pair (ok_arrow ok_float ok_float) ok_float) ok_float
                  (apply ok_float ok_float)
                  (fork ok_float (ok_arrow ok_float ok_float) ok_float
                    (compose
                        ok_float
                        (ok_pair (ok_arrow ok_float (ok_arrow ok_float ok_float)) ok_float)
                        (ok_arrow ok_float ok_float)
                      (apply ok_float (ok_arrow ok_float ok_float))
                      (fork ok_float (ok_arrow ok_float (ok_arrow ok_float ok_float)) ok_float
                        (curry ok_float ok_float (ok_arrow ok_float ok_float)
                          (compose (ok_pair ok_float ok_float) ok_float (ok_arrow ok_float ok_float)
                            (curry ok_float ok_float ok_float mulC)
                            (exr ok_float ok_float)))
                        (id ok_float)))
                    (id ok_float)))
                (exr ok_float ok_float)))
            (id ok_float)))))
    (compose ok_float (ok_pair (ok_arrow ok_float ok_float) ok_float) ok_float
      (apply ok_float ok_float)
      (fork ok_float (ok_arrow ok_float ok_float) ok_float
        (curry ok_float ok_float ok_float
          (compose (ok_pair ok_float ok_float) ok_float ok_float
            (compose ok_float (ok_pair (ok_arrow ok_float ok_float) ok_float) ok_float
              (apply ok_float ok_float)
              (fork ok_float (ok_arrow ok_float ok_float) ok_float
                (compose
                    ok_float
                    (ok_pair (ok_arrow ok_float (ok_arrow ok_float ok_float)) ok_float)
                    (ok_arrow ok_float ok_float)
                  (apply ok_float (ok_arrow ok_float ok_float))
                  (fork ok_float (ok_arrow ok_float (ok_arrow ok_float ok_float)) ok_float
                    (curry ok_float ok_float (ok_arrow ok_float ok_float)
                      (compose (ok_pair ok_float ok_float) ok_float (ok_arrow ok_float ok_float)
                        (curry ok_float ok_float ok_float mulC)
                        (exr ok_float ok_float)))
                    (id ok_float)))
                (id ok_float)))
            (exr ok_float ok_float)))
        (id ok_float))))
)
end
