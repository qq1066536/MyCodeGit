#!/bin/bash
cd ../tar_gz
ls *.tar.gz > ls.list
for TAR in `cat ls.list`
do    
	echo "正在解压"$TAR
	tar -zxf $TAR
done
rm -rf ls.list
#find ./ -type d -exec rm -rf {} \;
