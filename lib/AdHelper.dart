import 'dart:io';

class Adhelper{
  static String get bannerAdUnitId{

    if(Platform.isIOS){
      return "ca-app-pub-4269360951858539/1272203891";
    }else if(Platform.isAndroid){
      return "ca-app-pub-3940256099942544/6300978111";
    }else{
      return "";
    }
  }

  static String get intersetialaddunitid{
    if(Platform.isIOS){
      return "ca-app-pub-4269360951858539/4329612077";
    }else if(Platform.isAndroid){
      return "ca-app-pub-3940256099942544/1033173712";
    }else{
      return "";
    }
  }
}