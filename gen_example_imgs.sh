#!/usr/bin/env bash

nimble build && ./cardgenerator -o:./examples/output -f:100 -d:./examples/resources -s -c:255,255,255,255 -z:50
