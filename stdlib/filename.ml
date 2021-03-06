(***********************************************************************)
(*                                                                     *)
(*                           Objective Caml                            *)
(*                                                                     *)
(*          Xavier Leroy and Damien Doligez, INRIA Rocquencourt        *)
(*                                                                     *)
(*  Copyright 1996 Institut National de Recherche en Informatique et   *)
(*  Automatique.  Distributed only by permission.                      *)
(*                                                                     *)
(***********************************************************************)

(* $Id: filename.ml,v 1.3 1998/10/23 13:18:40 pessaux Exp $ *)

let current_dir_name =
  match Sys.os_type with
  | "Unix" -> "."
  | "Win32" -> "."
  | "MacOS" -> ":"
  | _ -> assert false ;;

let unix_concat dirname filename =
  let l = String.length dirname in
  if l = 0 or dirname.[l-1] = '/'
  then dirname ^ filename
  else dirname ^ "/" ^ filename ;;

let wnt_concat dirname filename =
  let l = String.length dirname in
  if l = 0 or (let c = dirname.[l-1] in c = '/' or c = '\\' or c = ':')
  then dirname ^ filename
  else dirname ^ "\\" ^ filename ;;

let mac_concat dirname filename =
  let l = String.length dirname in
  if l = 0 or dirname.[l-1] = ':'
  then dirname ^ filename
  else dirname ^ ":" ^ filename ;;

(* !!! Eta expansions *)
let concat x y =
  match Sys.os_type with
  | "Unix" -> unix_concat x y
  | "Win32" -> wnt_concat x y
  | "MacOS" -> mac_concat x y
  | _ -> assert false ;;

let unix_is_relative n = String.length n < 1 || n.[0] <> '/';;

let unix_is_implicit n =
  unix_is_relative n
  && (String.length n < 2 || String.sub n 0 2 <> "./")
  && (String.length n < 3 || String.sub n 0 3 <> "../")
;;

let wnt_is_relative n =
  (String.length n < 1 || n.[0] <> '/')
  && (String.length n < 1 || n.[0] <> '\\')
  && (String.length n < 2 || n.[1] <> ':')
;;

let wnt_is_implicit n =
  wnt_is_relative n
  && (String.length n < 2 || String.sub n 0 2 <> "./")
  && (String.length n < 2 || String.sub n 0 2 <> ".\\")
  && (String.length n < 3 || String.sub n 0 3 <> "../")
  && (String.length n < 3 || String.sub n 0 3 <> "..\\")
;;

let contains_colon n =
  try
    String.index n ':'; true
  with Not_found ->
    false
;;

let mac_is_relative n =
  (String.length n >= 1 && n.[0] = ':')
  || not (contains_colon n)
;;

let mac_is_implicit n = not (contains_colon n);;


(* !!! Eta expansions *)
let is_relative x =
  match Sys.os_type with
  | "Unix" -> unix_is_relative x
  | "Win32" -> wnt_is_relative x
  | "MacOS" -> mac_is_relative x
  | _ -> assert false ;;

(* !!! Eta expansions *)
let is_implicit x =
  match Sys.os_type with
  | "Unix" -> unix_is_implicit x
  | "Win32" -> wnt_is_implicit x
  | "MacOS" -> mac_is_implicit x
  | _ -> assert false ;;


let unix_check_suffix name suff =
 String.length name >= String.length suff &&
 String.sub name (String.length name - String.length suff) (String.length suff)
    = suff ;;

let wnt_check_suffix name suff =
 String.length name >= String.length suff &&
 (let s = String.sub name (String.length name - String.length suff)
                          (String.length suff) in
  String.lowercase s = String.lowercase suff) ;;

let mac_check_suffix = unix_check_suffix ;;

(* !!! Eta expansions *)
let check_suffix x y =
  match Sys.os_type with
  | "Unix" -> unix_check_suffix x y
  | "Win32" -> wnt_check_suffix x y
  | "MacOS" -> mac_check_suffix x y
  | _ -> assert false ;;

let chop_suffix name suff =
  let n = String.length name - String.length suff in
  if n < 0 then invalid_arg "Filename.chop_suffix" else String.sub name 0 n ;;

let wnt_rindexsep s =
  let rec pos i =
    if i < 0 then raise Not_found
    else if (let c = s.[i] in c = '/' || c = '\\' || c = ':') then i
    else pos (i - 1)
  in pos (String.length s - 1) ;;

let chop_extension name =
  try
    String.sub name 0 (String.rindex name '.')
  with Not_found ->
    invalid_arg "Filename.chop_extension" ;;

let unix_basename name =
  try
    let p = String.rindex name '/' + 1 in
    String.sub name p (String.length name - p)
  with Not_found ->
    name ;;

let unix_dirname name =
  try
    match String.rindex name '/' with
      0 -> "/"
    | n -> String.sub name 0 n
  with Not_found ->
    "." ;;

let wnt_basename name =
  try
    let p = wnt_rindexsep name + 1 in
    String.sub name p (String.length name - p)
  with Not_found ->
    name ;;

let wnt_dirname name =
  try
    match wnt_rindexsep name with
      0 -> "\\"
    | n -> String.sub name 0 n
  with Not_found ->
    "." ;;

let mac_basename name =
  try
    let p = String.rindex name ':' + 1 in
    String.sub name p (String.length name - p)
  with Not_found -> name ;;

let mac_dirname name =
  try match String.rindex name ':' with
      | 0 -> ":"
      | n -> String.sub name 0 n
  with Not_found -> ":" ;;

(* !!! Eta expansions *)
let basename x =
  match Sys.os_type with
  | "Unix" -> unix_basename x
  | "Win32" -> wnt_basename x
  | "MacOS" -> mac_basename x
  | _ -> assert false ;;

(* !!! Eta expansions *)
let dirname x =
  match Sys.os_type with
  | "Unix" -> unix_dirname x
  | "Win32" -> wnt_dirname x
  | "MacOS" -> mac_dirname x
  | _ -> assert false ;;

let temporary_directory =
  match Sys.os_type with
  | "Unix" -> (try Sys.getenv "TMPDIR" with Not_found -> "/tmp")
  | "Win32" -> (try Sys.getenv "TEMP" with Not_found -> "C:\\temp")
  | "MacOS" -> (try Sys.getenv "TempFolder" with Not_found -> ":")
  | _ -> assert false ;;

external open_desc: string[`a] <[`b]-> open_flag[`c] list[`d] <[`e]->
                    int[`f] <[`g]-> int[_] = "sys_open" ;;
external close_desc: int[`a] <[`b]-> unit[() :Pre; `c] = "sys_close" ;;

let temp_file prefix suffix =
  let rec try_name counter =
    if counter >= 1000 then
      invalid_arg "Filename.temp_file: temp dir nonexistent or full"
    else begin
      let name =
        concat temporary_directory (prefix ^ string_of_int counter ^ suffix) in
      try
        close_desc(open_desc name [Open_wronly; Open_creat; Open_excl] 0o666);
        name
      with Sys_error _ ->
        try_name (counter + 1)
    end
  in try_name 0 ;;

