#!/bin/bash

ApiKey=""
SecretKey=""

HttpCode=""
HttpResult=""

## 对参数数据进行签名
signature(){
  echo -n "$1" | openssl dgst -sha256 -hmac "${SecretKey}" | awk '{print "signature="$2}'
}

## 添加时间校对参数
addTimeParams(){
  local tsParams="recvWindow=10000&timestamp="`date +%s`"000"
  if [ -z "$1" ] ;then
    echo $tsParams
  else
    echo $1"&"$tsParams
  fi
}

## 发送带签名的请求
sendRequest(){
  HttpCode=""
  HttpResult=""
  local method=$1
  local host=$2
  local path=$3
  local params=$4
  params=`addTimeParams ${params}`
  local sig=`signature ${params}`
  params=$params"&"$sig
  local result=`curl -s -w "\t%{http_code}" -H "X-MBX-APIKEY: ${ApiKey}" -X ${method} $host""$path"?"$params`
  HttpCode=`echo $result | awk '{ print $NF}'`
  HttpResult=`echo $result | awk '{ print substr($0,1,length($0)-4); }'`
  if [ $HttpCode -eq 200 ];then
    return 0
  else
    echo $HttpResult
    return 1
  fi
}

sendSimpleRequest(){
  HttpCode=""
  HttpResult=""
  local method=$1
  local host=$2
  local path=$3
  local params=$4
  local result=`curl -s -w "\t%{http_code}" -X ${method} $host""$path"?"$params`
  HttpCode=`echo $result | awk '{ print $NF}'`
  HttpResult=`echo $result | awk '{ print substr($0,1,length($0)-4); }'`
  if [ $HttpCode -eq 200 ];then
    return 0
  else
    echo $HttpResult
    return 1
  fi
}

## 识别OrderId类型
getOrderIdType(){
  expr $1 "+" 1 &> /dev/null
  if [ $? -eq 0 ];then
    echo "orderId"
  else
    echo "origClientOrderId"
  fi
}
