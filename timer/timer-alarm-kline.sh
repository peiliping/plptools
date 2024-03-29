#!/bin/bash

source ./base.sh

data=(
BTCUSDT 18000 16400
##ETHUSDT 1300  1250
)

call(){
symbol=$1
up=$2
down=$3

close=`curl -s "https://www.binance.com/api/v3/klines?symbol=${symbol}&interval=1h&limit=1"  |\
  awk -i ${jsonLib} '{parserJson($0,json);print json[0][4]}'`

mm=`echo $close | awk -vlimita="$up" -vlimitb="$down" '{if($1>limita || $1<limitb){ if($1>0){print $1+0} }}'`

if [ -n "$mm" ] ;then
  bark "WARNING.SPOT.${symbol}.Close.${mm}"
fi
}

forData
