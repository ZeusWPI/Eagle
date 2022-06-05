open Utils

let print_transactions ts tab_user =
  Ocolor_format.printf "@{<ul>@{<bold>   Tab transaction info@} (last 10)@}\n";
  let last10 = slice ts (List.length ts - 10) (List.length ts) in
  Format.open_vbox 2;
  Format.print_cut ();
  List.iter
    (fun t ->
      let debtor = get_str "debtor" t
      and creditor = get_str "creditor" t
      and issuer = get_str "issuer" t
      and amount = get_currency "amount" t
      and message = get_str "message" t
      and time = get_datetime "time" t in
      let color = if debtor = tab_user then "red" else "green" in
      Ocolor_format.printf
        "%8s sent @{<%s>€ %5.2f@} from %8s to %8s on the %s, saying: %s@,"
        issuer color amount debtor creditor
        (CalendarPrinter.to_string time)
        message)
    last10;
  Format.close_box ();
  print_newline ()

let print_profile t =
  Ocolor_format.printf "@{<bold;ul>   Tab profile info@}\n";
  let name = get_str "name" t
  and penning = get_bool "penning" t
  and balance = get_currency "balance" t
  and created_at = get_datetime "created_at" t
  and updated_at = get_datetime "updated_at" t in
  let color = if balance < 0. then "red" else "green" in
  Ocolor_format.printf "        Name : %s\n" name;
  Ocolor_format.printf "     Balance : @{<%s>€ %.2f@}\n" color balance;
  Ocolor_format.printf "     Penning : %B\n" penning;
  Ocolor_format.printf "  Created at : %s\n"
    (CalendarPrinter.to_string created_at);
  Ocolor_format.printf "  Updated at : %s\n"
    (CalendarPrinter.to_string updated_at);
  print_newline ()

type api_endpoint = Transactions | Profile

let fetch_api_tap endpoint tab_token tab_user =
  let path =
    match endpoint with
    | Transactions -> "/users/" ^ tab_user ^ "/transactions"
    | Profile -> "/users/" ^ tab_user
  in
  Api.get_json ("https://tab.zeus.gent/api/v1" ^ path) tab_token

let get_tab_variables () =
  let* tab_token = get_env_opt_err "TAB_TOKEN" in
  let* tab_user = get_env_opt_err "TAB_USER" in
  Some (tab_token, tab_user)

let command_tab_transactions () =
  let* tab_token, tab_user = get_tab_variables () in
  let* transactions =
    Lwt_main.run (fetch_api_tap Transactions tab_token tab_user)
  in
  let trans_list = transactions |> YojsonBU.to_list in
  print_transactions trans_list tab_user;
  None

let command_tab_profile () =
  match get_tab_variables () with
  | Some (tab_token, tab_user) -> (
      match Lwt_main.run (fetch_api_tap Profile tab_token tab_user) with
      | Some profile -> print_profile profile
      | None -> ())
  | None -> ()
