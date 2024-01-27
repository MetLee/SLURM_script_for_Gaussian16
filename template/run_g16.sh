#!/bin/bash

#SBATCH -J JOB_NAME
#SBATCH -o JOB_NAME.out
#SBATCH -p v6_384
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 48
#SBATCH --mem=100G

WORKDIR=$SLURM_SUBMIT_DIR
JOBNAME=JOB_NAME

# environment
export g16root=~/Gaussian16
source $g16root/g16/bsd/g16.profile
mkdir -p ~/tmp/$SLURM_JOB_ID
export GAUSS_SCRDIR=~/tmp/$SLURM_JOB_ID

# clean
cd $WORKDIR
rm *.fchk *_DONE *_FAILED *_running 2>/dev/null

# job start
echo "------[$JOBNAME]------"
touch $SLURM_JOB_ID
touch ${HOSTNAME}_running
echo "Job [$JOBNAME] start at" `date`
printf "\n"

# job runing
echo "Job [$JOBNAME] running host is:  $HOSTNAME"
echo "Job [$JOBNAME] running path is:  $WORKDIR"
printf "\n"
g16 <$JOBNAME.gjf 1>$JOBNAME.log

# job end
rm $SLURM_JOB_ID
rm ${HOSTNAME}_running
echo "------[$JOBNAME]------"

# result check
if [ "$( tail -n 1 $JOBNAME.log | grep "Normal termination of Gaussian" )" ]; then
    echo "Job [$JOBNAME] finish at" `date`
    echo "Job [$JOBNAME] completed, congratulations!"
    touch   ${SLURM_JOB_ID}_DONE

    # formchk
    chk_names=$(ls *.chk)
    for chk_name in $chk_names; do
        formchk $chk_name 2>/dev/null 1>&2
    done
else
    echo "Job [$JOBNAME] failed" `date`
    touch   ${SLURM_JOB_ID}_FAILED
fi

# clean
rm -rf $GAUSS_SCRDIR

printf "\n"
echo "Job finally stoped at" `date`
printf "\n"
