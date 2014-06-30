open Format
open Printf
open Def
open Dag
open Tree
open Tools
open Schedule
open Checkpoints
open Time
open Example

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
		| 0 -> make_tree config dagfile
		| _ -> make_dag config dagfile


(*Be careful, a call to a checkpoint function modifies the current workflow, hence after each schedule, we need to call ckptnone.*)
let script paramfile dagfile = 
  let config = parse_config paramfile in
  let dag = make_graph config dagfile in
  let expe_number = config.expe_number in
  match expe_number with 
    | _ -> 
      begin
      	let temp_wf_bfs = bfs dag in
   	    let wf_bfs_all = ckptall dag temp_wf_bfs in
   	    let t_bfs_all = schedTime config dag wf_bfs_all in

   	    let wf_bfs_none = ckptnone dag temp_wf_bfs in 
   	    let t_bfs_none = schedTime config dag wf_bfs_none in

		let wf_bfs_per10 = ckptper dag temp_wf_bfs 10. in
		let t_bfs_per10 = schedTime config dag wf_bfs_per10 in

      	let temp_wf_dfs = dfs dag in

   	    let wf_dfs_all = ckptall dag temp_wf_dfs in
   	    let t_dfs_all = schedTime config dag wf_dfs_all in

   	    let wf_dfs_none = ckptnone dag temp_wf_dfs in
   	    let t_dfs_none = schedTime config dag wf_dfs_none in

		let wf_dfs_per10 = ckptper dag temp_wf_dfs 10. in
		let t_dfs_per10 = schedTime config dag wf_dfs_per10 in

        printf "bfs: %f\t%f\t%f\tdfs: %f\t%f\t%f\n" t_bfs_none t_bfs_all t_bfs_per10 t_dfs_none t_dfs_all t_dfs_per10
      end

let _  = script Sys.argv.(1) Sys.argv.(2)
