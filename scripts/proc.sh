name=${12}
for p in 50 100 200 300 400 500 600 700; do 
	echo "begin ${p} ${name}"
	if [ -f results/${name}_$2_${p}_$9_${10}.results ]; then
		echo "Tests have already been done"
	else
		for iter in `seq 0 19`; do 
			python pegasus_parser.py SyntheticWorkflows/${name}/${name}.n.${p}.${iter}.dax > ${name}.n.${p}.${iter}.dag
			./script.native param_$1_$2_$3_$5_$6_$7_$8_$9_${10} ${name}.n.${p}.${iter}.dag >> results/${name}_$2_${p}_$9_${10}.results
			rm ${name}.n.${p}.${iter}.dag
		done
	fi
	echo "end ${p} ${name}"
done
