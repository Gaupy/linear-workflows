open Format
open Def
open Tools



let dfs_compare dag compare_fun =
	let ntasks = Array.length dag.tabTask in
	let result = {order = Array.make ntasks (-1,false); sched = Array.make ntasks (-1,false)} in
	let current = ref 0 in (* The position of the current task in the linearization*)
	let rec auxdfs_v1 taskId =
		(* We verify first whether all parents of taskId have been scheduled *)
		if (List.for_all (fun x -> snd result.sched.(x)) dag.tabParents.(taskId)) then 
		begin
			if (snd result.sched.(taskId) || (fst result.order.(!current)) >= 0) then failwith "already scheduled";
			(* We add the current task to the linearization first, without checkpoint.*)
			result.sched.(taskId) <- (!current , true);
			result.order.(!current) <- (taskId , false);
			incr current;
			
			(* compare_fun chooses the function for dfs.*)
			let childrenSorted = List.fast_sort (compare_fun) dag.tabChildren.(taskId) in
			List.iter auxdfs_v1 childrenSorted
		end
	in
	List.iter auxdfs_v1 dag.sources;
	if !current <> ntasks then (Printf.printf "Not everyone has been scheduled: %d." !current; failwith "\n") ; 
	result

let dfs dag =
	let ntasks = Array.length dag.tabTask in
	let result = {order = Array.make ntasks (-1,false); sched = Array.make ntasks (-1,false)} in
	let current = ref 0 in (* The position of the current task in the linearization*)
	let rec auxdfs_v2 taskId =
		(* We verify first whether all parents of taskId have been scheduled *)
		if (List.for_all (fun x -> snd result.sched.(x)) dag.tabParents.(taskId)) then 
		begin
			if (snd result.sched.(taskId) || (fst result.order.(!current)) >= 0) then failwith "already scheduled";
			(* We add the current task to the linearization first, without checkpoint.*)
			result.sched.(taskId) <- (!current, true);
			result.order.(!current) <- (taskId , false);
			incr current;
			
			(* We sort the children in increasing order of weightSucc *)
			let childrenSorted = List.fast_sort (fun x y -> compare (dag.weightSucc.(x)) (dag.weightSucc.(y))) dag.tabChildren.(taskId) in
			List.iter auxdfs_v2 childrenSorted
		end
	in
	List.iter auxdfs_v2 dag.sources;
	if !current <> ntasks then (Printf.printf "Not everyone has been scheduled: %d." !current; failwith "\n") ; 
	result



let bfs dag =
	let ntasks = Array.length dag.tabTask in
	let result = {order = Array.make ntasks (-1,false); sched = Array.make ntasks (-1,false)} in
	let queueTBS = Queue.create () in
	List.iter (fun x-> Queue.add x queueTBS) dag.sources;
	let current = ref 0 in (* The position of the current task in the linearization*)
	while !current < ntasks do
		let taskId = Queue.pop queueTBS in
		(* We verify whether this element has already been scheduled. If it yes, we do nothing.*)
		if snd result.sched.(taskId) then ()
		else
		begin
			(* We verify whether this element can be scheduled. If it cannot we do nothing.*)
			if (List.for_all (fun x -> snd result.sched.(x)) dag.tabParents.(taskId)) then 
			begin
				result.sched.(taskId) <- (!current,true);
				result.order.(!current) <- (taskId,false);
				List.iter (fun x-> Queue.add x queueTBS) dag.tabChildren.(taskId);
				incr current;
			end
		end
	done;
	result

let random_fs dag =
	let ntasks = Array.length dag.tabTask in
	let result = {order = Array.make ntasks (-1,false); sched = Array.make ntasks (-1,false)} in
	let current = ref 0 in (* The position of the current task in the linearization*)
	let avail = ref (List.length dag.sources) in
	let avail_list = ref dag.sources in

	while !avail > 0 do
		let rand_avail_id = Random.int !avail in
		let taskId = List.nth !avail_list rand_avail_id in
		if (snd result.sched.(taskId) || (fst result.order.(!current)) >= 0) then failwith "already scheduled";
		result.sched.(taskId) <- (!current, true);
		result.order.(!current) <- (taskId , false);
		incr current;
		decr avail;	
		let add_child tId =
			if (List.for_all (fun x -> snd result.sched.(x)) dag.tabParents.(tId)) then 
				(incr avail; avail_list := tId :: !avail_list)
		in
			List.iter add_child dag.tabChildren.(taskId)
	done;
	if !current <> ntasks then (Printf.printf "Not everyone has been scheduled: %d." !current; failwith "\n") ; 
	result


