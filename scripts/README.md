README
=======

Requirements:
---
* The workflow library is available from https://download.pegasus.isi.edu/misc/SyntheticWorkflows.tar.gz
* It needs to be extracted in the main directory

Scripts:
---
To study the impact of the number of processors, you can launch the following script:
`$ ./main.sh 1 $c 0 0 0 0 0 0 $lambda 0 0`

where:
* $c should be: 
	- 0 if the checkpoint time is proportionnal (0.1 times) to the execution time of the task
	- 1 if the checkpoint time is proportionnal (0.01 times) to the execution time of the task
	- x -gt 0 if the checkpoint time is x for all tasks
	- x -lt 0 if the checkpoint time is a random number between 0 and -x for all tasks

* $lambda is 1/MTBF
