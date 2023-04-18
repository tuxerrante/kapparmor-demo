#!/bin/bash
cd .    # to avoid Make "getcwd: No such file or directory" error
make
make test
make container
make push
