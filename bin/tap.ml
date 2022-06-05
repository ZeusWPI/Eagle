open Utils

type api_endpoint = Profile

let print_profile t =
  Ocolor_format.printf "@{<bold;ul>   Tab profile info@}\n";
  let name = get_str "name" t
  and admin = get_bool "admin" t
  and orders_count = get_int "orders_count" t
  and is_private = get_bool "private" t
  and created_at = get_datetime "created_at" t
  and updated_at = get_datetime "updated_at" t in
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
  let* tap_token = get_env_opt_err "TAP_TOKEN" in
  let* tap_user = get_env_opt_err "TAP_USER" in
  Some (tap_token, tap_user)

let command_tap_profile () =
  let* tap_token, tap_user = get_tap_variables () in
  let* profile = fetch_api_tap Profile tap_token tap_user in
  print_profile profile;
  None
