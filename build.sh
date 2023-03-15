#!/bin/bash

set -e
set -x

docker build --build-arg TERM=$TERM --build-arg COLORTERM=$COLORTERM -t baseline .
