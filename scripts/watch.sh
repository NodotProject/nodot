#!/bin/bash

DIR_TO_WATCH="addons/nodot"
COMMAND="./scripts/watch_generate_docs.sh"
 
trap "echo Exited!; exit;" SIGINT SIGTERM
while [[ 1=1 ]]
do
  watch --chgexit -n 1 "ls --all -l --recursive --full-time ${DIR_TO_WATCH} | sha256sum" && ${COMMAND}
  sleep 1
done