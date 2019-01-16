let main =
     IO.parse_input_source_file (Options.get_source_file ())
  |> Typechecker.program
  |> Source.remove_locations_in_program
  |> Compiler.source_to_categories
  |> Simplifier.rewrite
  |> OCamlGenerator.generate_functor (Options.target_file ())
