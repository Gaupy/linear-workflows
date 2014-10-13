README
=======

All the data files have the form:

`WORKFLOWNAME_$c_$n_$l_$d.results`

where:

* WORKFLOWNAME is the name of the workflow (CYBERSHAKE, GENOME, LIGO, MONTAGE)

* $c should be: 
	- 0 if the checkpoint time is proportionnal (0.1 times) to the execution time of the task
	- 1 if the checkpoint time is proportionnal (0.01 times) to the execution time of the task
	- x < 0 if the checkpoint time is a random number between 0 and -x for all tasks
	- x > 0 if the checkpoint time is x for all tasks

* $n is the number of tasks

* $l is the fault rate lambda

* $d is the downtime

Inside each data files are 20 lines for 20 different graphs.
Each line is 
	`x (x0,y0) ... (x20,y20)`

where:
* x is the execution time of an execution without failures and without checkpoints (the total weight of the DAG)

* (xk,yk) is the execution time (xk) and number of checkpoints (yk) of the the heuristic "heur_name" where:
	- k = 3*j + i (i in 0;1;2)
	- tabJ = ["no ckpt" ; "all ckpt" ; "per ckpt" ; "decr W" ; "incr C" ; "decr D" ; "decr WD/C"]
	- tabI = ["bfs" ; "dfs" ; "rfs"]
	- "heur_name" = tabJ.(j) x tabI.(i)

