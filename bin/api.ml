open Lwt
open Cohttp
open Cohttp_lwt_unix
module YojsonS = Yojson.Safe
module YojsonB = Yojson.Basic
module YojsonBU = Yojson.Basic.Util
open Utils

(* Monad binding onto let* specifically for Lwt *)
let ( let* ) = Lwt.bind

let get_json url token =
  print_endline "Fetching data from api";
  let headers =
    [
      ("Accept", "application/json"); ("Authorization", "Token token=" ^ token);
    ]
  in
  let res =
    Lwt_main.run
      ( Client.get ~headers:(Header.of_list headers) (Uri.of_string url)
      >>= fun (resp, body) ->
        let code = resp |> Response.status |> Code.code_of_status in
        (* 
         * Printf.printf "Response code: %d\n" code;
         * Printf.printf "Headers: %s\n" (resp |> Response.headers |> Header.to_string);
         * *)
        let json =
          if code = 200 then
            let* body_str = Cohttp_lwt.Body.to_string body in
            Lwt.return @@ Some (YojsonB.from_string body_str)
          else
            let () = Printf.printf "Download of transactions.json failed." in
            Lwt.return @@ None
        in
        json )
  in
  res
