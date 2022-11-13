#!/bin/bash

source /root/timer/base.sh

data=(
BTCUSDT 0.4 0.3
##ETHUSDT 0.1 -0.1
)

call(){
symbol=$1
up=$2
down=$3

positionDelta=`curl -s "https://fapi.binance.com/futures/data/globalLongShortAccountRatio?symbol=${symbol}&period=5m&limit=1" |\
  awk -i ${AwkLib}/json.awk '{parserJson($0,json);print json[0]["longAccount"] - json[0]["shortAccount"]}'`

pd=`echo $positionDelta | awk -vlimita="$up" -vlimitb="$down" '{if($1>=limita || $1<=limitb){print $1}}'`

if [ -n "$pd" ] ;then
  bark "WARNING.UF.${symbol}.PD.${pd}"
fi
}

forData
