#!/bin/bash

set -e
set -x

cp -rf ~/.ssh .
docker.lima build --build-arg TERM=xterm-256color --build-arg COLORTERM=truecolor -t baseline .
rm -rf .ssh
