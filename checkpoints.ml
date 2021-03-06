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
(*	printf "period : %f\t" period;*)
	let temp = ref 0. in
(*	let cptr = ref 0 in*)
	for i = 0 to ntasks -1 do
		temp := !temp +. dag.tabTask.(indTaskWF2DAG workflow i).w;
		if !temp > 2. *. period then 
			(if i > 0 then workflow.order.(i-1) <- (fst workflow.order.(i-1), true)) (* In that case, the new task is so big that we need to checkpoint the previous work also.*)
		else 
			if !temp >= period then 
				begin
					workflow.order.(i) <- (fst workflow.order.(i), true);
					temp := 0.;
(*				incr cptr*)
				end
			else
				workflow.order.(i) <- (fst workflow.order.(i), false);
	done;
(*	printf "nreal : %d\t" !cptr;*)
	workflow



let compareW dag task1 task2 =
	compare (task2.w) (task1.w)

let compareC dag task1 task2 =
	compare (task1.c) (task2.c)

let compareD dag task1 task2 =
	compare (dag.weightSucc.(task2.id)) (dag.weightSucc.(task1.id))

let compareWCD dag task1 task2 =
	compare (task2.w *. (dag.weightSucc.(task2.id)) /. task2.c) (task1.w *. dag.weightSucc.(task1.id) /. task1.w)



let ckptsort dag workflow nckpt compare_fun =
	let ntasks = Array.length dag.tabTask in
	let array_sorted = Array.make ntasks {id = -1; w=0.; c = 0.; r = 0.} in
	for i = 0 to ntasks -1 do
		array_sorted.(i) <- dag.tabTask.(i)
	done;
	Array.fast_sort (compare_fun) array_sorted;
	let nckpt_nobug = min (int_of_float nckpt) ntasks in 
	for i = 0 to nckpt_nobug - 1 do
		let i_wf = indTaskDAG2WF workflow (array_sorted.(i).id) in
		workflow.order.(i_wf) <- (fst workflow.order.(i_wf),true)
	done;
	for i = nckpt_nobug to ntasks - 1 do
		let i_wf = indTaskDAG2WF workflow (array_sorted.(i).id) in
		workflow.order.(i_wf) <- (fst workflow.order.(i_wf),false)
	done;
	(*	printf "nreal : %d\t" !cptr;*)
	workflow


