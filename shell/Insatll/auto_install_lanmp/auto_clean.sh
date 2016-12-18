#!/bin/bash
find . -path './*' -prune -a -type d -exec rm -rf {} \;

