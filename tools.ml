open Format
open Printf
open Def

let isCkptWF workflow i = (* Returns whether ith task of the workflow is checkpointed. *)
	snd (workflow.order.(i))

let isSchedDAG workflow i = (* Returns whether task i is checkpointed. *)
	if not (snd workflow.sched.(i)) then failwith "the task is not scheduled"
	else
		snd (workflow.order.(fst workflow.sched.(i)))


let indTaskWF2DAG workflow i =
		fst workflow.order.(i)

let indTaskDAG2WF workflow i =
	if not (snd workflow.sched.(i)) then failwith "the task is not scheduled"
	else
		fst workflow.sched.(i)


let total_weight dag =
	let ntasks = Array.length dag.tabTask in
	let weight = ref 0. in
	for i = 0 to ntasks -1 do
		weight := !weight +. dag.tabTask.(i).w
	done;
	!weight


(* DEBUG TOOLS *)

let print_workflow_expect workflow eXi =
	let ntasks = Array.length workflow.order in
	for i = 0 to ntasks -1 do
		printf "%d: %d -> %f\n" i (fst workflow.order.(i)) (eXi.(i))
	done


let print_matrix tab =
	let n = Array.length tab in
	let m = Array.length tab.(0) in
	for i = 0 to n-1 do
		for j = 0 to m-1 do
			printf "%f\t" tab.(i).(j)
		done;
		printf "\n"
	done
