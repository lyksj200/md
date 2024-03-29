#!/bin/bash
file_path="./" 
timeout_count=500
interval=10
timeout_error="time out error"
pdbid=$1

# usage：
# using prepwizard to preprocess protein and ligand for MD prepare
# ./run_maestro.sh pdbid ligandid_1 ligandid_2 ...


# prepare pdb

prepwizard -delwater_hbond_cutoff 3 ${pdbid}.pdb minimize.pdb
file_path="./minimize.pdb" 


for ((i=1; i<=${timeout_count}; i ++))
do
    if [ -e "$file_path" ]; then
        echo "prepare finish"
        break
    else
    	echo "preparing"
    	sleep $interval
    fi
done


if [ ${i} -eq ${timeout_count} ]; then

	echo "$timeout_error"
	exit 1
fi



cat minimize.pdb |grep ATOM > protein.pdb

# process ligand

i=0
for var in $@
do
	i=$((i + 1))
	if [ $i -eq 1 ];then
		continue
	fi
	file_id="$var"
	echo ligand id is ${file_id}
	cat minimize.pdb |grep ${file_id} > ${file_id}.pdb
	structconvert -ipdb ${file_id}.pdb -osd ${file_id}.sdf
done
