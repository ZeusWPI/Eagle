open Lwt
open Cohttp
open Cohttp_lwt_unix


let available_commands = ["tab"; "tap"]

let tab_fetch_transactions =
  Client.get (Uri.of_string "https://www.reddit.com/") >>= fun (resp, body) ->
  let code = resp |> Response.status |> Code.code_of_status in
  Printf.printf "Response code: %d\n" code;
  Printf.printf "Headers: %s\n" (resp |> Response.headers |> Header.to_string);
  body |> Cohttp_lwt.Body.to_string >|= fun body ->
  Printf.printf "Body of length: %d\n" (String.length body);
  body


let command_tab () = 
  print_endline " -- TAB --";
  match Sys.getenv_opt("TAB_TOKEN") with
    | Some(tab_token) -> 
        let body = Lwt_main.run body in
          print_endline ("Received body\n" ^ body)
    | None -> print_endline "No API token for tab found. Set the TAB_TOKEN environment variable to use this feature."

let command_not_found () = 
  print_endline "Err! Command not found";
  print_endline "Available commands: ";
  print_string " - ";
  print_endline (String.concat "\n - " available_commands)

let process_command line = 
  if line = "tab" then command_tab ()
  else command_not_found ()

let maybe_read_line () =
  try Some(read_line())
  with End_of_file -> None

let rec loop () =
  print_string "> ";
  match maybe_read_line () with
  | Some(line) -> 
        process_command line;
        loop ();
  | None -> print_endline "Bye 👋"
  (* | None -> List.iter print_endline acc *)

let () = 
  print_endline "Welcome to Eagle. The goto CLI tool for all your Zeus needs.";
  loop ()

 (* print_endline "Hello, World!"

let quit_loop = ref false in
  while not !quit_loop do
    print_string "Have you had enough yet? (y/n) ";
    let str = read_line () in
      if str.[0] = 'y' then quit_loop := true
  done;;

let () = quit_loop *)