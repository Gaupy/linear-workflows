README
=======


. The workflow library is available from https://download.pegasus.isi.edu/misc/SyntheticWorkflows.tar.gz
. You need to put it in the main directory

To study the MONTAGE graph, you can launch the following script:
$ ./main.sh 1 $c 0 11 $n 0 0 0 $lambda 0 0

where:
* $c should be: 
	- 0 if the checkpoint time is proportionnal (0.1 times) to the execution time of the task
	- x > 0 if the checkpoint time is x for all tasks
	- x < 0 if the checkpoint time is a random number between 0 and -x for all tasks

* $n is the number of task in the workflow (only 50, 100, 200, 300, ..., 1000 are available in the MONTAGE library)

* $lambda is the MTBF
