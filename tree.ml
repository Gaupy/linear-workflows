open Format
open Printf
open Def

let assignWCR_tree config task =
    match config.c_number, config.r_number with
      | _ , _ -> ({id = task.id ; w = task.w ; c=1.;r=1.})


let spec_to_tree config sp =
	let tasks, edges, ntasks = sp in
	printf " ntasks= %d" ntasks;
	let tabTaskInit = Array.make ntasks {id=0;w=1.;c=1.;r=1.} in
	let tabParentsInit = Array.make ntasks [] in
	let tabChildrenInit = Array.make ntasks [] in
	(* First we create the tasks whose weight is known *)
	let assign_wcr a =
		tabTaskInit.(ntasks - 1 - a.id) <- (assignWCR_tree config {id= ntasks - 1 - a.id  ;w=a.w;c=a.c;r=a.r}) 
	in List.iter assign_wcr tasks;
	(* Then we create the edges whose weight is known *)
	let assign_edges (e1,e2) =
		if e1 = ntasks - 1 - e2 then printf "attention\n";
		if e1 = 0 then ()
		else
			(tabParentsInit.(ntasks - 1 - e2)<- e1 -1 :: tabParentsInit.(ntasks - 1 - e2) ; 
			tabChildrenInit.(e1 -1) <- ntasks - 1 - e2:: tabChildrenInit.(e1 -1))
	in List.iter assign_edges edges;
	let sources = ref [] in
	for i =0 to ntasks -1 do
		if tabParentsInit.(i) = [] then sources:= i :: !sources
	done;
	let temp = { tabTask = tabTaskInit; sources = !sources; tabParents = tabParentsInit; tabChildren = tabChildrenInit; weightSucc = Array.make ntasks 0.;} in
	computeWS temp

let parse_tree file =
	let chan = open_in file in
	let ans = Tree_parser.parse Tree_lexer.token (Lexing.from_channel chan) in
	let () = close_in chan in
	ans

let make_tree config file =
	let sp = parse_tree file in
	spec_to_tree config sp
