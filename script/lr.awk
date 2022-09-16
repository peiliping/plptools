function lr(_source, _result, _i){
  _result["len"] = length(_source);
  for(_i = 1; _i <= _result["len"]; _i++){
    _result["sumx"]+=_i;
    _result["sumy"]+=_source[_i];
    _result["sumxx"]+=(_i * _i);
    _result["sumxy"]+=(_i * _source[_i]);
  }
  _result["slope"] = (_result["len"] * _result["sumxy"] - _result["sumx"] * _result["sumy"]) / (_result["len"] * _result["sumxx"] - _result["sumx"] * _result["sumx"]);
  _result["intercept"] = _result["sumy"] / _result["len"] - _result["slope"] * _result["sumx"] / _result["len"] + _result["slope"];
 
  for(_i = 1; _i <= _result["len"]; _i++){
    _result["stdDevAcc"]+=((_i * _result["slope"] + _result["intercept"] - _source[_i]) * (_i * _result["slope"] + _result["intercept"] - _source[_i]));
  }
  _result["stdDev"] = sqrt(_result["stdDevAcc"] / (_result["len"] - 1));
  _result["M"] = _result["len"] * _result["slope"] + _result["intercept"];
  _result["U"] = _result["M"] + 2 * _result["stdDev"];
  _result["D"] = _result["M"] - 2 * _result["stdDev"];
}