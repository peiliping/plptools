#!/bin/bash

source /root/timer/base.sh

basePath="/tmp/timer/SCAN"

list=`curl -s "https://fapi.binance.com/fapi/v1/exchangeInfo" | awk -i ${AwkLib}/json.awk '
  { parserJson($0,json);
    for(i=0;i<length(json["symbols"])-1;i++){
      if(json["symbols"][i]["status"] == "TRADING" && json["symbols"][i]["contractType"] == "PERPETUAL"){
        print json["symbols"][i]["symbol"];
      }
    }
  }'`

call(){
symbol=$1

close=`curl -s "https://fapi.binance.com/fapi/v1/klines?symbol=${symbol}&interval=1h&limit=1" |\
  awk -i ${AwkLib}/json.awk '{parserJson($0,json);print json[0][4]}'`

open=`curl -s "https://fapi.binance.com/futures/data/openInterestHist?symbol=${symbol}&period=5m&limit=1" |\
  awk -i ${AwkLib}/json.awk '{parserJson($0,json);value=json[0]["sumOpenInterestValue"];print int(value/1000000)/100}'`

pd=`curl -s "https://fapi.binance.com/futures/data/globalLongShortAccountRatio?symbol=${symbol}&period=5m&limit=1" |\
  awk -i ${AwkLib}/json.awk '{parserJson($0,json);print json[0]["longAccount"] - json[0]["shortAccount"]}'`

echo `date "+%s"` $close $open $pd >> "${basePath}/${symbol}"
echo $symbol `date "+%s"` $close $open $pd >> "${basePath}/ZZZZZLAST"
}

rm -rf "${basePath}/ZZZZZLAST"

for name in $list
do
  call $name
  sleep 1s
done
