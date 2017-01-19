#!/bin/bash

files[]=`find / -name '*.log'`
for file in $files
do
	if [ `cat $file |wc -l ` -gt 2000 ];then
#		`tail -2000  $file` >$file
	fi		
done
