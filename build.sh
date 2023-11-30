#!/bin/bash

set -e
set -x

cp -rf ~/.ssh .
cp -rf ~/.codeium .
docker.lima build --build-arg TERM=xterm-256color --build-arg COLORTERM=truecolor -t baseline .
rm -rf .codeium
rm -rf .ssh
