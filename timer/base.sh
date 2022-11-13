#!/bin/bash

AwkLib="/root/awklib"

barkId="xxxxxxxxxxxxxxxxxxx"
logPath="/tmp/timer/BARK/bark.log-"`date "+%Y%m%d"`

bark(){
  cont=$1
  curl -s "https://api.day.app/${barkId}/${cont}?sound=choo"
}

barkAndLog(){
  bark $1
  echo `date "+%T"`"  "$1 >> $logPath
}

forData(){
  len=${#data[@]}
  for((i=0;i<len;i+=3))
  do
    call ${data[i]} ${data[i+1]} ${data[i+2]}
  done
}
