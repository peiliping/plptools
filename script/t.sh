curl -s "https://www.binance.com/api/v3/klines?symbol=BTCUSDT&interval=1h&limit=168" | \
gawk -i json.awk -i lr.awk '
{ 
  parserJson($0, json);
  for(i=0; i<168; i++){
    source[i + 1] = (json["_root_"][i][1] + json["_root_"][i][2] + json["_root_"][i][3] + json["_root_"][i][4])/4;
  }
}
END{
  lr(source, result);
  print result["U"], result["M"], result["D"];
}'