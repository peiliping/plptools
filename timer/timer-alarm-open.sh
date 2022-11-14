#!/bin/bash

source ./base.sh

data=(
BTCUSDT 21 19
##call ETHUSDT 16 13
)

call(){
symbol=$1
up=$2
down=$3

value=`curl -s "https://fapi.binance.com/futures/data/openInterestHist?symbol=${symbol}&period=5m&limit=1" |\
  awk -i ${jsonLib} '{parserJson($0,json);value=json[0]["sumOpenInterestValue"];print int(value/1000000)/100}'`

result=`echo $value | awk -vlimita="$up" -vlimitb="$down" '{if($1>0 && ($1>=limita || $1<=limitb)){print $1}}'`

if [ -n "$result" ] ;then
  bark "WARNING.UF.${symbol}.OV.${result}"
fi
}

forData
