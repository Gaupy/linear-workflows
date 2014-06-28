open Format
open Printf
open Def
open Tools
open Schedule
open Checkpoints
open Time
open Dag

(* A default DAG to try the code as it comes along. This is a binary tree.*)
let bintree_default =
	let ntasks = 50 in
	let tabTaskInit = Array.make ntasks {id=0;w=5.;c=1.;r=1.} in
	let tabParentsInit = Array.make ntasks [] in
	let tabChildrenInit = Array.make ntasks [] in
	let ind_parent = ref 0 in
	let card_child = ref 0 in
		for i = 1 to ntasks -1 do
			tabTaskInit.(i) <- {id=i;w=5.;c=1.;r=1.};
			if !card_child >= 2 then (incr ind_parent; card_child := 0);
			incr card_child;
			tabParentsInit.(i) <- [!ind_parent];
			tabChildrenInit.(!ind_parent) <- i :: tabChildrenInit.(!ind_parent);
		done;
	let temp = { tabTask = tabTaskInit; sources = [0]; tabParents = tabParentsInit; tabChildren = tabChildrenInit; weightSucc = Array.make ntasks 0.;} in
		computeWS temp


let _ = 
	let wf1 = bfs bintree_default in
	let t1 = schedTime {lambda=0.01; d=1.; ntasks=50; expe_number=0 ; c_number=0; r_number=0;} bintree_default wf1 in
	Printf.printf "t_bfs = %f\n" t1

let _ =
	let wf_temp = bfs bintree_default in
	let wf2 = ckptall bintree_default wf_temp in
	let t2 = schedTime {lambda=0.01; d=1.; ntasks=50; expe_number=0 ; c_number=0; r_number=0;} bintree_default wf2 in
	Printf.printf "t_bfs(ck=all) = %f\n" t2


(*let () = *)
(*	let dag = make_dag Sys.argv.(1) Sys.argv.(2) in*)
(*	let wf_temp = bfs dag in*)
(*	let wf2 = ckptall dag wf_temp in*)
(*	let t2 = schedTime {lambda=0.01; d=1.; ntasks=20; expe_number=0 ; c_number=0; r_number=0;} dag wf2 in*)
(*	Printf.printf "t_bfs(ck=all) = %f\n" t2*)


(*let _ =*)
(*	let wf2 = dfs bintree_default in*)
(*	let t2 = schedTime {lambda=0.01; d=1.} bintree_default wf2 in*)
(*	Printf.printf "t_dfs = %f\n" t2*)

(*let _ =*)
(*	let wf_temp = dfs bintree_default in*)
(*	let wf2 = ckptall bintree_default wf_temp in*)
(*	let t2 = schedTime {lambda=0.01; d=1.} bintree_default wf2 in*)
(*	Printf.printf "t_dfs(ck=all) = %f\n" t2*)

(*let _ =*)
(*	let wf_temp = dfs bintree_default in*)
(*	let wf2 = ckptper bintree_default wf_temp 3. in*)
(*	let t2 = schedTime {lambda=0.01; d=1.} bintree_default wf2 in*)
(*	Printf.printf "t_dfs(ck=%d) = %f\n" 3 t2*)






