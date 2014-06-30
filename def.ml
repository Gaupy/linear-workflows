open Format

(* DEFINITION TYPE TASKS *)

type task = {
	id : int;
	w : float;	(* work *)
	c : float;		(* checkpoint time *)
	r : float;		(* recovery time *)
}
    
(* DEFINITION TYPE (DIRECTED) EDGES *)
type edge = {
	id1 : int;
	id2 : int;
}

(* DEFINITION TYPE DAG *)
type dag = {
	tabTask : task array;
	sources : int list;			(* list of the sources of the DAG *)
	tabParents : int list array;	(* tabParents.(i) is the list of the index in tabTask of the parents of tabTask.(i) *)
	tabChildren : int list array;	(* tabChildren.(i) is the list of the index in tabTask of the children of tabTask.(i) *)
	weightSucc : float array;	(* weightSucc.(i) is the sum of the weight of all successors of tabTask.(i) *)
}

(** Type of the specification of a DAG. Can be almost converted to [dag] *)
type spec = task list * (int * int) list
type spec_tree = task list * (int * int) list * int


let computeWS dag =
	let ntasks = Array.length (dag.tabTask) in
	let wSucc = Array.make ntasks 0. in 
	let tasksDone = Array.make ntasks false in
	let rec auxcomputeWS taskId =
		if tasksDone.(taskId) then ()
		else
			begin
				tasksDone.(taskId) <- true;
				let f x = 
					auxcomputeWS x ; 
(*					Printf.printf "task %d went from %f to %f\n" taskId wSucc.(x) (wSucc.(taskId) +. wSucc.(x)+. dag.tabTask.(x).w);*)
					wSucc.(taskId) <- wSucc.(taskId) +. wSucc.(x) +. dag.tabTask.(x).w
				in
				List.iter f dag.tabChildren.(taskId)
			end
	in
	List.iter auxcomputeWS dag.sources;
	{
		tabTask = dag.tabTask;
		sources = dag.sources;
		tabParents = dag.tabParents;
		tabChildren = dag.tabChildren;
		weightSucc = wSucc;
	}


(* DEFINITION TYPE LINEAR WORKFLOW *)
type linearWorkflow = {
	order : (int * bool) array; 	(* "int" is the index of the task in dag.tabTask; "bool" is whether or not that task is checkpointed *)
	sched : (int * bool) array;		(* sched.(i) is "j,true" if there exists j and order.(j) = (i,_) (meaning task i has already been scheduled.)*)
}

type param = {
	lambda : float;
	d : float;
	ntasks : int;
	expe_number : int; (* What we want to plot *)
	c_number : int; (* How we want to generate checkpointing time *)
	r_number : int; (* How we want to generate recovery time *)
}

