open Category
module GoodScalableFloatingAdditiveCPSNumFunctionsCat =
  GoodScalableFloatingAdditiveCPSFunctionsCat (
      struct
        type t = float
        let okr : t AdditiveFunctionsCat.ok = (module AdditiveFloat)
      end)

module C = GoodScalableFloatingAdditiveCPSNumFunctionsCat
module D = Category.DiffNumCat (C) (FloatingFloat)
include D

let ok_float : float ok = ((module AdditiveFloat), (module AdditiveFloat))

let undefined what =
  failwith (Printf.sprintf "%s is undefined in this category." what)

let curry _ = undefined "Curry"

let uncurry _ = undefined "Uncurry"

let apply _ = undefined "Apply"

let ok_arrow _ = undefined "ok_arrow"

let cokf : float C.cok = (module AdditiveFloat)

let cokff : (float * float) C.cok = C.ok_pair cokf cokf

let af_apply (AdditiveFun f, x) =
  f x

module A = GoodScalableFloatingAdditiveFunctionsCat

let caf_apply (C.Cont f, x) =
  af_apply (f (A.id cokf), x)

let epsilon_apply (D f, x) epsilon =
  let y, df = f x in
  (y, caf_apply (df, epsilon))

let epsilon_dapply (D f) x epsilon =
  snd (epsilon_apply (D f, x) epsilon)

let epsilon = 0.01
