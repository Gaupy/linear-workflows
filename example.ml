open Format
open Printf
open Def
open Tools
open Schedule
open Checkpoints
open Time


(* A default DAG to try the code as it comes along. This is a binary tree.*)
let bintree_default =
	let ntasks = 6 in
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


let wf1 = bfs bintree_default
let t1 = schedTime {lambda=0.01; d=1.} bintree_default wf1
let _ = Printf.printf "t_bfs = %f\n" t1

let wf2 = dfs bintree_default
let t2 = schedTime {lambda=0.01; d=1.} bintree_default wf2
let _ = Printf.printf "t_dfs = %f\n" t2


