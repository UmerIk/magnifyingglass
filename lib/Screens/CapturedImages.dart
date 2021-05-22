import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../AdHelper.dart';

class CapturedImages extends StatefulWidget {
  const CapturedImages({Key key}) : super(key: key);

  @override
  _CapturedImagesState createState() => _CapturedImagesState();
}

class _CapturedImagesState extends State<CapturedImages> {
  Future _futureGetPath;
  List<dynamic> listImagePath = [];
  var _permissionStatus;

  String errortext = 'No Images Added yet';
  double width , height;


  BannerAd _bannerAd;
  bool _isbloading = false;

  @override
  void initState() {
    super.initState();
    _listenForPermissionStatus();
    _futureGetPath = _getPath();


    _bannerAd = BannerAd(size: AdSize.banner,
        adUnitId: Adhelper.bannerAdUnitId,
        listener: AdListener(onAdLoaded: (_){
          print('loaded');
          // Fluttertoast.showToast(msg: "banner loaded");
          setState(() {
            _isbloading = true;
          });
        }),
        request: AdRequest()
    );
    _bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: double.infinity,
              child: FutureBuilder(
                future: _futureGetPath,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    var dir = Directory(snapshot.data);
                    print('permission status: $_permissionStatus');
                    if (_permissionStatus) _fetchFiles(dir);
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.03 , vertical: height * 0.02),

                      child: Text('My Images:',style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),),
                    );
                  } else {
                    return Text('No Images Added yet');
                  }
                },
              ),
            ),
            Expanded(
              child: listImagePath.length == 0  ?
              Center(child: Text(errortext),)
                  :
                GridView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: listImagePath.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: (orientation == Orientation.portrait) ? 3 : 4),
                itemBuilder: (BuildContext context, int index) {
                  return _getListImg(listImagePath[index]);
                },
                primary: false,

              ),
            ),
            adwidget(),
          ],
        ),
      ),
    );
  }

  Widget adwidget(){
    if(_isbloading){

      return Container(
        child: AdWidget(ad: _bannerAd,),
        height: AdSize.banner.height.toDouble(),
        width: _bannerAd.size.width.toDouble(),
        alignment: Alignment.center,
      );
    }else{
      return Container();
    }
  }
  // Check for storage permission
  void _listenForPermissionStatus() async {
    final status = await Permission.storage.request().isGranted;
    // setState() triggers build again
    setState(() => _permissionStatus = status);
  }

  // Get storage path
  // https://pub.dev/documentation/ext_storage/latest/
  Future<String> _getPath() async{
    Directory dir = await getExternalStorageDirectory();
    return dir.path;
  }

  _fetchFiles(Directory dir) {
    List<dynamic> listImage = [];
    dir.list().forEach((element) {
      RegExp regExp =
      new RegExp("\.(gif|jpe?g|tiff?|png|webp|bmp)", caseSensitive: false);
      // Only add in List if path is an image
      if (regExp.hasMatch('$element')) listImage.add(element);
      setState(() {
        listImagePath = listImage;
        errortext = 'No Images Added yet';
      });
    });
  }

  Widget _getListImg(dynamic listImagePath) {
    // List<Widget> listImages = [];
    // for (var imagePath in listImagePath) {
      File file = listImagePath;
      // listImages.add(
      //
      // );
    // }
    return GestureDetector(
      onTap: (){
        _showSecondPage(context, file);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: width * 0.01 , vertical: height * 0.01),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(width * 0.03)),
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(width * 0.03)),
              child: Hero(
                  tag: file.path,
                  child: Image.file(file, fit: BoxFit.cover)
              )
          ),
        ),
      ),
    );
  }


  void _showSecondPage(BuildContext context , File link) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          body: SafeArea(
            child: Container(
              color: Colors.black,
              child: Center(
                child: Hero(
                  tag: link.path,
                  child: Image.file(link , fit: BoxFit.cover,),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



