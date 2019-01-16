(**

   This module introduces several categorical concepts and instances.

   In this module, we translate the type classes and type class
   instances of the following papers

      "The Simple Essence of Automatic Differentiation" (ICFP'2018)
      "Compiling to categories"                         (ICFP'2017)
      by Conal Elliot

   in OCaml using its module system.

*)

(**

   What is the idea of the encoding?

   We translate type classes as module types, type class instances
   as module definitions and dictionaries as modules. Functors naturally
   appear when an instance definition depends on another one.

   There is some freedom while translating type classes as modules.
   For instance, a type class inheritance relation like:

   class A => B where D

   can be translated by:

      module type B = sig
        include A
        D
      end

   or by:

      module type B = sig
        module A : A
        D
      end

   Since this development contains a long chain of concepts related
   by inheritance, we had preferred (when possible) the first kind
   of translation to reduce module nesting.

*)

(**

   What is challenging?

   The challenge is threefold:

   1. The inference engine of Haskell automatically elaborates the
   type class dictionaries the program needs given the methods it uses
   ; there is no such elaboration in OCaml. Therefore, we must
   elaborate these type class dictionaries by hand before turning them
   into modules. This is actually a good thing to help us understand
   precisely what is going on.

   2. Conal Eliott is using a notion of *constrained* type class.  A
   type class is constrained if it contains an associated constraint
   which must be satisfied to apply any method of this type
   class. (Typically, in the paper, this associated constraint help to
   restrict the types of objects valid for a given category.) We
   encode an associated constraint "Ok a" using a proof-term of the
   form "'a ok" which must be explicitly provided as an argument to
   the encoded method.

   3. For the sake of simplicity, the paper does not always provide
   the exact definitions that make the whole development work. For
   instance, the aforementioned associated constraint is not included
   in the initial definition of categories section 4.1 while it is
   actually needed to introduce the category of additive functions.
   Fortunately for you, we already solved this problem as the
   important definitions are given here with all the necessary
   details omitted in the paper. As a consequence, when the paper
   and the code disagree, give more credit to the code.

*)

(**

    What is your job here?

    1. Read the following papers:

      "The Simple Essence of Automatic Differentiation" (ICFP'2018)
      "Compiling to categories" (ICFP'2017)

      and optionally (but may be easier to start with):
      "Beautiful differentiation" (ICFP'2009)

    2. Complete the code by replacing 'failwith "Student! This is your job!"'
       or `todo` by the actual definition. While completing the code, we
       suggest you run `make -C tests/task-1` to get some feedback about
       your progress.

*)


(**

   A category comprises objects and morphisms.

   In this paper, the objects are the programming language types and
   the morphisms are the inhabitants of [('a, 'b) k].

   A category has a distinguised identity morphism named [id] as well
   as a composition operator. [compose] is associative and admits [id]
   as left and right neutral.

   As said earlier, we actually constrain the objects to be the types
   [a] that satisfy some constraint [C] over types. We encode this
   constraint using a type constructor named [ok], i.e [C (a)] is
   satisfied iff [a ok] is inhabited. We will usually assume that [ok]
   is stable by type applications (as witnessed by [ok_pair] and
   [ok_arrow] that will come in forthcoming definitions).

*)
module type Cat = sig

  type ('a, 'b) k

  type 'a ok

  val id: 'a ok -> ('a, 'a) k

  val compose: 'a ok -> 'b ok -> 'c ok ->
                ('b, 'c) k -> ('a, 'b) k -> ('a, 'c) k

end

(**

   An initial (or universal or coterminal) object [unit] of a category
   is such that for every object ['a] there is exactly one morphism
   [it] from [t] to ['a].

*)
module type HasInitialObject = sig
  type ('a, 'b) k
  type 'a ok
  val ti : 'a ok -> (unit, 'a) k
end

(**

   A terminal (or final) object [unit] of a category is such that for
   every object ['a] there is exactly one morphism [ti] from ['a] to
   [t].

*)
module type HasTerminalObject = sig
  type ('a, 'b) k
  type 'a ok
  val it : 'a ok -> ('a, unit) k
end

(**

    A unit arrow starts from the terminal object.

*)
module type HasConstantArrows = sig
  type ('a, 'b) k
  type 'a ok
  val unit_arrow : 'a ok -> 'a -> (unit, 'a) k
end

(**


*)


(**

   A monoidal category allows us to form morphisms between products.

   For the sake of simplicity and even though it restricts the
   generality of the definition, we do not introduce a new type
   constructor for products but we reuse instead the standard type
   constructor [*].

   Notice that we [include] the module type signature [Cat] in
   [MonoidalCat] to encode the fact that a [MonoidalCat] is a
   [Cat]. Notice also that we apply a destructive substitution of the
   form (... with type ('a, 'b) k := ...)  on the included signature
   to share the type constructor for morphisms between module type
   signatures.

*)
module type MonoidalCat = sig

  type ('a, 'b) k

  include Cat with type ('a, 'b) k := ('a, 'b) k

  val ok_pair: 'a ok -> 'b ok -> ('a * 'b) ok

  val pair : 'a ok -> 'b ok -> 'c ok -> 'd ok ->
             ('a, 'c) k -> ('b, 'd) k -> ('a * 'b, 'c * 'd) k
end

(**

   A cartesian category is a monoidal category whose product is
   categorical, that it is equipped with two projections [exl] and
   [exr] and verifies the universal property for products.

   A cartesian category has a terminal object. As before, we will
   reuse the type [unit] to denote all terminal objects, even though
   this restricts a bit the definition. We include in that definition
   the existence of "constant arrows".

   Finally, [dup] witnesses the fact that a cartesian category has
   diagonal maps. This operator allows for data duplication.

*)
module type CartesianCat = sig
  type ('a, 'b) k

  include MonoidalCat with type ('a, 'b) k := ('a, 'b) k

  val exl : 'a ok -> 'b ok -> ('a * 'b, 'a) k

  val exr : 'a ok -> 'b ok -> ('a * 'b, 'b) k

  val ok_unit : unit ok

  include HasTerminalObject
        with type ('a, 'b) k := ('a, 'b) k
        with type 'a ok := 'a ok

  include HasConstantArrows
        with type ('a, 'b) k := ('a, 'b) k
        with type 'a ok := 'a ok

  val dup : 'a ok -> ('a, 'a * 'a) k

end

(**

   A cartesian closed category is a cartesian category containing
   exponential objects with the operations [apply], [curry] and
   [uncurry].

   Once again, we reuse the arrow of OCaml to represent the
   exponential ['a -> 'b] of ['b] by ['a] even though the definition
   could be made more general.

   To handle constants, we require the presence of an initial object.

 *)

module type CartesianClosedCat = sig
  type ('a, 'b) k

  include CartesianCat with type ('a, 'b) k := ('a, 'b) k

  val ok_arrow: 'a ok -> 'b ok -> ('a -> 'b) ok

  val apply : 'a ok -> 'b ok ->
              (('a -> 'b) * 'a, 'b) k

  val curry : 'a ok -> 'b ok -> 'c ok ->
              ('a * 'b, 'c) k -> ('a, 'b -> 'c) k

  val uncurry : 'a ok -> 'b ok -> 'c ok ->
                ('a, 'b -> 'c) k -> ('a * 'b, 'c) k

end

(**

   Simply typed lambda-calculus is a Cartesian Closed Category.

*)
module LambdaCat
: CartesianClosedCat
       with type ('a, 'b) k = 'a -> 'b
       with type 'a ok = unit
= struct

  (** In STLC, the morphisms are the functions. *)
  type ('a, 'b) k = 'a -> 'b

  (** There is no restriction over the type of objects. *)
  type 'a ok = unit
  let ok_arrow () () = ()
  let ok_pair () () = ()

  (*-------------------------------------------------*)
  (* Question 1: Complete the following definitions. *)
  (*             Then, run `make -C tests/task-1`.   *)
  (*-------------------------------------------------*)

  let id () =
    (* <corrige> *)
    fun x -> x
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let compose () () () f g =
    (* <corrige> *)
    fun x -> f (g x)
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let pair () () () () f g =
    (* <corrige> *)
    fun (x, y) -> (f x, g y)
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let exl () () (x, y) =
    (* <corrige> *)
    x
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let exr () () (x, y) =
    (* <corrige> *)
    y
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let dup () x =
    (* <corrige> *)
    (x, x)
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let apply () () (f, x) =
    (* <corrige> *)
    f x
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let curry () () () f =
    (* <corrige> *)
    fun x y -> f (x, y)
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let uncurry () () () f =
    (* <corrige> *)
    fun (x, y) -> f x y
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  (** STLC has a terminal object. *)
  let it () x =
    (* <corrige> *)
    ()
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  (** STLC has constant arrows. *)
  let unit_arrow () x =
    (* <corrige> *)
    fun () -> x
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let ok_unit = ()

end

(** We will use composition in LambdaCat many times, hence we
   introduce an infix operator to write composition more concisely. *)
let ( ** ) f g = LambdaCat.compose () () () f g

(**

   A co-cartesian category is a monoidal category with
   a left-injection [inl], a right-injection [inr] and
   an operation [jam] which mirrors the duplication
   of cartesian categories.

   A co-cartesian category has an initial object.

*)
module type CoCartesianCat = sig

  type ('a, 'b) k

  include MonoidalCat with type ('a, 'b) k := ('a, 'b) k

  val inl : 'a ok -> 'b ok -> ('a, 'a * 'b) k

  val inr : 'a ok -> 'b ok -> ('b, 'a * 'b) k

  val jam : 'a ok -> ('a * 'a, 'a) k

  include HasInitialObject
          with type ('a, 'b) k := ('a, 'b) k
          with type 'a ok := 'a ok
end

(**

    The following set of derived operations over Cartesian
    and CoCartesian categories will be helpful.

*)
module CartesianCatDerivedOperations (C : CartesianCat) = struct

  let fork oka okc okd f g =
    C.(compose oka (ok_pair oka oka) (ok_pair okc okd)
         (pair oka oka okc okd f g) (dup oka)
    )

  let unfork oka okc okd h =
    C.((compose oka (ok_pair okc okd) okc (exl okc okd) h),
       (compose oka (ok_pair okc okd) okd (exr okc okd) h))

end

module CoCartesianCatDerivedOperations (C : CoCartesianCat) = struct

  let join oka okc okd (f, g) =
    C.(compose (ok_pair okc okd) (ok_pair oka oka) oka
           (jam oka) (pair okc okd oka oka f g))

  let unjoin oka okc okd h =
    C.((compose okc (ok_pair okc okd) oka h (inl okc okd)),
       (compose okd (ok_pair okc okd) oka h (inr okc okd)))

end

(**

   A type [t] is additive if there exists an addition over values of
   type [t] and a zero for this addition.

*)

module type Additive = sig
  type t
  val zero : t
  val add : t -> t -> t
end

(**

   Unit is additive.

*)
module AdditiveUnit
: Additive with type t = unit
= struct
  type t = unit
  let zero = ()
  let add () () = ()
end

(**

   Float is additive.

*)
module AdditiveFloat
: Additive with type t = float
= struct
  type t = float
  let zero = 0.
  let add x y = x +. y
end

(**

   If A and B are additive, so is A x B.

*)
module AdditivePair (AddA : Additive) (AddB : Additive)
: Additive with type t = AddA.t * AddB.t
= struct
  type t = AddA.t * AddB.t
  let zero = (AddA.zero, AddB.zero)
  let add x y = (AddA.add (fst x) (fst y), AddB.add (snd x) (snd y))
end

(**
    If A and B are additive then A -> B is additive too.

 *)
module AdditiveLambda (A : sig type t end) (AddB : Additive)
: Additive with type t = A.t -> AddB.t
= struct
  type t = A.t -> AddB.t
  let zero = fun x -> AddB.zero
  let add f g = fun x -> AddB.add (f x) (g x)
end

(**

    A function [f] is additive if [f (x + y) = f x + f y].

*)

type ('a, 'b) additive_function =
  AdditiveFun of ('a -> 'b)

(**

   Additive types naturally provide injection and jam.

   Notice the usage of first-class modules here: additive
   structures are passed as arguments to these functions.
   This flexibility is needed to define the next category.

*)

let inlF (type b) (module AddB : Additive with type t = b) =
  fun x -> (x, AddB.zero)

let inrF (type a) (module AddA : Additive with type t = a) =
  fun x -> (AddA.zero, x)

let jamF (type a) (module AddA : Additive with type t = a) =
  fun (x, y) -> AddA.add x y

(**

   Additive functions are a cartesian and co-cartesian category.

*)
module AdditiveFunctionsCat : sig
  type ('a, 'b) k = ('a, 'b) additive_function

  type 'a ok = (module Additive with type t = 'a)

  include CartesianCat
          with type ('a, 'b) k := ('a, 'b) k
          with type 'a ok := 'a ok

  include CoCartesianCat
          with type ('a, 'b) k := ('a, 'b) k
          with type 'a ok := 'a ok

  include CartesianClosedCat
          with type ('a, 'b) k := ('a, 'b) k
          with type 'a ok := 'a ok

end
= struct

  type ('a, 'b) k = ('a, 'b) additive_function

  type 'a ok = (module Additive with type t = 'a)

  (*-------------------------------------------------*)
  (* Question 2: Complete the following definitions. *)
  (*             Then, run `make -C tests/task-1`.   *)
  (*-------------------------------------------------*)

  let ok_pair (type a b) (oka : a ok) (okb : b ok) : (a * b) ok =
    (* <corrige> *)
    let module AddA = (val oka : Additive with type t = a) in
    let module AddB = (val okb : Additive with type t = b) in
    (module AdditivePair (AddA) (AddB))
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let id oka =
    (* <corrige> *)
    AdditiveFun (fun x -> x)
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let compose oka okb okc (AdditiveFun f) (AdditiveFun g) =
    (* <corrige> *)
    AdditiveFun (fun x -> f (g x))
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let pair oka okb okc okd (AdditiveFun f) (AdditiveFun g) =
    (* <corrige> *)
    AdditiveFun (fun (x, y) -> (f x, g y))
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let exl oka okb =
    (* <corrige> *)
    AdditiveFun fst
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let exr oka okb =
    (* <corrige> *)
    AdditiveFun snd
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let dup oka =
    (* <corrige> *)
    AdditiveFun (fun x -> (x, x))
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let inl (type a b) (oka : a ok) (okb : b ok) =
    (* <corrige> *)
    AdditiveFun (inlF okb)
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let inr (type a b) (oka : a ok) (okb : b ok) =
    (* <corrige> *)
    AdditiveFun (inrF oka)
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let jam (type a) (oka : a ok) =
    (* <corrige> *)
    AdditiveFun (jamF oka)
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let ti (type a) (module AddA : Additive with type t = a) =
    (* <corrige> *)
    AdditiveFun (fun () -> AddA.zero)
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let it (type a) (module AddA : Additive with type t = a) =
    (* <corrige> *)
    AdditiveFun (fun _ -> ())
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let unit_arrow (type a) (module AddA : Additive with type t = a) x =
    (* <corrige> *)
    AdditiveFun (fun () -> x)
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let ok_unit : unit ok =
    (* <corrige> *)
    (module AdditiveUnit)
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let apply oka okb =
    (* <corrige> *)
    AdditiveFun (fun (f, x) -> f x)
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let curry oka okb okc (AdditiveFun f) =
    (* <corrige> *)
    AdditiveFun (fun x -> fun y -> f (x, y))
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let uncurry oka okb okc (AdditiveFun f) =
    (* <corrige> *)
    AdditiveFun (fun (x, y) -> f x y)
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let ok_arrow (type a b) oka okb =
    (* <corrige> *)
    let module A = struct type t = a end in
    let module AddB = (val okb : Additive with type t = b) in
    (module AdditiveLambda (A) (AddB) : Additive with type t = a -> b)
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

end

(**

   Since we will differentiate numerical function, we need
   a type for numeric values.

*)
module type Num = sig
  type t
  val neg : t -> t
  val add : t -> t -> t
  val zero : t
  val mul : t -> t -> t
end

(**

   Float is a famous example of such a type.

*)
module NumFloat : Num with type t = float = struct
  type t = float
  let neg x = -.x
  let zero = 0.
  let add x y = x +. y
  let mul x y = x *. y
end

(**

   A category can be equipped with morphisms that denote numerical
   operations.

*)
module type NumCat = sig
  type ('a, 'b) k
  type t
  val negC : (t, t) k
  val addC : (t * t, t) k
  val mulC : (t * t, t) k
end

(**

   We also need some primitive numerical functions.

*)
module type Floating = sig
  type t
  val sin : t -> t
  val cos : t -> t
  val exp : t -> t
  val inv : t -> t
end

(**

   These primitive functions are builtin in OCaml.

*)
module FloatingFloat : Floating with type t = float
= struct
  type t = float
  let sin = Pervasives.sin
  let cos = Pervasives.cos
  let exp = Pervasives.exp
  let inv x = 1. /. x
end

(**

   Again, we transfer these primitive functions in
   the categorical world.

*)
module type FloatingCat = sig
  type ('a, 'b) k
  type t
  val sinC : (t, t) k
  val cosC : (t, t) k
  val expC : (t, t) k
  val invC : (t, t) k
end

(**

    Given a numerical type, LambdaCat can be extended with the
    morphisms for numerical operations.

*)
module LambdaNumCatFromNum (Num : Num)
       : NumCat
         with type ('a, 'b) k = 'a -> 'b
         with type t = Num.t
= struct
  type ('a, 'b) k = 'a -> 'b
  type t = Num.t
  let negC = Num.neg
  let addC = LambdaCat.uncurry () () () Num.add
  let mulC = LambdaCat.uncurry () () () Num.mul
end

(**

    Idem for additive functions.

*)
module AdditiveFunctionNumCatFromNum (Num : Num)
       : NumCat
       with type ('a, 'b) k = ('a, 'b) additive_function
       with type t = Num.t
= struct
  type ('a, 'b) k = ('a, 'b) additive_function
  type t = Num.t
  let negC = AdditiveFun Num.neg
  let addC = AdditiveFun (LambdaCat.uncurry () () () Num.add)
  let mulC = AdditiveFun (LambdaCat.uncurry () () () Num.mul)
end

module FloatLambdaCat = struct
  include LambdaCat
  let ok_float = ()
  include (LambdaNumCatFromNum (NumFloat) :
           NumCat
           with type ('a, 'b) k := ('a, 'b) k
           with type t = float)
  let cosC = FloatingFloat.cos
  let sinC = FloatingFloat.sin
  let expC = FloatingFloat.exp
  let invC = FloatingFloat.inv
end

(**

   A final notion: a category is scalable if for each
   scalar, there is a scaling morphism.

*)
module type Scalable = sig
  type ('a, 'b) k
  type t
  val scale : t -> (t, t) k
end

(**

   The category of additive functions is scalable.

 *)
module ScalableAdditiveFromNum (Num : Num)
: Scalable
       with type t = Num.t
       with type ('a, 'b) k = ('a, 'b) additive_function
= struct
  type ('a, 'b) k = ('a, 'b) additive_function
  type t = Num.t
  let scale x = AdditiveFun (fun dx -> Num.mul dx x)
end

(**

   The "good" categories for automatic differentiation are categories
   which are both cartesian and cocartesian. Let us introduce a
   module signature for them.

*)

module type GoodCat = sig
  include CartesianCat
  include CoCartesianCat
          with type ('a, 'b) k := ('a, 'b) k
          with type 'a ok := 'a ok
end

(**

   From a cartesian and cocartesian category C, we construct a
   cartesian and cocartesian category where morphisms are
   differentiable functions.

   Given an input [x], a differentiable function [f] not only produces
   an output [y] but also a derivative [df] of [f] which is represented
   by a morphism of C.

   As explained in the paper, a derivative of f is a linear map f'
   such that:

                   | f (x + ε) - (f x + f' x ε) |
             lim   —————————————————————————————– = 0
             ε→0              | ε |

   This definition is general enough to capture a notion of derivatives
   over higher-dimensional spaces, typically Rⁿ → Rᵐ.

*)
module DiffCat (C : GoodCat) :
sig

  type ('a, 'b) k = D of ('a -> ('b * ('a, 'b) C.k))

  type 'a ok = (module Additive with type t = 'a) * 'a C.ok

  val linearD : ('a -> 'b) -> ('a, 'b) C.k -> ('a, 'b) k

  include GoodCat
          with type ('a, 'b) k := ('a, 'b) k
          with type 'a ok := 'a ok

end
= struct

  type ('a, 'b) k = D of ('a -> ('b * ('a, 'b) C.k))

  let linearD f f' = D (fun x -> (f x, f'))

  type 'a ok = (module Additive with type t = 'a) * 'a C.ok

  (*-------------------------------------------------*)
  (* Question 3: Complete the following definitions. *)
  (*             Then, run `make -C tests/task-1`.   *)
  (*-------------------------------------------------*)

  let ok_pair (type a b) (oka : a ok) (okb : b ok) : (a * b) ok =
    (* <corrige> *)
    let module AddA = (val fst oka : Additive with type t = a) in
    let module AddB = (val fst okb : Additive with type t = b) in
    ((module AdditivePair (AddA) (AddB)), C.ok_pair (snd oka) (snd okb))
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let id oka =
    (* <corrige> *)
    linearD (fun x -> x) (C.id (snd oka))
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let compose oka okb okc (D g) (D f) =
    (* <corrige> *)
    D (fun x ->
        let y, f' = f x in
        let z, g' = g y in
        z, C.compose (snd oka) (snd okb) (snd okc) g' f')
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let pair
    : type a b c d.
      a ok -> b ok -> c ok -> d ok ->
      (a, c) k -> (b, d) k -> (a * b, c * d) k
    = fun oka okb okc okd (D f) (D g) ->
    (* <corrige> *)
    D (fun (a, b) ->
        let c, f' = f a in
        let d, g' = g b in
        ((c, d),
         C.pair (snd oka) (snd okb) (snd okc) (snd okd) f' g'))
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let exl oka okb =
    (* <corrige> *)
    linearD (LambdaCat.exl () ()) (C.exl (snd oka) (snd okb))
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let dup oka =
    (* <corrige> *)
    linearD (LambdaCat.dup ()) (C.dup (snd oka))
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let exr oka okb =
    (* <corrige> *)
    linearD (LambdaCat.exr () ()) (C.exr (snd oka) (snd okb))
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let inl oka okb =
    (* <corrige> *)
    linearD (inlF (fst okb)) (C.inl (snd oka) (snd okb))
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let inr oka okb =
    (* <corrige> *)
    linearD (inrF (fst oka)) (C.inr (snd oka) (snd okb))
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let jam oka =
    (* <corrige> *)
    linearD (jamF (fst oka)) (C.jam (snd oka))
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let ti (type a) (((module AddA), coka) : a ok) : (unit, a) k =
    (* <corrige> *)
    D (fun () -> (AddA.zero, C.ti coka))
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let it (type a) (oka : a ok) : (a, unit) k =
    (* <corrige> *)
    D (fun _ -> ((), C.it (snd oka)))
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

  let unit_arrow (type a) (oka : a ok) x : (unit, a) k =
    (* <corrige> *)
    D (fun () -> (x, C.ti (snd oka)))
    (* </corrige> *)
    (* <sujet>
    failwith "Student! This is your job!"
    </sujet> *)

   let ok_unit =
     ((module AdditiveUnit : Additive with type t = unit), C.ok_unit)

end

(**

   Automatic differentiation is usually applied to numerical
   functions. In that case, the category is typically extended with
   numerical primitives and a type [Num.t] for scalars.

*)
module type GoodScalableFloatingCat = sig
  include GoodCat
  module Num : Num
  include NumCat
          with type ('a, 'b) k := ('a, 'b) k
          with type t = Num.t
  include Scalable
          with type ('a, 'b) k := ('a, 'b) k
          with type t := Num.t
  val ok_t : t ok
end

(**

    Additive functions over floats are an example of such category.

*)
module GoodScalableFloatingAdditiveFunctionsCat
: GoodScalableFloatingCat
       with type ('a, 'b) k = ('a, 'b) AdditiveFunctionsCat.k
       with module Num = NumFloat
       with type 'a ok = 'a AdditiveFunctionsCat.ok
       with type t = NumFloat.t
= struct

  include AdditiveFunctionsCat

  module Num = NumFloat

  include (ScalableAdditiveFromNum(Num)
           : Scalable
           with type ('a, 'b) k := ('a, 'b) k
           with type t = NumFloat.t)

  include (AdditiveFunctionNumCatFromNum(Num)
           : NumCat
           with type ('a, 'b) k := ('a, 'b) k
           with type t := NumFloat.t)

  let ok_t : t ok = (module Num)

  let ok_unit : unit ok = (module AdditiveUnit)

end

(**

   Automatic differentiation for functions from float to float.

*)
module DiffNumCat
         (C : GoodScalableFloatingCat)
         (Floating : Floating with type t = C.t)
: sig

  type ('a, 'b) k = D of ('a -> ('b * ('a, 'b) C.k))

  type 'a ok = (module Additive with type t = 'a) * 'a C.ok

  val linearD : ('a -> 'b) -> ('a, 'b) C.k -> ('a, 'b) k

  include GoodCat
          with type ('a, 'b) k := ('a, 'b) k
          with type 'a ok := 'a ok

  include NumCat
          with type ('a, 'b) k := ('a, 'b) k
          with type t := C.t

  include FloatingCat
          with type ('a, 'b) k := ('a, 'b) k
          with type t := C.t

