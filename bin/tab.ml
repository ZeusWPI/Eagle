open Utils

let print_transactions ts tab_user =
  Ocolor_format.printf "@{<ul>@{<bold>   Tab transaction info@} (last 10)@}\n";
  let last10 = slice ts (List.length ts - 10) (List.length ts) in
  Format.open_vbox 2;
  Format.print_cut ();
  List.iter
    (fun t ->
      let debtor = get_str "debtor" t in
      let creditor = get_str "creditor" t in
      let issuer = get_str "issuer" t in
      let amount = get_currency "amount" t in
      let message = get_str "message" t in
      let time = get_datetime "time" t in
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
  let name = get_str "name" t in
  let penning = get_bool "penning" t in
  let balance = get_currency "balance" t in
  let created_at = get_datetime "created_at" t in
  let updated_at = get_datetime "updated_at" t in
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
  match Sys.getenv_opt "TAB_TOKEN" with
  | Some tab_token -> (
      match Sys.getenv_opt "TAB_USER" with
      | Some tab_user -> Some (tab_token, tab_user)
      | None ->
          print_endline
            "No tap user found. Set the TAB_USER environment variable to use \
             this feature.";
          None)
  | None ->
      print_endline
        "No API token for tab found. Set the TAB_TOKEN environment variable to \
         use this feature.";
      None

let command_tab_transactions () =
  match get_tab_variables () with
  | Some (tab_token, tab_user) -> (
      match Lwt_main.run (fetch_api_tap Transactions tab_token tab_user) with
      | Some transactions ->
          let trans_list = transactions |> YojsonBU.to_list in
          print_transactions trans_list tab_user
      | None -> ())
  | None -> ()

let command_tab_profile () =
  match get_tab_variables () with
  | Some (tab_token, tab_user) -> (
      match Lwt_main.run (fetch_api_tap Profile tab_token tab_user) with
      | Some profile -> print_profile profile
      | None -> ())
  | None -> ()
