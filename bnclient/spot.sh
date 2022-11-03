#!/bin/bash

source /root/binance/functions.sh
AwkLib="/root/awklib"

Host="https://api.binance.com"

getAssets(){
  local path="/sapi/v3/asset/getUserAsset"
  sendRequest "POST" $Host $path
  [[ $? -gt  0 ]] && return 1
  echo $HttpResult | awk -i ${AwkLib}/json.awk '
  {
    parserJson($0, json);
    for(i=0; i<length(json)-1; i++){
      print json[i]["asset"]"\t"json[i]["free"]"\t"json[i]["locked"];
    }
  }' | sort -k2nr
}

getOpenOrders(){
  local path="/api/v3/openOrders"
  sendRequest "GET" $Host $path
  [[ $? -gt  0 ]] && return 1
  echo $HttpResult | awk -i ${AwkLib}/json.awk '{parserJson($0, json);printJson(json);}'
}

getBookTicker(){
  local path="/api/v3/ticker/bookTicker"
  local symbol=`echo $1 | tr a-z A-Z`
  local params="symbol=${symbol}"
  sendSimpleRequest "GET" $Host $path $params
  [[ $? -gt  0 ]] && return 1
  echo $HttpResult | awk -i ${AwkLib}/json.awk '{parserJson($0, json);printJson(json);}'
}

getOrder(){
  local path="/api/v3/order"
  local symbol=`echo $1 | tr a-z A-Z`
  local key=`getOrderIdType $2`
  local value=$2
  local params="symbol=${symbol}&${key}=${value}"
  sendRequest "GET" $Host $path $params
  [[ $? -gt  0 ]] && return 1
  echo $HttpResult | awk -i ${AwkLib}/json.awk '{parserJson($0, json);printJson(json);}'
}

cancelOpenOrder(){
  local path="/api/v3/order"
  local symbol=`echo $1 | tr a-z A-Z`
  local key=`getOrderIdType $2`
  local value=$2
  local params="symbol=${symbol}&${key}=${value}"
  sendRequest "DELETE" $Host $path $params
  [[ $? -gt  0 ]] && return 1
  echo $HttpResult | awk -i ${AwkLib}/json.awk '{parserJson($0, json);printJson(json);}'
}

marketTrade(){
  local path="/api/v3/order"
  local symbol=`echo $1 | tr a-z A-Z`
  local side=$2
  local quantity=$3
  local params="symbol=${symbol}&side=${side}&type=MARKET&quantity=${quantity}"
  sendRequest "POST" $Host $path $params
  [[ $? -gt  0 ]] && return 1
  echo $HttpResult | awk -i ${AwkLib}/json.awk '{parserJson($0, json);printJson(json);}'
}

limitTrade(){
  local path="/api/v3/order"
  local symbol=`echo $1 | tr a-z A-Z`
  local side=$2
  local price=$3
  local quantity=$4
  local params="symbol=${symbol}&side=${side}&type=LIMIT&timeInForce=GTC&price=${price}&quantity=${quantity}"
  sendRequest "POST" $Host $path $params
  [[ $? -gt  0 ]] && return 1
  echo $HttpResult | awk -i ${AwkLib}/json.awk '{parserJson($0, json);printJson(json);}'
}

if [ -z "$*" ];then
  echo "============================================================"
  echo "1. getAssets"
  echo "2. getOpenOrders"
  echo "3. getBookTicker {symbol}"
  echo "4. getOrder {symbol} {orderId or clientOrderId}"
  echo "5. cancelOpenOrder {symbol} {orderId or clinetOrderId}"
  echo "6. marketTrade {symbol} {buy or sell} {quantity}"
  echo "7. limitTrade  {symbol} {buy or sell} {price} {quantity}"
  echo "============================================================"
else
  echo $*
  echo "------------------------------------------------------------"
  eval $*
fi