end
= struct

  include DiffCat (C)

  (* <corrige> *)
  module AFD = CoCartesianCatDerivedOperations (C)

  module SAF = C

  module ANC  = C

  module LNC  = LambdaNumCatFromNum (C.Num)
  (* </corrige> *)

  (*-------------------------------------------------*)
  (* Question 4: Complete the following definitions. *)
  (*             Then, run `make -C tests/task-1`.   *)
  (*-------------------------------------------------*)

  let todo = D (fun _ -> failwith "Students! This is your job!")

  let negC =
    (* <corrige> *)
    linearD LNC.negC ANC.negC
    (* </corrige> *)
    (* <sujet>
    todo
    </sujet> *)

  let addC =
    (* <corrige> *)
    linearD LNC.addC ANC.addC
    (* </corrige> *)
    (* <sujet>
    todo
    </sujet> *)

  let mulC =
    (* <corrige> *)
    D (fun (a, b) ->
          (C.Num.mul a b,
           AFD.join C.ok_t C.ok_t C.ok_t (SAF.scale b, SAF.scale a)))
    (* </corrige> *)
    (* <sujet>
    todo
    </sujet> *)

  let sinC =
    (* <corrige> *)
    D (fun a -> (Floating.sin a, SAF.scale (Floating.cos a)))
    (* </corrige> *)
    (* <sujet>
    todo
    </sujet> *)

  let cosC =
    (* <corrige> *)
    D (fun a -> (Floating.cos a, SAF.scale (C.Num.neg (Floating.sin a))))
    (* </corrige> *)
    (* <sujet>
    todo
    </sujet> *)

  let expC =
    (* <corrige> *)
    D (fun a ->
        let e = Floating.exp a in
        (e, SAF.scale e))
    (* </corrige> *)
    (* <sujet>
    todo
    </sujet> *)

  let invC =
    (* <corrige> *)
    D (fun a ->
        (Floating.inv a,
         SAF.scale (Floating.(C.Num.neg (inv (C.Num.mul a a))))))
    (* </corrige> *)
    (* <sujet>
    todo
    </sujet> *)

