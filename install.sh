#!/bin/bash
# Use only if you need to perform changes on the user system such as installing software
[[ -z $(which mpg321) ]] && sudo apt-get install mpg321
[[ -z $(which wget) ]] && sudo apt-get install wget
[[ -z $(which bc) ]] && sudo apt-get install bc
[[ -z $(which jq) ]] && sudo apt-get install jq
[[ -z $(which sponge) ]] && sudo apt-get install sponge