#!/bin/bash

source ./base.sh

data=(
BTCUSDT 0.5 -0.5
ETHUSDT 0.4 -0.4
)

call(){
symbol=$1
up=$2
down=$3

rfile="${BasePath}/AD/AD-UFOP-${symbol}"
if [ ! -f "$rfile" ]; then
  echo `date +%s` > $rfile
fi
stime=`awk '{print $1}' $rfile`

result=`curl -s "https://fapi.binance.com/futures/data/openInterestHist?symbol=${symbol}&period=15m&limit=100" |\
  awk -i ${jsonLib} '
  { parserJson($0,json);
    for(i=0;i<length(json)-1;i++){
      print json[i]["timestamp"]/1000,int(json[i]["sumOpenInterestValue"]/10000)/10000;
    }
  }' | sort -nr |\
  awk -vlimita="$up" -vlimitb="$down" -vst="$stime" '
  NR==1{ts=$1;base=$2;} 
  NR>1&&$1>=st&&base>0{dt=base-$2;if(dt>=limita || dt<=limitb){print ts,dt;exit;}}'`

if [ -n "$result" ] ;then
  echo $result > $rfile
  dt=`echo $result | awk '{print $2}'`
  bark "WARNING.UF.${symbol}.OV.AD.${dt}"
fi
}

forData
