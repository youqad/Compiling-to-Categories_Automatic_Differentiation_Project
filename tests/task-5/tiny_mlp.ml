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
let t_1 = ok_float

let t_2 = (ok_pair t_1 t_1)

let t_3 = exr t_2 t_2

let t_4 = exr t_1 t_1

let t_5 = (ok_pair t_2 t_2)

let t_6 = compose t_5 t_2 t_1

let t_7 = t_6 (t_4)

let t_8 = t_7 (t_3)

let t_9 = exl t_2 t_2

let t_10 = t_7 (t_9)

let t_11 = fork t_5 t_1 t_1

let t_12 = t_11 (t_10)

let t_13 = t_12 (t_8)

let t_14 = mulC

let t_15 = t_6 t_14

let t_16 = t_15 (t_13)

let t_17 = exl t_1 t_1

let t_18 = t_6 (t_17)

let t_19 = t_18 (t_3)

let t_20 = t_18 (t_9)

let t_21 = t_11 (t_20)

let t_22 = t_21 (t_19)

let t_23 = t_15 (t_22)

let t_24 = t_11 (t_23)

let t_25 = t_24 (t_16)

let t_26 = addC

let t_27 = t_6 t_26

let t_28 = t_27 (t_25)

let t_29 = negC

let t_30 = compose t_5 t_1 t_1

let t_31 = t_30 t_29

let t_32 = t_31 (t_28)

let t_33 = expC

let t_34 = t_30 t_33

let t_35 = t_34 (t_32)

let t_36 = it t_5

let t_37 = 1.

let t_38 = unit_arrow t_1

let t_39 = t_38 t_37

let t_40 = ok_unit

let t_41 = compose t_5 t_40 t_1

let t_42 = t_41 (t_39)

let t_43 = t_42 (t_36)

let t_44 = t_11 (t_43)

let t_45 = t_44 (t_35)

let t_46 = t_27 (t_45)

let t_47 = invC

let t_48 = t_30 t_47

let t_49 = t_48 (t_46)

let t_50 = exr t_5 t_1

let t_51 = exl t_5 t_1

let t_52 = (ok_pair t_5 t_1)

let t_53 = compose t_52 t_5 t_2

let t_54 = t_53 (t_3)

let t_55 = t_54 (t_51)

let t_56 = compose t_52 t_2 t_1

let t_57 = t_56 (t_4)

let t_58 = t_57 (t_55)

let t_59 = t_53 (t_9)

let t_60 = t_59 (t_51)

let t_61 = t_57 (t_60)

let t_62 = fork t_52 t_1 t_1

let t_63 = t_62 (t_61)

let t_64 = t_63 (t_58)

let t_65 = t_56 t_14

let t_66 = t_65 (t_64)

let t_67 = t_56 (t_17)

let t_68 = t_67 (t_55)

let t_69 = t_67 (t_60)

let t_70 = t_62 (t_69)

let t_71 = t_70 (t_68)

let t_72 = t_65 (t_71)

let t_73 = t_62 (t_72)

let t_74 = t_73 (t_66)

let t_75 = t_56 t_26

let t_76 = t_75 (t_74)

let t_77 = compose t_52 t_1 t_1

let t_78 = t_77 t_29

let t_79 = t_78 (t_76)

let t_80 = t_77 t_33

let t_81 = t_80 (t_79)

let t_82 = it t_52

let t_83 = compose t_52 t_40 t_1

let t_84 = t_83 (t_39)

let t_85 = t_84 (t_82)

let t_86 = t_62 (t_85)

let t_87 = t_86 (t_81)

let t_88 = t_75 (t_87)

let t_89 = t_77 t_47

let t_90 = t_89 (t_88)

let t_91 = t_78 (t_90)

let t_92 = t_62 (t_91)

let t_93 = t_92 (t_50)

let t_94 = t_75 (t_93)

let t_95 = 0.5

let t_96 = t_38 t_95

let t_97 = t_83 (t_96)

let t_98 = t_97 (t_82)

let t_99 = t_62 (t_98)

let t_100 = t_99 (t_94)

let t_101 = t_65 (t_100)

let t_102 = t_62 (t_101)

let t_103 = t_102 (t_94)

let t_104 = t_65 (t_103)
let nn = C.(
t_49
)
let error = C.(
t_104
)
end
