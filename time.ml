open Format
open Printf
open Def
open Schedule
open Tools

let expect d = d

let expectedTime param w c r =
	let lambda = param.lambda in
	let d = param.d in
		exp (lambda *. r) *. (1. /. lambda +. (expect d)) *. (exp (lambda*. (w +. c)) -. 1.)



(*let rec traverse dag workflow l i k tabDone =(* l,i,k are the (l,i,k)th tasks in the order of the workflow! *)*)
(*	let ntasks = Array.length dag.tabTask in*)
(*	let auxtraverse jdag =*)
(*		let j = indTaskDAG2WF workflow jdag in*)
(*		match tabDone.(i).(k).(j) with*)
(*			| -1 -> *)
(*			begin*)
(*				for r = i+1 to ntasks - 1 do*)
(*					tabDone.(r).(k).(j) <- 0*)
(*				done;*)
(*				if j < k then*)
(*					if isCkptWF workflow j then tabDone.(i).(k).(j) <- 2*)
(*					else (tabDone.(i).(k).(j) <- 1; traverse dag workflow j i k tabDone)*)
(*			end*)
(*			| 0 | 1 | 2 -> ()*)
(*			| _ -> failwith "should never happen"*)
(*	in*)
(*	List.iter auxtraverse dag.tabParents.(indTaskWF2DAG workflow l)*)

let rec traverse dag workflow l i k tabDone =(* l,i,k are the (l,i,k)th tasks in the order of the workflow! *)
	let ntasks = Array.length dag.tabTask in
	let ldag = indTaskWF2DAG workflow l in
	match tabDone.(i).(k).(l) with
		| -1 -> 
		begin
(*			printf "traverse l=%d, i=%d, k=%d \n" l i k;*)
			for r = i+1 to ntasks - 1 do
				tabDone.(r).(k).(l) <- 0
			done;
			if l < k then
				if isCkptWF workflow l then tabDone.(i).(k).(l) <- 2
				else (tabDone.(i).(k).(l) <- 1; List.iter (fun x -> traverse dag workflow (indTaskDAG2WF workflow x) i k tabDone) dag.tabParents.(ldag))
			else tabDone.(i).(k).(l) <- 0
		end
		| 0 | 1 | 2 -> ()
		| _ -> failwith "should never happen"





let findWikRik dag workflow k = (*k is the kth task in the order of the workflow!*)
	let ntasks = Array.length dag.tabTask in
	let tabDone = Array.make_matrix ntasks ntasks (Array.make ntasks (-1)) in
	let wk = Array.make ntasks 0. in
	let rk = Array.make ntasks 0. in
	for r = k+1 to ntasks -1 do
		tabDone.(r).(k).(k) <- 0 (* there is a failure during the execution of k, but k was executed successfully *)
	done;
	for i = k to ntasks -1 do
		List.iter (fun x -> traverse dag workflow (indTaskDAG2WF workflow x) i k tabDone) dag.tabParents.(indTaskWF2DAG workflow i);
		for j = 0 to k-1 do
			match tabDone.(i).(k).(j) with
				| 1 -> (wk.(i) <- wk.(i) +. dag.tabTask.(indTaskWF2DAG workflow j).w)
				| 2 -> (rk.(i) <- rk.(i) +. dag.tabTask.(indTaskWF2DAG workflow j).r)
				| _ -> () (*this means that this task is not a predecessor.*)
		done
	done; 
	wk,rk




let schedTime param dag workflow =
	let ntasks = Array.length dag.tabTask in
	let tabWik = Array.make_matrix ntasks ntasks 0. in
	let tabRik = Array.make_matrix ntasks ntasks 0. in
	let eXi = Array.make ntasks 0. in (* This array is not necessary, but it is for debug. *)
	for k = 0 to ntasks -1 do
		let wk,rk = findWikRik dag workflow k in
		printf "%d: " k;
		for i = 0 to ntasks -1 do
			tabWik.(i).(k) <- wk.(i);
			printf "%f\t" wk.(i);
			tabRik.(i).(k) <- rk.(i);
		done; 
		printf "\n";
	done;
	
	let tabZik = Array.make_matrix ntasks ntasks 0. in
	for k = 0 to ntasks-1 do
		if k+1 < ntasks then
		begin  
			tabZik.(k+1).(k) <- 1.;
			for i = 0 to k-1 do
				tabZik.(k+1).(k) <- tabZik.(k+1).(k) -. tabZik.(k).(i)
			done;
		end;
		for i = k+2 to ntasks-1 do
			let sum = ref 0. in
			for j = k+1 to i-1 do
				let j_dag = indTaskWF2DAG workflow j in
				let delta_j = if isCkptWF workflow j then 1. else 0. in
				sum := !sum +. tabWik.(j).(k) +. tabRik.(j).(k) +. dag.tabTask.(j_dag).w +. delta_j *. dag.tabTask.(j_dag).c
			done;
			tabZik.(i).(k) <- exp (-. param.lambda *. !sum) *. tabZik.(k+1).(k)
		done
	done;
	let result = ref 0. in (* We need to initiate it with the values for the first task.*)
	let i_dag = indTaskWF2DAG workflow 0 in
	let delta_i = if isCkptWF workflow 0 then 1. else 0. in
	let c = delta_i *. dag.tabTask.(i_dag).c in
	let w = dag.tabTask.(i_dag).w in 
	let r = 0. in
		eXi.(0) <- eXi.(0) +. (expectedTime param w c r);
		result := !result +. (expectedTime param w c r);
	for i = 1 to ntasks -1 do
		let i_dag = indTaskWF2DAG workflow i in
		let delta_i = if isCkptWF workflow i then 1. else 0. in
		let c = delta_i *. dag.tabTask.(i_dag).c in
		for k = 0 to i-1 do
			let w = dag.tabTask.(i_dag).w +. tabWik.(i).(k) +. tabRik.(i).(k) in 
			let r = (tabWik.(i).(i) +. tabRik.(i).(i) -. (tabWik.(i).(k) +. tabRik.(i).(k))) in
				eXi.(i) <- eXi.(i) +. tabZik.(i).(k) *. (expectedTime param w c r);
				result := !result +. tabZik.(i).(k) *. (expectedTime param w c r)
		done
	done;
	print_workflow_expect workflow eXi;
	!result




