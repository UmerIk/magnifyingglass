import 'dart:io';

class Adhelper{
  static String get bannerAdUnitId{
    if(Platform.isIOS){
      return "ca-app-pub-4269360951858539/1272203891";
    }else if(Platform.isAndroid){
      return "ca-app-pub-4269360951858539/4363409270";
    }else{
      return "";
    }
  }

  static String get intersetialaddunitid{
    if(Platform.isIOS){
      return "ca-app-pub-4269360951858539/4329612077";
    }else if(Platform.isAndroid){
      return "ca-app-pub-4269360951858539/4473082300";
    }else{
      return "";
    }
  }
}