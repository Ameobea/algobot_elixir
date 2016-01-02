var downloadUtils = {};

// https://www.dukascopy.com/datafeed/AUDUSD/2012/09/02/06h_ticks.bi5
// https://www.dukascopy.com/datafeed/AUDUSD/2012/09/02/06_ticks.bi5 

downloadUtils.str2ab = function(str) {
  var buf = new ArrayBuffer(str.length*2); // 2 bytes for each char
  var bufView = new Uint16Array(buf);
  for (var i=0, strLen=str.length; i<strLen; i++) {
    bufView[i] = str.charCodeAt(i);
  }
  return buf;
}

downloadUtils.downloadHour = function(ticker, year, month, day, hour){
  //console.log(day, hour);
  if(year.toString().length == 1){
    year = "0"+year.toString();
  }
  if(month.toString().length == 1){
    month = "0"+month.toString();
  }
  if(day.toString().length == 1){
    day = "0"+day.toString();
  }
  if(hour.toString().length == 1){
    hour = "0"+hour.toString();
  }
  var res = new XMLHttpRequest();
  res.open('GET', "https://www.dukascopy.com/datafeed/"+ticker+"/"+year+"/"+month+"/"+day+"/"+hour+"h_ticks.bi5", true);
  res.responseType = 'arraybuffer';

  res.onload = function(e){
    if(this.status == 200){
      var data = new DataView(this.response);
      saveAs(new Blob([this.response], {type: "application/x-lzma"}), ticker+"/"+year+"/"+month+"/"+day+"/"+hour+"h_ticks.lzma")
    }else{
      console.log("Error - page not found.");
      return;
    }   
  };

  res.send();
  /*res = $.get("https://www.dukascopy.com/datafeed/"+ticker+"/"+year+"/"+month+"/"+day+"/"+hour+"h_ticks.bi5");*/
}

downloadUtils.batch = function(ticker, year, month, day, hour){
  setTimeout(function(){
    downloadUtils.downloadHour(ticker, year, month, day, hour);
    hour++;
    if(hour > 23){
      hour = 0;
      day++;
    }
    if(day > 31){
      day = 1;
      month++;
    }
    if(month > 12){
      month = 0;
      year++;
    }
    if(year == 2015 && month == 10 && day == 16 && hour == 23){
      return;
    }else{
      downloadUtils.batch(ticker, year, month, day, hour);
    }
  }, 1000);
}

downloadUtils.downloadMo0 = function(ticker, year, month, day, hour){
  setTimeout(function(){
    downloadUtils.downloadHour(ticker, year, month, day, hour);
    hour++;
    if(hour > 23){
      hour = 0;
      day++;
    }
    if(day > 31){
      day = 1;
      month = 0;
      year++
    }
    if(year == 2016){
      return;
    }else{
      downloadUtils.downloadMo0(ticker, year, month, day, hour);
    }
  }, 1000);
}
