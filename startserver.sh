#!/usr/bin/env bash

export FLASK_APP=./server.py
FLASK_HOST="127.0.0.1"
FLASK_DEBUG=0


for i in "$@"
do
    case ${i} in
        -d|--debug)
            FLASK_DEBUG=1
            shift
       ;;
        -h=*|--host=*)
            FLASK_HOST="${i#*=}"
            shift
        ;;
        *)
            echo "Unknown parameter"
            # default case
            shift
        ;;
    esac
done

if [[ ${FLASK_DEBUG} -eq 1 ]] ; then
    echo "+-------------------------------------------------------------------+"
    echo "|Warning: If running in a prod environment, kill the process and    |"
    echo "|restart the server without the debug flag. This flag enables an    |"
    echo "|attacker to execute arbitrary code.                                |"
    echo "+-------------------------------------------------------------------+"
fi

echo "Launching server. Listening on ${FLASK_HOST}:5000"
flask run --host=${FLASK_HOST}