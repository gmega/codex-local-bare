#!/usr/bin/env bash

logfile=$1
shift
"$@" | tee "$1"