open Format
open Printf
open Def
open Dag
open Tree
open Tools
open Schedule
open Checkpoints
open Time
(*open Example*)

let () = Random.self_init ()

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

let make_graph config dagfile =
	match config.expe_number with 
(*		| 0 -> make_tree config dagfile*)
(*		| 1 -> make_dag config dagfile*)
		| _ -> make_pegasus config dagfile



let script_facto_simu config dag =
  let ntasks = Array.length dag.tabTask in
  let tab_sched_fun = Array.make 3 (bfs) in
  	tab_sched_fun.(1) <- dfs;
  	tab_sched_fun.(2) <- random_fs;
  let tab_compare_fun = Array.make 4 (compareW dag) in
    tab_compare_fun.(1) <- (compareC dag);
    tab_compare_fun.(2) <- (compareD dag);
    tab_compare_fun.(3) <- (compareWCD dag);
  let tab_res = Array.make_matrix 3 7 (0.,0) in
  let tab_names = Array.make 7 "" in
  for i = 0 to 2 do
    let wf = tab_sched_fun.(i) dag in
          
          (** No Ckeckpoint*)
   	let wf_none = ckptnone dag wf in 
   	let t_none = schedTime config dag wf_none in
   	tab_res.(i).(0) <- (t_none, 0);
    tab_names.(0) <- "no ckpt";

          (** All Ckeckpoint*)
    let wf_all = ckptall dag wf in 
    let t_all = schedTime config dag wf_all in
    tab_res.(i).(1) <- (t_all, ntasks);
    tab_names.(1) <- "all ckpt";
          
          (** Periodic Ckeckpoint*)
    let t_per = ref max_float in
    let nperopt = ref 0 in
    for j = 1 to ntasks -1 do
      let wf_per = ckptper dag wf (float_of_int j) in
      let temp = schedTime config dag wf_per in
      if temp < !t_per then (t_per := temp ; nperopt := j)
    done;
    tab_res.(i).(2) <- (!t_per, !nperopt);
    tab_names.(2) <- "per ckpt";

          (** Ckeckpoint with comparaison function (4 heuristics)*)
    tab_names.(3) <- "decr W  ";
    tab_names.(4) <- "incr C  ";
    tab_names.(5) <- "decr D  ";
    tab_names.(6) <- "decr WD/C";
    for k = 0 to 3 do
      let t_comp = ref max_float in
      let ncompopt = ref 0 in
      for j = 1 to ntasks-1 do
        let wf_comp = ckptsort dag wf (float_of_int j) tab_compare_fun.(k) in
        let temp = schedTime config dag wf_comp in
        if temp < !t_comp then (t_comp := temp ; ncompopt := j);
      done;
      tab_res.(i).(3+k) <- (!t_comp, !ncompopt);
    done;
  done;
  (tab_res,tab_names)




let script paramfile dagfile = 
  let config = parse_config paramfile in
  let dag = make_graph config dagfile in
  let expe_number = config.expe_number in
  match expe_number with 
    | _ -> 
      begin
        let tab_result,tab_names = script_facto_simu config dag in
(*        printf "\t\t\tbfs\t\t\tdfs\t\t\trfs\n";*)
        printf "%f\t" (total_weight dag);
        for j = 0 to 6 do
(*          printf "%s \t" tab_names.(j);*)
          for i = 0 to 2 do
            printf "(%f , %d)\t" (fst tab_result.(i).(j)) (snd tab_result.(i).(j));
          done;
(*          printf "\n";*)
        done;
        printf "\n"
      end

let _  = script Sys.argv.(1) Sys.argv.(2)
