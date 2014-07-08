if [ -f results/MONTAGE_$2_${12}_$9_${10}.results ]; then
	echo "Tests have already been done"
else
	for iter in `seq 0 19`; do 
		python pegasus_parser.py SyntheticWorkflows/MONTAGE/MONTAGE.n.$5.${iter}.dax > MONTAGE.n.$5.${iter}.dag
		./script.native param_$1_$2_$3_$5_$6_$7_$8_$9_${10} MONTAGE.n.$5.${iter}.dag >> results/MONTAGE_$2_${12}_$9_${10}.results
		rm MONTAGE.n.$5.${iter}.dag
	done
fi
