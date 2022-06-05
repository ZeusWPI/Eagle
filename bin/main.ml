let available_commands = [ "tab t (transactions)"; "tab p (profile + balance)" ]

let print_possible_actions () =
  print_endline "Available commands: ";
  print_string " - ";
  print_endline (String.concat "\n - " available_commands)

let command_not_found () =
  print_endline "Err! Command not found";
  print_endline "";
  print_possible_actions ()

let process_command line =
  if line = "tab t" then Tab.command_tab_transactions ()
  else if line = "tab p" then Tab.command_tab_profile ()
  else command_not_found ()

let maybe_read_line () = try Some (read_line ()) with End_of_file -> None

let rec loop () =
  print_string "> ";
  match maybe_read_line () with
  | Some line ->
      print_endline "";
      process_command line;
      loop ()
  | None -> print_endline "Bye 👋"

let () =
  print_endline "Welcome to Eagle. The goto CLI tool for all your Zeus needs.";
  print_possible_actions ();
  loop ()
