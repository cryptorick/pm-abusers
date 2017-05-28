#!/bin/sh

authlog=/var/log/authlog
blockCountThresh=40

grep -E 'Failed password|BREAK-IN' $authlog |
  awk '{ match($0,/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/) # extract IPs ...
         print substr($0,RSTART,RLENGTH)            # ... print them.
       }' | sort -n | uniq -c |
  awk '{ count=$1; ip=$2;
         split(ip, a, "."); block=a[1] "." a[2];
         blockCount[block] += count;
         ++blockNumAddrs[block];
       }
       END {
         for ( block in blockCount )
           if ( (blockCount[block] >= '${blockCountThresh}') ||
                (blockNumAddrs[block] > 2) )
             print block ".0.0/16";
       }' | sort -n
