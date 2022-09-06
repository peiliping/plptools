function fatal(_sp){ print "index : ("idx") "_sp; exit 1; }
function get(_np){ return substr(str, idx, _np); }
function step(_np){ idx+=_np; }
function check(_sp){ if(get(length(_sp)) == _sp){ step(length(_sp)); }else{ fatal("check failed "_np); }  }
function skip(_sp, _greed){ if(get(length(_sp)) == _sp){ step(length(_sp)); if(_greed == "true"){ skip(_sp, _greed); } } }
function skipSpace(){ skip(" ", "true" ); }
function skipDot(){ skip(",", "false"); }
function keyfc(_key, _i){
  for(_i = idx; ; _i++){ if(substr(str, _i, 1) == "\""){ break; } }
  _key = get(_i - idx); step(_i - idx + 1); return _key;
}
function strfc(result, _key, _i){
  for(_i = idx; ; _i++){ if(substr(str, _i, 1) == "\"" && substr(str, _i - 1, 1) != "\\"){ break; } }
  result[_key] = get(_i - idx); step(_i - idx + 1);
}
function numfc(result, _key, _i){
  for(_i = idx; ; _i++){ if(substr(str, _i, 1) !~ /[0-9.\-]/){ break; } }
  result[_key] = get(_i - idx); step(_i - idx);
}
function boolfc(result, _key){
  if(get(4) == "true" ){ result[_key] = "true";  step(4); return; }
  if(get(5) == "false"){ result[_key] = "false"; step(5); return; }
  fatal("not boolean");
}
function arrfc(result, _key){
  _key = 0;
  while(1 == 1){
    skipSpace();
    if(get(1) == "]"){ step(1); skipSpace(); break; }
    if(get(1) == ","){ result[_key++] = ""; skipDot(); continue; }
    dispatch(result, _key++); skipSpace(); skipDot();
  }
}
function objfc(result, _key){
  while(1 == 1){
    skipSpace();
    if(get(1) == "}"){ step(1); skipSpace(); break; }
    check("\""); _key = keyfc(); skipSpace(); check(":"); skipSpace();
    dispatch(result, _key); skipSpace(); skipDot();
  }
}
function jtype(_sp){
  if(_sp == "["){return "array";}
  if(_sp == "{"){return "object";}
  if(_sp == "\""){return "string";}
  if(_sp ~ /[0-9\-]/){return "number";}
  if(_sp == "t" || _sp == "f"){return "boolean";}
  fatal("bad format");
}
function dispatch(result, _key, _type){
  _type = jtype(get(1));
  if(_type == "array"){
    result[_key]["_type_"] = _type;
    step(1); arrfc(result[_key]);
  }else if(_type == "object"){
    result[_key]["_type_"] = _type;
    step(1); objfc(result[_key]);
  }else if(_type == "string"){
    step(1); strfc(result, _key);
  }else if(_type == "number"){
    numfc(result, _key);
  }else if(_type == "boolean"){
    boolfc(result, _key);
  }
}
function pjson(result, _indent, _key, _type){
  if(typeof(result) != "array"){ print _indent, result; return ;}
  _type = result["_type_"];
  if(_type == "object"){
    print _indent"{";
    for(_key in result){
      if(_key == "_type_"){ continue; }
      if(typeof(result[_key]) == "array"){
        print _indent, _key, ":"; pjson(result[_key], _indent"  ");
      }else{
        print _indent, _key, ":", result[_key];
      }
    }
    print _indent"}";
  }else if(_type == "array"){ 
    print _indent"[";
    for(_key = 0; _key < length(result) - 1; _key++){
      if(typeof(result[_key]) == "array"){
        pjson(result[_key], _indent"  ");
      }else{
        print _indent, result[_key];
      }
    }
    print _indent"]";
  }
}

BEGIN{str=""; idx=1; result["_type_"] = "object";}
{
  str=$0; skipSpace();
  rootType = jtype(get(1)); if(rootType != "array" && rootType != "object"){ fatal("not json"); }
  dispatch(result, ".");
}

## echo '{"a":123,"b":-0.4,"c":"ccd","d":true,"e":{"f":["abc","fff"]}}' | gawk -i json.awk 'END{pjson(result["."])}'