name=${12}
p=${5}
for lambda in 0.0000005 0.000001 0.000005 0.00001 0.00005 0.0001 0.0005 0.001 0.005 0.01; do
	echo "begin ${lambda} ${name}"
	if [ -f results/${name}_$2_${p}_${lambda}_${10}.results ]; then
		echo "Tests have already been done"
	else
		for iter in `seq 0 19`; do 
			python pegasus_parser.py SyntheticWorkflows/${name}/${name}.n.${p}.${iter}.dax > ${name}.n.${p}.${iter}.dag
			if [ -f param_$1_$2_$3_$5_$6_$7_$8_$9_${10} ]; then
				echo "${lambda}\n${10}\n$5\n$1\n$2\n$3" >  param_$1_$2_$3_$5_$6_$7_$8_${lambda}_${10}
				./script.native param_$1_$2_$3_$5_$6_$7_$8_${lambda}_${10} ${name}.n.${p}.${iter}.dag >> results/${name}_$2_${p}_${lambda}_${10}.results
				if [ ${lambda} -ne $9 ]; then
					rm param_$1_$2_$3_$5_$6_$7_$8_${lambda}_${10}
				fi
			else
				echo "Stop tests"
			fi
			rm ${name}.n.${p}.${iter}.dag
		done
	fi
	echo "end ${lambda} ${name}"
done
