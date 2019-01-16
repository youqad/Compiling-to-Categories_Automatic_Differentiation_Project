let parse_input_source_file source_filename = Lexing.(
  let cin = open_in source_filename in
  let buf = Lexing.from_channel cin in
  buf.lex_curr_p <- { buf.lex_curr_p with  pos_fname = source_filename };
  Parser.program Lexer.token buf
)
