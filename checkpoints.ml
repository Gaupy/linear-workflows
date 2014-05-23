open Format
open Printf
open Def
open Schedule
open Tools


let ckptall dag workflow =
	let ntasks = Array.length dag.tabTask in
	for i = 0 to ntasks -1 do
		workflow.order.(i) <- (fst workflow.order.(i), true)
	done;
	workflow

let ckptnone dag workflow =
	let ntasks = Array.length dag.tabTask in
	for i = 0 to ntasks -1 do
		workflow.order.(i) <- (fst workflow.order.(i), false)
	done;
	workflow


let ckptper dag workflow nckpt =
	let ntasks = Array.length dag.tabTask in
	let sum_total_weights = ref 0. in
	for i = 0 to ntasks -1 do
		sum_total_weights := !sum_total_weights +. dag.tabTask.(i).w;
	done;
	let period = !sum_total_weights /. nckpt in
	let temp = ref 0. in
	for i = 0 to ntasks -1 do
		temp := !temp +. dag.tabTask.(i).w;
		if !temp > 2. *. period then 
			(if i > 0 then workflow.order.(i-1) <- (fst workflow.order.(i-1), true)) (* In that case, the new task is so big that we need to checkpoint the previous work also.*)
		else 
			if !temp > period then 
				(workflow.order.(i) <- (fst workflow.order.(i), true);
				temp := 0.)
	done;
	workflow