end

(**

   Forward-mode and reverse-mode are two specific strategies to
   automatically differentiate functions. Roughly speaking, automatic
   differentiation in forward mode applies the chain rule to
   "differentiate a function from its inputs to its outputs" while
   automatic differentiation in backward mode applies the chain rule
   to "differentiate a function from its outputs to its inputs".

   Backward mode is more efficient than forward mode when used on a
   function whose domain has a greater dimension than its
   codomain. Conversely, forward mode works better when the codomain
   has a greater dimension than its codomain.

   If you never have heard of reverse-mode differentiation before and
   to better grab the meaning of the previous paragraph, we strongly
   suggest that you study the following blog post:

   https://rufflewind.com/2016-12-30/reverse-mode-automatic-differentiation

   (Recompute the derivatives of z with respect to x and y using both
   forward mode and backward mode.)

   At the end of tutorial, the author explains how to use Wengert
   lists to implement reverse-mode. This technique is a bit
   complex. Interestingly, Conal Elliot shows that we can specialize
   the general differentiation method implemented in the previous
   module to follow a reverse-mode strategy: it is simply a matter of
   forcing all the compositions to be left-associated!

   Instead of constraining the programmer to only use left-associated
   composition, we could simply CPS-transform the program before
   differentiating it. In that project, we actually do not apply the
   CPS-translation to the program but on its categorical
   interpretation domain. We achieve the same result but we avoid
   all the troubles entailed by binders.

*)
module ContinuationCategoryTransformer
         (C : GoodCat)
         (R : sig type t val okr : t C.ok end)
