open Format
open Printf
open Def
open Schedule
open Tools
open Checkpoints


let expect d = d

let expectedTime param w c r =
	let lambda = param.lambda in
	let d = param.d in
		exp (lambda *. r) *. (1. /. lambda +. (expect d)) *. (exp (lambda*. (w +. c)) -. 1.)


let rec traverse dag workflow l i k tabDone ant_k =	(* l,i,k are the (l,i,k)th tasks in the order of the workflow! ant_k is a bool that is considering the special case where we are studying a needed predecessor of k.*)
	let ntasks = Array.length dag.tabTask in
	let ldag = indTaskWF2DAG workflow l in
	match tabDone.(i).(k).(l) with
		| -1 -> 
		begin
			for r = i+1 to ntasks - 1 do
				tabDone.(r).(k).(l) <- 0;
			done;
			if l < k then
				begin
					if isCkptWF workflow l then (tabDone.(i).(k).(l) <- (if ant_k then 3 else 2))
					else (tabDone.(i).(k).(l) <- (if ant_k then 3 else 1); List.iter (fun x -> traverse dag workflow (indTaskDAG2WF workflow x) i k tabDone ant_k) dag.tabParents.(ldag))
				end
			else (tabDone.(i).(k).(l) <- 0)
		end
		| 0 | 1 | 2 | 3 -> ()
		| _ -> failwith "should never happen"



let findWikRik dag workflow k = (*k is the kth task in the order of the workflow!*)
	let ntasks = Array.length dag.tabTask in
	let tabDone = Array.make_matrix ntasks ntasks (Array.make ntasks (-1)) in
	(*First we need to initialize tabDone.*)
	for i = 0 to ntasks -1 do
		for j = 0 to ntasks -1 do
			tabDone.(i).(j) <- Array.make ntasks (-1)
		done
	done;
	let wk = Array.make ntasks 0. in
	let rk = Array.make ntasks 0. in
	for r = k+1 to ntasks -1 do
		tabDone.(r).(k).(k) <- 0 (* there is a failure during the execution of k, but k was executed successfully *)
	done;
	for i = k to ntasks -1 do
		List.iter (fun x -> traverse dag workflow (indTaskDAG2WF workflow x) i k tabDone (i = k)) dag.tabParents.(indTaskWF2DAG workflow i);
		for j = 0 to k-1 do
			match tabDone.(i).(k).(j) with
				| 1 -> (wk.(i) <- wk.(i) +. dag.tabTask.(indTaskWF2DAG workflow j).w)(*; printf "i=%d-j=%d\n" i j*)
				| 2 -> (rk.(i) <- rk.(i) +. dag.tabTask.(indTaskWF2DAG workflow j).r)
				| _ -> () (*this means that this task is not a needed predecessor.*)
		done;
(*	printf "\n\ntab : %d \n" i;*)
(*	print_matrix tabDone.(i);*)
	done;
	wk,rk




let schedTime param dag workflow =
	let ntasks = Array.length dag.tabTask in
	let tabWik = Array.make_matrix ntasks ntasks 0. in
	let tabRik = Array.make_matrix ntasks ntasks 0. in
	let eXi = Array.make ntasks 0. in (* This array is not necessary, but it is for debug. *)
	for k = 0 to ntasks -1 do
(*		printf "pivot : %d: \n" k;*)
		let wk,rk = findWikRik dag workflow k in
		for i = 0 to ntasks -1 do
			tabWik.(i).(k) <- wk.(i);
			tabRik.(i).(k) <- rk.(i);
		done; 
(*		printf "\n";*)
	done;
(*	print_matrix tabWik;*)
	
	
	
	(* BEGIN Where we compute the values for Zik.*)
	let tabZik = Array.make_matrix ntasks ntasks 0. in
	let tabZikNoFaults = Array.make ntasks 0. in
	
	(* The special case where there is no fault before the execution of the ith task is easy to compute *)
	for i = 0 to ntasks -1 do

		(* Only the execution of task anterior to the current task impacts the "nofault"*)
		let sum = ref 0. in
		for j = 0 to i -1 do
			let j_dag = indTaskWF2DAG workflow j in
			let delta_j = if isCkptWF workflow j then 1. else 0. in
			sum := !sum +. dag.tabTask.(j_dag).w +. delta_j *. dag.tabTask.(j_dag).c
		done;

		tabZikNoFaults.(i) <- exp (-. param.lambda *. !sum);
(*		printf "ZikNoFaults.(%d): %f \n" i tabZikNoFaults.(i);*)
	done;
	
	(*We use the equations from the paper now.*)
	for i = 0 to ntasks -1 do
		
		for k = 0 to i - 2 do (* where the faults happen *)
			let sum = ref 0. in
			for j = k to i-1 do
				let j_dag = indTaskWF2DAG workflow j in
				let delta_j = if isCkptWF workflow j then 1. else 0. in
				sum := !sum +. tabWik.(j).(k) +. tabRik.(j).(k) +. dag.tabTask.(j_dag).w +. delta_j *. dag.tabTask.(j_dag).c
			done;
			tabZik.(i).(k) <- exp (-. param.lambda *. !sum) *. tabZik.(k+1).(k);

		done;

		if i > 0 then
			begin
				tabZik.(i).(i-1) <- 1. -. tabZikNoFaults.(i);
				for k = 0 to i-2 do
					tabZik.(i).(i-1) <- tabZik.(i).(i-1) -. tabZik.(i).(k)
				done;
			end;

	
	done;
	(* END Where we compute the values for Zik.*)

	for i = 0 to ntasks -1 do
		let temp = ref tabZikNoFaults.(i) in
		for k = 0 to i-1 do
			temp := !temp +. tabZik.(i).(k)
		done;
(*		printf "sum Z.(%d) = %f\n" i (!temp);*)
	done;

		

	let result = ref 0. in 
	
	(* We need to initiate it with the values for the first task.*)
	(*BEGIN First task*)
	let i_dag = indTaskWF2DAG workflow 0 in
	let delta_i = if isCkptWF workflow 0 then 1. else 0. in
	let c = delta_i *. dag.tabTask.(i_dag).c in
	let w = dag.tabTask.(i_dag).w in 
	let r = 0. in
		eXi.(0) <- eXi.(0) +. (expectedTime param w c r);
		result := !result +. (expectedTime param w c r);
	(*END First task*)
	
	(* Then we initialize with the special case when there is no failure *)
	for i = 1 to ntasks -1 do
		let i_dag = indTaskWF2DAG workflow i in
		let delta_i = if isCkptWF workflow i then 1. else 0. in
		let c = delta_i *. dag.tabTask.(i_dag).c in
		eXi.(i) <- eXi.(i) +. tabZikNoFaults.(i) *. (expectedTime param dag.tabTask.(i_dag).w c 0.);
		result := !result +. tabZikNoFaults.(i) *. (expectedTime param dag.tabTask.(i_dag).w c 0.);
		for k = 0 to i-1 do
			let w = dag.tabTask.(i_dag).w +. tabWik.(i).(k) +. tabRik.(i).(k) in 
			let r = (tabWik.(i).(i) +. tabRik.(i).(i) -. (tabWik.(i).(k) +. tabRik.(i).(k))) in
				eXi.(i) <- eXi.(i) +. tabZik.(i).(k) *. (expectedTime param w c r);
				result := !result +. tabZik.(i).(k) *. (expectedTime param w c r)
		done
	done;
(*	print_workflow_expect workflow eXi;*)
	!result




