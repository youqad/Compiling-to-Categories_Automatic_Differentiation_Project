let main =
  Infratest.title
    "Task 1: Implementing Categories for Automatic Differentiation";
  Lambdacat.test ();
  AdditiveFunctionsCat.test ();
  DiffCat.test ();
  DiffNumCat.test ();
  DiffContNumCat.test ();
  Infratest.show_score ()