: sig
  type ('a, 'b) k = Cont of (('b, R.t) C.k -> ('a, R.t) C.k)
  type 'a ok = 'a C.ok
  include GoodCat
          with type ('a, 'b) k := ('a, 'b) k
          with type 'a ok := 'a C.ok
  val cont : 'a C.ok -> 'b C.ok -> ('a, 'b) C.k -> ('a, 'b) k
end
= struct

  module AFD = CoCartesianCatDerivedOperations (C)

  type ('a, 'b) k = Cont of (('b, R.t) C.k -> ('a, R.t) C.k)

  let cont : 'a C.ok -> 'b C.ok -> ('a, 'b) C.k -> ('a, 'b) k = fun oka okb f ->
    Cont (fun g -> C.compose oka okb R.okr g f)

  type 'a ok = 'a C.ok

  let ok_pair = C.ok_pair

  (*-------------------------------------------------*)
  (* Question 5: Complete the following definitions. *)
  (*             Then, run `make -C tests/task-1`.   *)
  (*-------------------------------------------------*)

  let id oka =
    (* <corrige> *)
    Cont (LambdaCat.id ())
    (* </corrige> *)
    (* <sujet>
    failwith "Students! This is your job!"
    </sujet> *)

  let compose oka okb okc (Cont g) (Cont f) =
    (* <corrige> *)
    Cont (LambdaCat.compose () () () f g)
    (* </corrige> *)
    (* <sujet>
    failwith "Students! This is your job!"
    </sujet> *)

  let pair oka okb okc okd (Cont f) (Cont g) =
    (* <corrige> *)
    let t1 = AFD.unjoin R.okr okc okd in
    let t2 = LambdaCat.pair () () () () f g in
    let t3 = t2 ** t1 in
    let t4 = AFD.join R.okr oka okb in
    let t5 = t4 ** t3 in
    Cont t5
    (* </corrige> *)
    (* <sujet>
    failwith "Students! This is your job!"
    </sujet> *)

  let exl (type a b) (oka : a C.ok) (okb : b C.ok) : (a * b, a) k =
    (* <corrige> *)
    let zero : (b, R.t) C.k =
      C.compose okb C.ok_unit R.okr (C.ti R.okr) (C.it okb)
    in
    let inl : (a, R.t) C.k -> (a, R.t) C.k * (b, R.t) C.k =
      fun h -> (h, zero)
    in
    Cont ((AFD.join R.okr oka okb) ** inl)
    (* </corrige> *)
    (* <sujet>
    failwith "Students! This is your job!"
    </sujet> *)

  let exr (type a b) (oka : a C.ok) (okb : b C.ok) : (a * b, b) k =
    (* <corrige> *)
    let zero : (a, R.t) C.k =
      C.compose oka C.ok_unit R.okr (C.ti R.okr) (C.it oka)
    in
    let inr : (b, R.t) C.k -> (a, R.t) C.k * (b, R.t) C.k =
      fun h -> (zero, h)
    in
    Cont ((AFD.join R.okr oka okb) ** inr)
    (* </corrige> *)
    (* <sujet>
    failwith "Students! This is your job!"
    </sujet> *)

  let dup (type a) (oka : a C.ok) : (a, a * a) k =
    (* <corrige> *)
    let jam : (a, R.t) C.k * (a, R.t) C.k -> (a, R.t) C.k =
      fun (f, g) ->
      C.compose oka (C.ok_pair oka oka) R.okr
        (AFD.join R.okr oka oka (f, g))
        (C.dup oka)
    in
    Cont (jam ** (AFD.unjoin R.okr oka oka))
    (* </corrige> *)
    (* <sujet>
    failwith "Students! This is your job!"
    </sujet> *)

  let inl (type a b) (oka : a C.ok) (okb : b C.ok) : (a, a * b) k =
    (* <corrige> *)
    Cont ((LambdaCat.exl () ()) ** (AFD.unjoin R.okr oka okb))
    (* </corrige> *)
    (* <sujet>
    failwith "Students! This is your job!"
    </sujet> *)

  let inr (type a b) (oka : a C.ok) (okb : b C.ok) : (b, a * b) k =
    (* <corrige> *)
    Cont ((LambdaCat.exr () ()) ** (AFD.unjoin R.okr oka okb))
    (* </corrige> *)
    (* <sujet>
    failwith "Students! This is your job!"
    </sujet> *)

  let jam (type a) (oka : a C.ok) : (a * a, a) k =
    (* <corrige> *)
    Cont ((AFD.join R.okr oka oka) ** (LambdaCat.dup ()))
    (* </corrige> *)
    (* <sujet>
    failwith "Students! This is your job!"
    </sujet> *)

  let ok_unit = C.ok_unit

  let ti oka =
    (* <corrige> *)
    Cont (fun f -> C.ti R.okr)
    (* </corrige> *)
    (* <sujet>
    failwith "Students! This is your job!"
    </sujet> *)

  let it oka =
    (* <corrige> *)
    Cont (fun f -> C.compose oka ok_unit R.okr f (C.it oka))
    (* </corrige> *)
    (* <sujet>
    failwith "Students! This is your job!"
    </sujet> *)

  let unit_arrow (type a) (oka : a ok) (x : a) : (unit, a) k =
    (* <corrige> *)
    Cont (fun f -> C.compose ok_unit oka R.okr f (C.unit_arrow oka x))
    (* </corrige> *)
    (* <sujet>
    failwith "Students! This is your job!"
    </sujet> *)

