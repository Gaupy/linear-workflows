open Const
open Scanf
open Printf

let parse_config file =
  let chan = open_in file in
  let lambda = float_of_string (input_line chan) in
  let d = float_of_string (input_line chan) in
  let ntasks = int_of_string (input_line chan) in
  let expe_number = int_of_string (input_line chan) in
  let c_number = int_of_string (input_line chan) in
  let r_number = int_of_string (input_line chan) in
  let () = close_in chan in
  {
  lambda = lambda;
  d = d;
  ntasks = ntasks;
  expe_number= expe_number;
  c_number= c_number;
  r_number= r_number;
  }




let script config_file =
  let param = parse_config config_file in
(*  let nheur = param.size_of_tree in*)
(*  let tab = Array.make_matrix nheur 6 (0.,0.) in*)
  let ntasks = param.ntasks in
  let lambda = param.lambda in
  let d = param.d in
  let c_number = param.c_number in
  let r_number= param.r_number in
  let expe_number = param.expe_number in
  let number_heur = 21 in 

  let tab_names_heur = Array.make number_heur "" in
  for i = 0 to number_heur -1 do
    let temp_name = sprintf "%d" i in
      tab_names_heur.(i) <- temp_name
  done;

  (*Below are the array where we store the solutions to draw some nice plot with gnuplot.*)
  let node_val_array = Array.make 11 0 in
    node_val_array.(0) <- 50;
    for i = 1 to 10 do
      node_val_array.(i) <- i * 100
    done;
  let tab_maxnodes = 
    match expe_number with 
      | _-> Array.make_matrix 11 number_heur (0.,0.)
  in
(*  let tab_time = *)
(*    match expe_number with *)
(*      | _-> Array.make_matrix (size_of_tree+1) number_heur (0.,0.)*)
(*  in*)
  let lambda_val_array = Array.make 4 0. in
    lambda_val_array.(0) <- 0.0001;
    lambda_val_array.(1) <- 0.0005;
    lambda_val_array.(2) <- 0.001;
    lambda_val_array.(3) <- 0.005;
  let number_of_lambda = Array.length lambda_val_array in
  let tab_lambda = 
    match expe_number with 
      | _-> Array.make_matrix number_of_lambda  number_heur (0.,0.)
  in

(*  let res_string = (sprintf "result_%d_%d_%d_%d.avg" size_of_tree number_of_speeds (string_of_int (int_of_float param.static)) expe_number) in *)
  let name_result = 
    match expe_number with 
      | _ -> ("nodes_l"^(string_of_float (lambda))^"_c"^(string_of_int c_number)^"_r"^(string_of_int (r_number))) 
   in
(*  let eps_file = (name_result^".eps") in *)
  let res_string = (name_result^".tex") in
  let buff = ref (open_out res_string) in 
(*  let script_gnuplot = ref (open_out (name_result^".p")) in *)

(*  let name_input =*)
(*    match expe_number with*)
(*      | _ -> *)
(*  in*)
  
  let list_dags =
    match expe_number with
    | _ -> "MONTAGE"::"LIGO"::"CYBERSHAKE"::[]
    | _ -> "MONTAGE"::"LIGO"::"GENOME"::"CYBERSHAKE"::[]
  in
  let list_nodes =
    match expe_number with
(*    | _ -> 50::[]*)
    | _ -> 50::100::200::300::400::500::600::700::800::[]
  in







  let parse_results tab file =
    let ich = open_in file in
    try 
      let rec loop () =
        let total_weight = Scanf.fscanf ich " %f " (fun x -> x) in

          for i = 0 to number_heur - 1 do
              let time, ckpt = (Scanf.fscanf ich " ( %f , %d ) " (fun f d -> f,d)) in
              let j,r = tab.(i) in
                tab.(i) <- j +. 1. , r+. time /. total_weight ;
          done;
(*          let _ = (Scanf.fscanf ich " \n " (fun () -> ())) in*)
          loop ()
      in loop () 
    with 
      | Scan_failure _ -> printf "scan failure %s" file
      | End_of_file -> ()
      | _ -> printf "???"
  in

  let fun_iter_dag_node dagname node =
    let new_file =  ("../results/"^dagname^"_"^(string_of_int c_number)^"_"^(string_of_int node)^"_"^(string_of_float (lambda))^"_"^(string_of_int (int_of_float d))^".results") in
    printf "%s\n" new_file;
    match expe_number with
      | _ -> parse_results tab_maxnodes.(node / 100) new_file
  in
  let list_of_names = List.concat (List.map (fun a -> (List.map (fun b -> (a, b)) list_nodes)) list_dags) in
    List.iter (fun p -> fun_iter_dag_node (fst p) (snd p)) list_of_names;
  
(*  Finally we treat the data.*)

  let tab, tab_val =
    match expe_number with
      | _ -> tab_maxnodes, node_val_array
(*      | _ -> tab_lambda, lambda_val_array*)
  in
  for i = 0 to number_heur -1 do
    let data_set_name =
      match expe_number with
        | _ -> name_result^(tab_names_heur.(i))^".data"
    in
    fprintf !buff "\\begin{filecontents}{%s}\n" data_set_name;
    for j = 0 to 10 do
      if fst tab.(j).(i) = 0. then printf "no value %d %d\n" i j else
      fprintf !buff "%d\t%f\n" tab_val.(j) (snd tab.(j).(i) /. fst tab.(j).(i));
    done;
    fprintf !buff "\\end{filecontents}\n"
  done




let () = script Sys.argv.(1)
