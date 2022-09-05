##  echo '{"a":123,"b":[1,-3.0],"c":"ccd"}' | gawk -i json.awk 'END{pjson(result)}'

function get(_sp){ return substr(str, idx, _sp); }
function step(_sp){ idx+=_sp; }
function check(pp){ if(get(length(pp)) == pp){ step(length(pp)); }else{ exit 1; } }
## Skip SkipSpace SkipDot
function skip(pp, greed){
  if(get(1) == pp){
    step(1);
    if(greed == "true"){ skip(pp, greed); } 
  } 
}
function ss(){skip(" ", "true" );}
function sd(){skip(",", "false");}

function keyfc(){
  c = 0;
  for(i = idx; ; i++){
    if(substr(str, i, 1) == "\""){ break; }else{ c++; }
  }
  r = get(c); step(c + 1); return r;
}
function strfc(result, key){
  c = 0;
  for(i = idx; ; i++){
    if(substr(str, i, 1) == "\"" && substr(str, i-1, 1) != "\\"){ break; }else{ c++; }
  }
  result[key] = get(c); step(c + 1);
}
function numfc(result, key){
  c = 0;
  for(i = idx; ; i++){
    if(substr(str, i, 1) ~ /[0-9.\-]/){ c++; }else { break; }
  }
  result[key] = get(c); step(c);
}
function boolfc(result, key){
  if(get(1) == "t"){
    check("true"); result[key] = "true";
  }else if(get(1) == "f"){
    check("false"); result[key] = "false";
  }
}
function arrfc(result, _lpi){
  _lpi = 0;
  while(1 == 1){
    ss();
    if(get(1) != "]"){
      dp(result, _lpi++); ss(); sd();
    }else{
      step(1); ss(); break;
    }
  }
}
function objfc(result, _tkey){
  while(1 == 1){
    ss();
    if(get(1) == "}"){
      step(1); ss(); break;
    }
    check("\"");
    _tkey = keyfc();
    ss(); check(":"); ss();
    dp(result, _tkey); ss(); sd();
  }
}
function jt(tk){
  if(tk == "["){return "array";}
  if(tk == "{"){return "object";}
  if(tk == "\""){return "string";}
  if(tk ~ /[0-9\-]/){return "number";}
  if(tk == "t" || tk == "f"){return "boolean";}
}
function dp(result, key, _type){
  _type = jt(get(1));
  if(_type == "array"){
    result[key]["_type_"] = _type;
    step(1); arrfc(result[key]);
  }else if(_type == "object"){
    result[key]["_type_"] = _type;
    step(1); objfc(result[key]);
  }else if(_type == "string"){
    step(1); strfc(result, key);
  }else if(_type == "number"){
    numfc(result, key);
  }else if(_type == "boolean"){
    boolfc(result, key);
  }
}
function pjson(result, ind, _type, _arridx){
  if(typeof(result) == "array"){
    _type = result["_type_"];
    if(_type == "object"){
      print ind"{";
      for(x in result){
        if(x == "_type_"){ continue; }
        if(typeof(result[x]) == "array"){
          print ind, x, ":";
          pjson(result[x], ind"  ");
        }else{
          print ind, x, ":", result[x];
        }
      }
      print ind"}";
    }else if(_type == "array"){ 
      print ind"[";
      for(_arridx = 0; _arridx < length(result) - 1; _arridx++){
        if(typeof(result[_arridx]) == "array"){
          pjson(result[_arridx], ind"  ");
        }else{
          print ind, result[_arridx];
        }
      }
      print ind"]";
    }
  }else{
    print ind, result;
  }
}

BEGIN{tLen=0; str=""; idx=1; result["_type_"] = "object";}
{
  str=$0; tLen = length(str); ss();
  if(tLen < idx){ exit 1; }
  _type = jt(get(1));
  if(_type != "array" && _type != "object"){ exit 1; }
  dp(result, ".");
}