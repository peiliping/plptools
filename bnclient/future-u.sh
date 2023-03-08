#!/bin/bash

source ./functions.sh

Host="https://fapi.binance.com"

getPositions(){
  local path="/fapi/v2/account"
  sendRequest "GET" $Host $path
  [[ $? -gt  0 ]] && return 1
  echo $HttpResult | awk -i ${AwkLib}/json.awk '
  {
    parserJson($0, json);
    for(i=0; i<length(json["positions"])-1; i++){
      if(json["positions"][i]["positionAmt"] + 0 != 0){
        print json["positions"][i]["symbol"],json["positions"][i]["positionSide"],json["positions"][i]["positionAmt"],json["positions"
][i]["entryPrice"];
      }
    }
    for(i=0; i<length(json["assets"])-1; i++){
      if(json["assets"][i]["marginBalance"] + 0 != 0){
        print json["assets"][i]["asset"],json["assets"][i]["marginBalance"];
      }
    }
  }'
}

getOpenOrders(){
  local path="/fapi/v1/openOrders"
  sendRequest "GET" $Host $path
  [[ $? -gt  0 ]] && return 1
  echo $HttpResult | awk -i ${AwkLib}/json.awk '{parserJson($0, json);printJson(json);}'
}

getBookTicker(){
  local path="/fapi/v1/ticker/bookTicker"
  local symbol=`echo $1 | tr a-z A-Z`
  local params="symbol=${symbol}"
  sendSimpleRequest "GET" $Host $path $params
  [[ $? -gt  0 ]] && return 1
  echo $HttpResult | awk -i ${AwkLib}/json.awk '{parserJson($0, json);printJson(json);}'
}

getOrder(){
  local path="/fapi/v1/order"
  local symbol=`echo $1 | tr a-z A-Z`
  local key=`getOrderIdType $2`
  local value=$2
  local params="symbol=${symbol}&${key}=${value}"
  sendRequest "GET" $Host $path $params
  [[ $? -gt  0 ]] && return 1
  echo $HttpResult | awk -i ${AwkLib}/json.awk '{parserJson($0, json);printJson(json);}'
}

getHistoryOrder(){
  local path="/fapi/v1/allOrders"
  local symbol=`echo $1 | tr a-z A-Z`
  local params="symbol=${symbol}"
  sendRequest "GET" $Host $path $params
  [[ $? -gt  0 ]] && return 1
  echo $HttpResult | awk -i ${AwkLib}/json.awk '{parserJson($0, json);printJson(json);}'
}

cancelOpenOrder(){
  local path="/fapi/v1/order"
  local symbol=`echo $1 | tr a-z A-Z`
  local key=`getOrderIdType $2`
  local value=$2
  local params="symbol=${symbol}&${key}=${value}"
  sendRequest "DELETE" $Host $path $params
  [[ $? -gt  0 ]] && return 1
  echo $HttpResult | awk -i ${AwkLib}/json.awk '{parserJson($0, json);printJson(json);}'
}

marketTrade(){
  local path="/fapi/v1/order"
  local symbol=`echo $1 | tr a-z A-Z`
  local side=`echo $2 | tr a-z A-Z`
  local positionSide=$3
  local quantity=$4
  local params="symbol=${symbol}&side=${side}&positionSide=${positionSide}&type=MARKET&quantity=${quantity}"
  sendRequest "POST" $Host $path $params
  [[ $? -gt  0 ]] && return 1
  echo $HttpResult | awk -i ${AwkLib}/json.awk '{parserJson($0, json);printJson(json);}'
}

limitTrade(){
  local path="/fapi/v1/order"
  local symbol=`echo $1 | tr a-z A-Z`
  local side=`echo $2 | tr a-z A-Z`
  local positionSide=$3
  local price=$4
  local quantity=$5
  local params="symbol=${symbol}&side=${side}&positionSide=${positionSide}&type=LIMIT&timeInForce=GTC&price=${price}&quantity=${quantity}"
  sendRequest "POST" $Host $path $params
  [[ $? -gt  0 ]] && return 1
  echo $HttpResult | awk -i ${AwkLib}/json.awk '{parserJson($0, json);printJson(json);}'
}

if [ -z "$*" ];then
  echo "============================================================"
  echo "1. getPositions"
  echo "2. getOpenOrders"
  echo "3. getBookTicker {symbol}"
  echo "4. getOrder {symbol} {orderId or clientOrderId}"
  echo "5. getHistoryOrder {symbol}"
  echo "6. cancelOpenOrder {symbol} {orderId or clinetOrderId}"
  echo "7. marketTrade {symbol} {buy or sell} {long or short} {quantity}"
  echo "8. limitTrade  {symbol} {buy or sell} {long or short} {price} {quantity}"
  echo "============================================================"
else
  echo $*
  echo "------------------------------------------------------------"
  eval $*
fi
