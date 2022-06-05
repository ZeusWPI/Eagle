module YojsonS = Yojson.Safe
module YojsonB = Yojson.Basic
module YojsonBU = Yojson.Basic.Util
module CalendarPrinter = CalendarLib.Printer.Calendar

(* Monad binding onto let *)
let ( let* ) = Lwt.bind

let slice list i k =
  let rec take n = function
    | [] -> []
    | h :: t -> if n = 0 then [] else h :: take (n - 1) t
  in
  let rec drop n = function
    | [] -> []
    | _h :: t as l -> if n = 0 then l else drop (n - 1) t
  in
  take (k - i + 1) (drop i list)

let get_json_member_str name jt =
  jt |> YojsonBU.member name |> YojsonBU.to_string

let get_str = get_json_member_str

let get_json_member_currency name jt =
  jt |> YojsonBU.member name |> YojsonBU.to_int |> float_of_int |> fun c ->
  c /. 100.

let get_currency = get_json_member_currency

let get_json_member_bool name jt =
  jt |> YojsonBU.member name |> YojsonBU.to_bool

let get_bool = get_json_member_bool
let get_json_member_int name jt = jt |> YojsonBU.member name |> YojsonBU.to_int
let get_int = get_json_member_int

let get_json_member_datetime name jt =
  get_json_member_str name jt
  |> String.split_on_char '.'
     (* There is no support for milliseconds so we just cut this of. At the moment this also cuts of the timezone so the date is a localdatetime *)
  |> (fun l -> List.nth l 0)
  |> CalendarLib.Printer.Calendar.from_fstring "%FT%T"

let get_datetime = get_json_member_datetime
