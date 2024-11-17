#!/bin/bash

find "./mfun" -type f -name "*.sh" -exec sed -i 's/\r$//' {} \;