#!/bin/bash

if [ -z $SERVICE_DIR ]; then export SERVICE_DIR=`pwd`; fi

#clean up previous job (just in case)
rm -f finished
rm -r masks

if [ $ENV == "IUHPC" ]; then
	queue=""
	if [ $HPC == "KARST" ]; then
		queue="-q preempt"
	fi
	jobid=`qsub $queue $SERVICE_DIR/submit.pbs`
	echo $jobid > jobid
fi

if [ $ENV == "VM" ]; then
	nohup time $SERVICE_DIR/submit.pbs > stdout.log 2> stderr.log &
	echo $! > pid
fi