end

(**

    The good categories which are scalable can be CPS transformed
    into scalable categories.

*)
module ContinuationScalableCategoryTransformer
         (C : sig
            include GoodCat
            include Scalable with type ('a, 'b) k := ('a, 'b) k
            val ok_t : t ok
          end)
         (R : sig type t val okr : t C.ok end)
: sig
  type ('a, 'b) k = Cont of (('b, R.t) C.k -> ('a, R.t) C.k)
  type 'a ok = 'a C.ok
  include GoodCat
          with type ('a, 'b) k := ('a, 'b) k
          with type 'a ok := 'a C.ok
  val cont : 'a C.ok -> 'b C.ok -> ('a, 'b) C.k -> ('a, 'b) k
  type t = C.t
  val scale : t -> (t, t) k
end =
struct
  include ContinuationCategoryTransformer (C) (R)
  type t = C.t
  let scale s =
    (* <corrige> *)
    Cont (fun h -> C.compose C.ok_t C.ok_t R.okr h (C.scale s))
    (* </corrige> *)
    (* <sujet>
    failwith "Students! This is your job!"
    </sujet> *)
end

(**

   A good category to differentiate functions producing values of type
   [R.t] following a reverse-mode strategy can be built from the good
   category of scalable and additive functions.

*)
module GoodScalableFloatingAdditiveCPSFunctionsCat
         (R : sig
            type t
            val okr : t AdditiveFunctionsCat.ok
          end)
