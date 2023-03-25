#!/bin/bash

set -e
set -x

cp -rf ~/.ssh .
docker build --build-arg TERM=$TERM --build-arg COLORTERM=$COLORTERM -t baseline .
rm -rf .ssh
