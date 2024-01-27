#!/bin/bash

file_names=$(ls *.gjf )
for file_name in $file_names; do
    file_name=${file_name%.gjf} # delete suffix
    rm -rf $file_name 2>/dev/null # delete dir

    mkdir $file_name
    mv $file_name.gjf $file_name.chk ./$file_name 2>/dev/null
    cd $file_name
    cp ~/template/run_g16.sh g_$file_name

    sed -i "s/JOB_NAME/$file_name/g" g_$file_name # replace

    sbatch g_$file_name # submit
    cd ..
done
