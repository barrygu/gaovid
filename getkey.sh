#!/bin/bash

url=$1
echo $url | sed -ne "s/.*\/video\/\([0-9a-f]\+\)\/.*/\1/p"
