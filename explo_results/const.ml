open Arg
type param = {
	lambda : string;
	d : float;
	ntasks : int;
	expe_number : int; (* What we want to plot *)
	c_number : int; (* How we want to generate checkpointing time *)
	r_number : int; (* How we want to generate recovery time *)
}
