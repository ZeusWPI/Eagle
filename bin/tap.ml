open Utils

type api_endpoint = Profile

let print_profile t =
  Ocolor_format.printf "@{<bold;ul>   Tab profile info@}\n";
  let name = get_str "name" t in
  let admin = get_bool "admin" t in
  let orders_count = get_int "orders_count" t in
  let is_private = get_bool "private" t in
  let created_at = get_datetime "created_at" t in
  let updated_at = get_datetime "updated_at" t in
  Ocolor_format.printf "             Name : %s\n" name;
  Ocolor_format.printf "      Order count : %d\n" orders_count;
  Ocolor_format.printf
    "          Private : %B  (private accounts can not be seen on koelkast)\n"
    is_private;
  Ocolor_format.printf "            Admin : %B\n" admin;
  Ocolor_format.printf "       Created at : %s\n"
    (CalendarPrinter.to_string created_at);
  Ocolor_format.printf "       Updated at : %s\n"
    (CalendarPrinter.to_string updated_at);
  print_newline ()

let fetch_api_tap endpoint tap_token tap_user =
  let path = match endpoint with Profile -> "/users/" ^ tap_user ^ ".json" in
  Api.get_json ("https://tap.zeus.gent" ^ path) tap_token

let get_tap_variables () =
  match Sys.getenv_opt "TAP_TOKEN" with
  | Some tap_token -> (
      match Sys.getenv_opt "TAP_USER" with
      | Some tap_user -> Some (tap_token, tap_user)
      | None ->
          print_endline
            "No tap user found. Set the TAP_USER environment variable to use \
             this feature.";
          None)
  | None ->
      print_endline
        "No API token for tap found. Set the TAP_TOKEN environment variable to \
         use this feature.";
      None

let command_tap_profile () =
  match get_tap_variables () with
  | Some (tap_token, tap_user) -> (
      match Lwt_main.run (fetch_api_tap Profile tap_token tap_user) with
      | Some profile -> print_profile profile
      | None -> ())
  | None -> ()
