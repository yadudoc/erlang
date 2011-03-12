#!/bin/bash

A=`head --lines=10 ./README`
echo "$A" >> README.tmp
for i in `ls *.erl`
do    
    Value=`head --lines=1 ./$i | grep %`;
        if [ $? -eq 0 ]
	then
	    echo "$i $Value" >> README.tmp
	fi
done

rm ./README;
mv ./README.tmp ./README