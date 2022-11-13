#!/bin/bash

source /root/timer/base.sh

data=(
##BTCUSDT 4h 168
##ETHUSDT 4h 168

##BTCUSDT 1h 168
##ETHUSDT 1h 168
)

call(){
symbol=$1
interval=$2
count=$3

mm=`curl -s "https://www.binance.com/api/v3/klines?symbol=${symbol}&interval=${interval}&limit=${count}" |\
awk -i ${AwkLib}/json.awk -i ${AwkLib}/linear.awk -vct="${count}" '
{
  parserJson($0, json);
  for(i=0; i<ct; i++){source[i + 1] = (json[i][1] + json[i][2] + json[i][3] + json[i][4])/4;}
  cls=json[ct-1][4];
}
END{
  lr(source, result);
  if(cls > (result["U"] * 0.995)){print "UP";}
  if(cls < (result["D"] * 1.005)){print "DOWN";}
}'`

if [ -n "$mm" ] ;then
  bark "WARNING.SPOT.${symbol}.${interval}.LR.${mm}"
fi
}

forData
