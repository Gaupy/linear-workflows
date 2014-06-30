#!/bin/sh

##  experiment  param_$1_$2_$3_$5_$6_$7_$8_$9_${10}eters

#read -p 'experiment/graph number: ' var1 
#read -p 'c number: ' var2 
#read -p 'r number: ' var3

##  ggen  param_$1_$2_$3_$5_$6_$7_$8_$9_${10}eters:
#read -p 'random seed: ' var4
#read -p 'ntasks: ' var5
#read -p 'nedges (gnm) or nlayer (layer) or outdegree (FiFo) or ntotalorders (RO): ' var6
#read -p 'proba  param_$1_$2_$3_$5_$6_$7_$8_$9_${10}eter (gnp+layer) or indegree (FiFo): ' var7
#read -p 'weight tasks: ' var8

##  constant known
#read -p 'lambda: ' var9
#read -p 'downtime: ' var10

#read -p 'number of simulations: ' var11


cd ..
echo "$9\n${10}\n$5\n$1\n$2\n$3" >  param_$1_$2_$3_$5_$6_$7_$8_$9_${10}
ocamlbuild -lib unix script.native
case $1 in
	0) #one tree
	./script.native param_$1_$2_$3_$5_$6_$7_$8_$9_${10} example_files/dump.1.4.amd.Lin.Lin-1213.tree
	;;
	1) #graphs are gnp
	for iter in `seq 1 ${11}`; do
		r=$(echo "$4+${iter}*10" | bc) #changing random seed for all generation
		GSL_RNG_SEED=$r ggen -l=0 generate-graph gnp $5 $7 | GSL_RNG_TYPE=ranlux GSL_RNG_SEED=$r ggen -l=0 add-property exponential $8 > dag_$1_$2_$3_$5_$6_$7_$8_$9_${10}.dag
		./script.native param_$1_$2_$3_$5_$6_$7_$8_$9_${10} dag_$1_$2_$3_$5_$6_$7_$8_$9_${10}.dag
	done
#	rm dag_$1_$2_$3_$5_$6_$7_$8_$9_${10}.dag param_$1_$2_$3_$5_$6_$7_$8_$9_${10}
	;;
	2) #graphs are gnm
	for iter in `seq 1 ${11}`; do
		r=$(echo "$4+${iter}*10" | bc) #changing random seed for all generation
		GSL_RNG_TYPE=ranlux GSL_RNG_SEED=$r ggen -l=0 generate-graph gnm $5 $6 | GSL_RNG_TYPE=ranlux GSL_RNG_SEED=$r ggen -l=0 add-property exponential $8 > dag_$1_$2_$3_$5_$6_$7_$8_$9_${10}.dag
		./script.native  param_$1_$2_$3_$5_$6_$7_$8_$9_${10} dag_$1_$2_$3_$5_$6_$7_$8_$9_${10}.dag
	done
	rm dag_$1_$2_$3_$5_$6_$7_$8_$9_${10}.dag param_$1_$2_$3_$5_$6_$7_$8_$9_${10}
	;;
	3) #graphs are fifo
	for iter in `seq 1 ${11}`; do
		r=$(echo "$4+${iter}*10" | bc) #changing random seed for all generation
		GSL_RNG_TYPE=ranlux GSL_RNG_SEED=$r ggen -l=0 generate-graph fifo $5 $6 $7 | GSL_RNG_TYPE=ranlux GSL_RNG_SEED=$r ggen -l=0 add-property exponential $8 > dag_$1_$2_$3_$5_$6_$7_$8_$9_${10}.dag
		./script.native  param_$1_$2_$3_$5_$6_$7_$8_$9_${10} dag_$1_$2_$3_$5_$6_$7_$8_$9_${10}.dag
	done
	rm dag_$1_$2_$3_$5_$6_$7_$8_$9_${10}.dag param_$1_$2_$3_$5_$6_$7_$8_$9_${10}
	;;
	4) #graphs are lbl
	for iter in `seq 1 ${11}`; do
		r=$(echo "$4+${iter}*10" | bc) #changing random seed for all generation
		GSL_RNG_TYPE=ranlux GSL_RNG_SEED=$r ggen -l=0 generate-graph lbl $5 $6 $7 | GSL_RNG_TYPE=ranlux GSL_RNG_SEED=$r ggen -l=0 add-property exponential $8 > dag_$1_$2_$3_$5_$6_$7_$8_$9_${10}.dag
		./script.native  param_$1_$2_$3_$5_$6_$7_$8_$9_${10} dag_$1_$2_$3_$5_$6_$7_$8_$9_${10}.dag
	done
	rm dag_$1_$2_$3_$5_$6_$7_$8_$9_${10}.dag param_$1_$2_$3_$5_$6_$7_$8_$9_${10}
	;;
	5) #graphs are ro
	for iter in `seq 1 ${11}`; do
		r=$(echo "$4+${iter}*10" | bc) #changing random seed for all generation
		GSL_RNG_TYPE=ranlux GSL_RNG_SEED=$r ggen -l=0 generate-graph ro $5 $6 | GSL_RNG_TYPE=ranlux GSL_RNG_SEED=$r ggen -l=0 add-property exponential $8 > dag_$1_$2_$3_$5_$6_$7_$8_$9_${10}.dag
		./script.native  param_$1_$2_$3_$5_$6_$7_$8_$9_${10} dag_$1_$2_$3_$5_$6_$7_$8_$9_${10}.dag
	done
	rm dag_$1_$2_$3_$5_$6_$7_$8_$9_${10}.dag param_$1_$2_$3_$5_$6_$7_$8_$9_${10}
	;;
	* ) 
	echo "You have tried an expe_number that is not yet implemented."
	;;
esac
