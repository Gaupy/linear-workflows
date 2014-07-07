open Format
open Printf
open Def

let sizeDAG config =
  config.ntasks



let assignWCR config task =
	let i = task.id in 
    match task.w,config.c_number, config.r_number with
      | 0.,0,_ -> ({id=i;w=5.;c=0.5;r= 0.5})
      | 0.,_,_ -> ({id=i;w=5.;c=(float_of_int config.c_number);r=(float_of_int config.c_number)})
      | _,0,_ -> ({id=i;w=task.w;c=0.1*. task.w;r= 0.1*. task.w})
      | _,a,_ -> 
      	if a > 0 
      	  then ({id=i;w=task.w;c=(float_of_int config.c_number);r=(float_of_int config.c_number)}) 
      	  else let value = Random.float (float_of_int (-a)) in ({id=i;w=task.w ; c=value ; r= value})




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

let spec_to_dagP config sp =
	let ntasks = sizeDAG config in
	let tabTaskInit = Array.make ntasks {id=0;w=0.;c=0.;r=0.} in
	let tabParentsInit = Array.make ntasks [] in
	let tabChildrenInit = Array.make ntasks [] in
	let tasks, edges = sp in
	(* First we create the tasks whose weight is known *)
	let rec assign_wcr listoftasks i =
		if i < 0 then ()
		else
			match listoftasks with
				| [] -> (  )
				| a::q -> ( tabTaskInit.(i) <- (assignWCR config {id=a.id;w=a.w;c=a.c;r=a.r}); assign_wcr q (i-1) )
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

let parse_pegasus file =
	let chan = open_in file in
	let ans = Pegasus_parser.parse Pegasus_lexer.token (Lexing.from_channel chan) in
	let () = close_in chan in
	ans

let parse_graph file =
	let chan = open_in file in
	let ans = Graph_parser.parse Graph_lexer.token (Lexing.from_channel chan) in
	let () = close_in chan in
	ans

let make_pegasus config file =
	let sp = parse_pegasus file in
	spec_to_dagP config sp

let make_dag config file =
	let sp = parse_graph file in
	spec_to_dag config sp
