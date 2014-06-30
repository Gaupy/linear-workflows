open Format
open Printf
open Def

let sizeDAG config =
  config.ntasks



let assignWCR config task =
	let i = task.id in 
    match task.w,config.c_number, config.r_number with
      | 0.,_,_ -> ({id=i;w=5.;c=1.;r=1.})
      | _,_,_ -> ({id=i;w=task.w;c=1.;r=1.})




let spec_to_dag config sp =
	let ntasks = sizeDAG config in
	let tabTaskInit = Array.make ntasks {id=0;w=1.;c=1.;r=1.} in
	let tabParentsInit = Array.make ntasks [] in
	let tabChildrenInit = Array.make ntasks [] in
	let tasks, edges = sp in
	(* First we create the tasks whose weight is known *)
	let rec assign_wcr listoftasks i =
		if i < 0 then ()
		else
			match listoftasks with
				| [] -> ( tabTaskInit.(i) <-  assignWCR config {id=i;w=0.;c=1.;r=1.}; assign_wcr [] (i-1) )
				| a::q -> ( tabTaskInit.(i) <- (assignWCR config {id=i;w=a.w;c=a.c;r=a.r}); assign_wcr q (i-1) )
	in assign_wcr tasks (ntasks-1);
	(* Then we create the edges whose weight is known *)
	let assign_edges (e1,e2) =
		tabParentsInit.(e2)<- e1 :: tabParentsInit.(e2) ; 
		tabChildrenInit.(e1) <- e2 :: tabChildrenInit.(e1)
	in List.iter assign_edges edges;
	let sources = ref [] in
	for i =0 to ntasks -1 do
		if tabParentsInit.(i) = [] then sources:= i :: !sources
	done;
	let temp = { tabTask = tabTaskInit; sources = !sources; tabParents = tabParentsInit; tabChildren = tabChildrenInit; weightSucc = Array.make ntasks 0.;} in
	computeWS temp

let parse_graph file =
	let chan = open_in file in
	let ans = Graph_parser.parse Graph_lexer.token (Lexing.from_channel chan) in
	let () = close_in chan in
	ans

let make_dag config file =
	let sp = parse_graph file in
	spec_to_dag config sp
