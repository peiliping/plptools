#!/bin/bash

source ./functions.sh

Host="https://api.binance.com"

getAssets(){
  local path="/sapi/v3/asset/getUserAsset"
  sendRequest "POST" $Host $path
  [[ $? -gt  0 ]] && return 1
  fmtStr='%-15s\t%-15s\t%-15s\t%-15s\t%-15s\t%-15s\n'
  echo "" | awk -vfmt=${fmtStr} '{printf(fmt,"Name","Amount","Free","Lock","Price","Total")}';
  prices=$(curl -s "https://fapi.binance.com/fapi/v2/ticker/price")
  echo $HttpResult | awk -i ${AwkLib}/json.awk -vfmt=${fmtStr} -vpricesstr=${prices} '
  {
    parserJson($0, json);
    parserJson(pricesstr, pss);
    for(i=0;i<length(pss)-1;i++){
      psmap[pss[i]["symbol"]]=pss[i]["price"];
    }
    for(i=0; i<length(json)-1; i++){
      dp=psmap[json[i]["asset"]"USDT"];if(dp==""){dp=1;}
      dtotal=json[i]["free"]+json[i]["locked"];
      printf(fmt,json[i]["asset"],dtotal,json[i]["free"],json[i]["locked"],dp,dp*dtotal);
      total+=dp*dtotal;
    }
    printf(fmt,"Total","-","-","-","-",total);
  }' | sort -k6nr
}

transfer(){
  local path="/sapi/v1/asset/transfer"
  local asset=`echo $1 | tr a-z A-Z`
  local amount=$2
  local fromType=$3
  local toType=$4
  local params="asset=${asset}&amount=${amount}&type=${fromType}_${toType}"
  sendRequest "POST" $Host $path $params
  [[ $? -gt  0 ]] && return 1
  echo $HttpResult | awk -i ${AwkLib}/json.awk '{parserJson($0, json);printJson(json);}'
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

getHistoryOrder(){
  local path="/api/v3/allOrders"
  local symbol=`echo $1 | tr a-z A-Z`
  local params="symbol=${symbol}&limit=5"
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
  echo "2. transfer asset quantity fromType toType (type in MAIN,UMFUTURE,CMFUTURE)"
  echo "3. getOpenOrders"
  echo "4. getBookTicker {symbol}"
  echo "5. getOrder {symbol} {orderId or clientOrderId}"
  echo "6. getHistoryOrder {symbol}"
  echo "7. cancelOpenOrder {symbol} {orderId or clinetOrderId}"
  echo "8. marketTrade {symbol} {buy or sell} {quantity}"
  echo "9. limitTrade  {symbol} {buy or sell} {price} {quantity}"
  echo "============================================================"
else
  echo $*
  echo "------------------------------------------------------------"
  eval $*
fi
