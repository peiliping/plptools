#!/bin/bash

source /root/timer/base.sh

data=(
BTCUSDT 0.1 -0.1
ETHUSDT 0.1 -0.1
)

call(){
symbol=$1
up=$2
down=$3

rfile="/tmp/timer/AD/AD-UFLS-${symbol}"

if [ ! -f "$rfile" ]; then
  echo `date +%s` > $rfile
fi
stime=`awk '{print $1}' $rfile`

result=`curl -s "https://fapi.binance.com/futures/data/globalLongShortAccountRatio?symbol=${symbol}&period=15m&limit=100" |\
  awk -i ${AwkLib}/json.awk '
  { parserJson($0,json);
    for(i=0;i<length(json)-1;i++){
      print json[i]["timestamp"]/1000,json[i]["longAccount"]-json[i]["shortAccount"];
    }
  }' | sort -nr |\
  awk -vlimita="$up" -vlimitb="$down" -vst="$stime" '
  NR==1{ts=$1;base=$2;} 
  NR>1&&$1>=st{dt=base-$2;if(dt>=limita || dt<=limitb){print ts,dt;exit;}}'`

if [ -n "$result" ] ;then
  echo $result > $rfile
  dt=`echo $result | awk '{print $2}'`
  bark "WARNING.UF.${symbol}.PD.AD.${dt}"
fi
}

forData
