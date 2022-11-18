function printX(o, _indent, _x){
  if(typeof(o) != "array"){ print o; return; }
  for(_x in o){
    if(typeof(o[_x]) != "array"){
      print _indent, _x, ":", o[_x];
    }else{
      print _indent, _x, ":";
      printX(o[_x], _indent"  ");
    }
  }
}

function clone(ma, mb, _key, _x){
  for(_x in ma){
    if(typeof(ma[_x]) != "array"){
      if(_key == ""){
        mb[_x] = ma[_x];
      }else{
        mb[_key][_x] = ma[_x];
      }
    }else{
       if(_key == ""){
         clone(ma[_x], mb, _x);
       }else{
         clone(ma[_x], mb[_key], _x);
       }
    }
  }
}

## echo "" | awk -i lib.awk -i json.awk '{map[1]=1;map[2]=2;map[3][1]=31; printX(map);clone(map,gg);printX(gg)}'