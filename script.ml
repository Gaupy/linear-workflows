open Format
open Printf
open Def
open Dag
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

(*Be careful, a call to a checkpoint function modifies the current workflow, hence after each schedule, we need to call ckptnone.*)
let script paramfile dagfile = 
  let config = parse_config paramfile in
  let dag = make_dag config dagfile in
  let expe_number = config.expe_number in
  match expe_number with 
    | _ -> 
      begin
      	let temp_wf_bfs = bfs dag in

   	    let wf_bfs_all = ckptall dag temp_wf_bfs in
   	    let t_bfs_all = schedTime config dag wf_bfs_all in

   	    let wf_bfs_none = ckptnone dag temp_wf_bfs in 
   	    let t_bfs_none = schedTime config dag wf_bfs_none in

      	let temp_wf_dfs = dfs dag in
   	    let wf_dfs_all = ckptall dag temp_wf_dfs in
   	    let t_dfs_all = schedTime config dag wf_dfs_all in

   	    let wf_dfs_none = ckptnone dag temp_wf_dfs in
   	    let t_dfs_none = schedTime config dag wf_dfs_none in

        printf "%f\t%f\t%f\t%f\n" t_bfs_none t_bfs_all t_dfs_none t_dfs_all
      end

let _  = script Sys.argv.(1) Sys.argv.(2)
