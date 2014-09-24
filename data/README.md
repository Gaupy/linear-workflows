README
=======

All the data files have the form:

`WORKFLOWNAME_$c_$n_$l_$d.results`

where:

* WORKFLOWNAME is the name of the workflow (CYBERSHAKE, GENOME, LIGO, MONTAGE)

* $c should be: 
	- 0 if the checkpoint time is proportionnal (0.1 times) to the execution time of the task
	- 1 if the checkpoint time is proportionnal (0.01 times) to the execution time of the task
	- x > 0 if the checkpoint time is x for all tasks
	- x < 0 if the checkpoint time is a random number between 0 and -x for all tasks

* $n is the number of tasks

* $l is the fault rate lambda

* $d is the downtime
