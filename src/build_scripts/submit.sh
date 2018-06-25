#!/bin/zsh

export NUMBER_JOBS=6
export PROGRAM=root
export LOGS=${PROGRAM}_logs

rm -rf $LOGS
mkdir $LOGS
qsub -l nodes=1:ppn=$NUMBER_JOBS -S /bin/zsh -q griper -N build -e $LOGS -o $LOGS -V run.sh
