let empty = Toml.Types.Table.empty
let find = Toml.Types.Table.find
let string_of_location loc = loc.Toml.Parser.source
let config_path = XDGBaseDir.Config.user_dir () ^ "/eagle/config.toml"
let maybe_read_line () = try Some (read_line ()) with End_of_file -> None

let rec ask_key key =
  print_endline
    "Enter your TAB_TOKEN. This can be found on the website of the tab service \
     at https://tab.zeus.gent";
  print_string "> ";
  match maybe_read_line () with
  | Some line -> line
  | None ->
      print_endline "Invalid input";
      ask_key key

let ask_fill_in_config conf =
  match find (Toml.Min.key "TAB_USER") conf with
  | exception Not_found ->
      let answer = ask_key "TAB_USER" in
      print_endline answer;
      print_endline ""
  | Toml.Types.TString tab_user -> print_endline tab_user
  | _ -> print_endline "Invalid content under the TAB_USER key"

let load_config () =
  let result =
    try Toml.Parser.from_filename config_path
    with Sys_error _ ->
      print_endline @@ "No config found at: " ^ config_path;
      print_endline
        "Creating a new one. Please enter the info below to get started";
      print_endline "You can always leave something empty and fill it in later";
      (* print_endline "Error loading the config";
          print_endline explanation; *)
      `Ok empty
  in
  match result with
  | `Error (s, loc) ->
      print_endline @@ "Could not parse config file: " ^ s;
      print_endline @@ "  at location " ^ string_of_location loc
  | `Ok table ->
      print_endline @@ Toml.Printer.string_of_table table;
      ask_fill_in_config table