: sig
  type ('a, 'b) ck = ('a, 'b) GoodScalableFloatingAdditiveFunctionsCat.k
  type 'a cok = 'a GoodScalableFloatingAdditiveFunctionsCat.ok
  type ('a, 'b) k = Cont of (('b, R.t) ck -> ('a, R.t) ck)
  include (GoodScalableFloatingCat
           with type ('a, 'b) k := ('a, 'b) k
           with module Num = NumFloat
           with type 'a ok = 'a AdditiveFunctionsCat.ok)
  val cont : 'a cok -> 'b cok -> ('a, 'b) ck -> ('a, 'b) k
end
= struct

  module Num = NumFloat

  module GAF = GoodScalableFloatingAdditiveFunctionsCat

  type ('a, 'b) ck = ('a, 'b) GoodScalableFloatingAdditiveFunctionsCat.k

  type 'a cok = 'a GoodScalableFloatingAdditiveFunctionsCat.ok

  include ContinuationScalableCategoryTransformer (GAF) (R)

  let ok_t = GAF.ok_t

  let ok_tt = GAF.ok_pair ok_t ok_t

  let negC = cont ok_t ok_t GAF.negC

  let addC = cont ok_tt ok_t GAF.addC

  let mulC = cont ok_tt ok_t GAF.mulC

end
