## 加载proxy
source ~/.bash_profile
proxy

tfile="tmp.csv"
rm -rf $tfile

getST(){
	file=$1
	t=`tail -n 1 $file | awk '{print $1}'`
	echo $t
}

toJson(){
	afile=$1
	bfile=$2
	key=$3
	awk -vks="$key" '
	{
		lc=$1;
		for(i=2;i<=NF;i++){			
			lc=lc","$i;
		}
		lc="["lc"]";
		result=(NR==1?lc:(result","lc));
	}
	END{
		print "var "ks" = ["result"];";
	}' $afile > $bfile
}

st=`getST positions.csv`
curl -s "https://fapi.binance.com/futures/data/globalLongShortAccountRatio?symbol=BTCUSDT&period=1h&limit=500" | \
gawk -F"{|}" '{for(i=1;i<=NF;i++){if(length($i)>5){print $i;}}}' | \
gawk -F":|," -vkst="$st" '{
  for(i=1;i<=NF;i+=2){
    if($i ~ "longAccount"){lvalue=substr($(i+1),2,length($(i+1))-2);}
    if($i ~ "shortAccount"){svalue=substr($(i+1),2,length($(i+1))-2);}
    if($i ~ "timestamp"){ts=$(i+1);}
  }
  if(ts>=kst){
    print ts,lvalue-svalue;
  }
}' > $tfile
gawk -vkst="$st" '$1<kst{print $0}' positions.csv >> $tfile
sort -n $tfile > positions.csv
rm -rf $tfile

st=`getST opens.csv`
curl -s "https://fapi.binance.com/futures/data/openInterestHist?symbol=BTCUSDT&period=1h&limit=500" | \
gawk -F"{|}" '{for(i=1;i<=NF;i++){if(length($i)>5){print $i;}}}' | \
gawk -F":|," -vkst="$st" '{
  for(i=1;i<=NF;i+=2){
    if($i ~ "sumOpenInterestValue"){value=int(substr($(i+1),2,length($(i+1))-2)/10000)/10000;}
    if($i ~ "timestamp"){ts=$(i+1);}
  }
  if(ts>=kst){
    print ts,value;
  }
}' > $tfile
gawk -vkst="$st" '$1<kst{print $0}' opens.csv >> $tfile
sort -n $tfile > opens.csv
rm -rf $tfile

st=`getST klines.csv`
curl -s "https://fapi.binance.com/fapi/v1/klines?symbol=BTCUSDT&interval=1h&limit=500" | \
gawk -F'\\[|\\]' '{for(i=1;i<=NF;i++){if(length($i)>5){print $i;}}}' | \
gawk -F"," -vkst="$st" '{
	ts=$1;op=substr($2,2,length($2)-2);hg=substr($3,2,length($3)-2);lw=substr($4,2,length($4)-2);cls=substr($5,2,length($5)-2);
	if(ts>=kst){
    print ts,op,hg,lw,cls;
  }
}' > $tfile
gawk -vkst="$st" '$1<kst{print $0}' klines.csv >> $tfile
sort -n $tfile > klines.csv
rm -rf $tfile

toJson positions.csv positions.js positions
toJson opens.csv opens.js opens
toJson klines.csv klines.js klines

unproxy