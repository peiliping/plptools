function fatal(_sp){ print "fatal error !!! index : ("IDX") "_sp; exit 1; }
function get(_np){ return substr(JSON_STRING, IDX, _np); }
function step(_np){ IDX+=_np; }
function skip(_sp, _greed){
  if(get(length(_sp)) == _sp){ 
    step(length(_sp)); 
    if(_greed == "true"){ skip(_sp, _greed); }
  } 
}
function skipSpace(){ skip(" ", "true" ); }
function skipDot(){ skip(",", "false"); }
function check(_sp){ 
  if(get(length(_sp)) == _sp){ step(length(_sp)); return ; }
  fatal("check failed "_np);  
}
function keyfc(_key, _i){
  for(_i = IDX; ; _i++){ if(substr(JSON_STRING, _i, 1) == "\""){ break; } }
  _key = get(_i - IDX); step(_i - IDX + 1); return _key;
}
function strfc(_json, _key, _i){
  for(_i = IDX; ; _i++){ if(substr(JSON_STRING, _i, 1) == "\"" && substr(JSON_STRING, _i - 1, 1) != "\\"){ break; } }
  _json[_key] = get(_i - IDX); step(_i - IDX + 1);
}
function numfc(_json, _key, _i){
  for(_i = IDX; ; _i++){ if(substr(JSON_STRING, _i, 1) !~ /[0-9.\-]/){ break; } }
  _json[_key] = get(_i - IDX); step(_i - IDX);
}
function boolfc(_json, _key){
  if(get(4) == "true" ){ _json[_key] = "true";  step(4); return; }
  if(get(5) == "false"){ _json[_key] = "false"; step(5); return; }
  fatal("not boolean");
}
function arrfc(_json, _key){
  _key = 0;
  while(1 == 1){
    skipSpace();
    if(get(1) == "]"){ step(1); skipSpace(); break; }
    if(get(1) == ","){ _json[_key++] = ""; skipDot(); continue; }
    dispatch(_json, _key++); skipSpace();
    if(get(1) != "]"){ check(","); }
  }
}
function objfc(_json, _key){
  while(1 == 1){
    skipSpace();
    if(get(1) == "}"){ step(1); skipSpace(); break; }
    check("\""); _key = keyfc(); skipSpace(); check(":"); skipSpace();
    dispatch(_json, _key); skipSpace();
    if(get(1) != "}"){ check(","); }
  }
}
function jtype(_sp){
  if(_sp == "\""){return "string";}
  if(_sp ~ /[0-9\-]/){return "number";}
  if(_sp == "t" || _sp == "f"){return "boolean";}
  if(_sp == "["){return "array";}
  if(_sp == "{"){return "object";}
  fatal("bad format");
}
function dispatch(_json, _key, _sp){
  _sp = jtype(get(1));
  if(_sp == "array"){
    if(_key == ""){
      _json["_type_"] = "array";  step(1); arrfc(_json);
    }else{
      _json[_key]["_type_"] = "array";  step(1); arrfc(_json[_key]);
    }
  }else if(_sp == "object"){
    if(_key == ""){
      _json["_type_"] = "object"; step(1); objfc(_json);
    }else{
      _json[_key]["_type_"] = "object"; step(1); objfc(_json[_key]);
    }
  }else if(_sp == "string"){
    step(1); strfc(_json, _key);
  }else if(_sp == "number"){
    numfc(_json, _key);
  }else if(_sp == "boolean"){
    boolfc(_json, _key);
  }
}
function printJson(_json, _indent, _key){
  if(typeof(_json) != "array"){ print _indent, _json; return ;}
  if(_json["_type_"] == "object"){
    print _indent"{";
    for(_key in _json){
      if(_key == "_type_"){ continue; }
      if(typeof(_json[_key]) == "array"){
        print _indent, _key, ":"; printJson(_json[_key], _indent"  ");
      }else{
        print _indent, _key, ":", _json[_key];
      }
    }
    print _indent"}";
  }else if(_json["_type_"] == "array"){ 
    print _indent"[";
    for(_key = 0; _key < length(_json) - 1; _key++){
      if(typeof(_json[_key]) == "array"){
        printJson(_json[_key], _indent"  ");
      }else{
        print _indent, _json[_key];
      }
    }
    print _indent"]";
  }
}
function parserJson(_str, _json){
 JSON_STRING = _str; IDX = 1; skipSpace();
 rootType = jtype(get(1)); if(rootType != "array" && rootType != "object"){ fatal("not json"); }
 dispatch(_json);
}
## echo '{"a":123,"b":-0.4,"c":"ccd","d":true,"e":{"f":["abc","fff"]}}' | gawk -i json.awk '{parserJson($0,json);printJson(json);}'
