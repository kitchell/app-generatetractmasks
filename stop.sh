#!/bin/bash

if [ -f finished ]; then
    echo "job has already finished"
    exit 1
fi

if [ $ENV == "IUHPC" ]; then
    jobid=`cat jobid`
    echo "running qdel $jobid"
    qdel $jobid
fi

if [ $ENV == "VM" ]; then
    pid=`cat pid`
    echo "running kill" 
    kill $pid
fi
