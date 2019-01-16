let score = ref 0

let total = ref 0

let say status = Printf.printf "  - [%s] %s\n" status

let notices = ref []

let notice s =
  notices := (Printf.sprintf "   - %s\n" s) :: !notices

let show_notices () =
  List.iter (output_string stdout) !notices;
  notices := []

let count status what =
  say status what;
  show_notices ();
  incr total

let fail what = count "KO" what

let success what = count "OK" what; incr score

let title s = Printf.printf "* %s\n" s

let subtitle s = Printf.printf "** %s\n" s

let check what f =
  (try
     if f () then success else fail
   with _ -> fail) what

let show_score () =
  Printf.eprintf "** Score for this task: %d/%d\n" !score !total
