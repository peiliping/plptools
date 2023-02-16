#!/bin/bash

source ./base.sh

list=`curl -s "https://fapi.binance.com/fapi/v1/exchangeInfo" | awk -i ${jsonLib} '
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
  awk -i ${jsonLib} '{parserJson($0,json);print json[0][4]}'`

open=`curl -s "https://fapi.binance.com/futures/data/openInterestHist?symbol=${symbol}&period=5m&limit=1" |\
  awk -i ${jsonLib} '{parserJson($0,json);value=json[0]["sumOpenInterestValue"];print int(value/1000000)/100}'`

pd=`curl -s "https://fapi.binance.com/futures/data/globalLongShortAccountRatio?symbol=${symbol}&period=5m&limit=1" |\
  awk -i ${jsonLib} '{parserJson($0,json);print json[0]["longAccount"] - json[0]["shortAccount"]}'`

echo `date "+%s"` $close $open $pd >> "${BasePath}/SCAN/${symbol}"
echo $symbol `date "+%s"` $close $open $pd >> "${BasePath}/SCAN/ZZZZZLAST"
}

rm -rf "${BasePath}/SCAN/ZZZZZLAST"

for name in $list
do
  call $name
  sleep 1s
done

result=`awk '$5<0.1{c++;}END{if(c<=25){print c;}}' ${BasePath}/SCAN/ZZZZZLAST `
if [ -n "$result" ] ;then
  bark "WARNING.UF.SCAN.${result}"
fi