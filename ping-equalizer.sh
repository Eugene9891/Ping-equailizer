#!/bin/bash

VERSION="1.0.0"

function show_usage {
    echo
    echo "Ping equalizer for linux-based servers. Uses externally provided file with ips and pings "
    echo "Version: $VERSION | Author: Eugene9891"
    echo
    echo "Usage: $1 <file_with_ips_and_ping>"
    echo
    echo "Arguments:"
    echo "  <file_with_ips_and_ping>            : the ip address to limit the traffic for"
    echo
    echo "Changelog:"
    echo "v1.0.0 - initial version"
}

[ -n $1 ] && FILE=$1

if [ -z $FILE ]; then
    echo
    echo "No file defined"
    exit 0
fi

#erase the rules
sh tc.sh -r

#get two arrays
while IFS=' ' read -r s d; do
    Ips+=( "$s" )        
    Pings+=( "$d" )
done < $FILE

#find the biggest ping
IFS=$'\n' targetping=($(sort -r <<<"${Pings[*]}")); unset IFS

echo "Pings will be equalized to $targetping"

#Add all delays in traffic control
    for index in "${!Ips[@]}"
    do
        delay=$(echo "($targetping-${Pings[index]})"/2|bc);
        if [[ $delay =~ -.* ]]; then delay=0;fi; #zeroed if negative
        id=$(echo "$index+1"|bc)
        echo "The delay will be added for ${Ips[index]} for in/out is $delay with index $id"
        sh tc.sh -I=$id -d=$delay ${Ips[index]}
    done
