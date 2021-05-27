import 'dart:io';
import 'dart:ui';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:magnifyingglass/AdHelper.dart';
import 'package:path/path.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as imageLib;
import 'package:gallery_saver/gallery_saver.dart';
import 'package:magnifyingglass/Screens/CapturedImages.dart';
import 'package:magnifyingglass/Screens/Settings.dart';
import 'package:minimize_app/minimize_app.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/filters/filters.dart';
import 'package:photofilters/filters/preset_filters.dart';
import 'package:photofilters/widgets/photo_filter.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:screen/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:screenshot/screenshot.dart';

class DashboardScreen extends StatefulWidget {

  final List<CameraDescription> cameras;
  const DashboardScreen({Key key, this.cameras}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin{

  SharedPreferences sharedPreferences;


  BuildContext contextt;
  Future<void> initsp() async {
    sharedPreferences = await SharedPreferences.getInstance();
    int c = sharedPreferences.getInt("count") ?? 1;
    print('ccccc $c');
    sharedPreferences.setInt("count", c + 1);

    if(c == 3){
      _showRatingDialog(contextt);
    }
  }
  int type = 0;
  double  height , width;
  bool _isfullscreen = false;
  final assetsAudioPlayer = AssetsAudioPlayer();
  BannerAd _bannerAd;
  bool _isbloading = false;
  InterstitialAd _interstitialAd;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    onNewCameraSelected(widget.cameras[0]);
    initsp();

    intersetialadd();



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

  bool _interstitialReady = false;
  void intersetialadd() {
    print('Intersertial');
    _interstitialAd ??= InterstitialAd(
      adUnitId: InterstitialAd.testAdUnitId,
      request: AdRequest(),
      listener: AdListener(
        onAdLoaded: (Ad ad) {
          // Fluttertoast.showToast(msg: "intersr loaded");
          print('${ad.runtimeType} loaded.');
          _interstitialReady = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('${ad.runtimeType} failed to load: $error.');
          ad.dispose();
          _interstitialAd = null;
          intersetialadd();
        },
        onAdOpened: (Ad ad) => print('${ad.runtimeType} onAdOpened.'),
        onAdClosed: (Ad ad) {
          print('${ad.runtimeType} closed.');
          ad.dispose();
          if(Platform.isIOS){
            MinimizeApp.minimizeApp();
          }else{
            SystemNavigator.pop();
          }
        },
        onApplicationExit: (Ad ad) =>
            print('${ad.runtimeType} onApplicationExit.'),
      ),
    )..load();
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
  @override
  Widget build(BuildContext context) {

    contextt = context;
    Screen.keepOn(true);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    height = MediaQuery.of(context).size.height - statusBarHeight;
    width = MediaQuery.of(context).size.width;


    return WillPopScope(
      onWillPop: () async {
        // Fluttertoast.showToast(msg: _interstitialReady.toString());
        print(_interstitialReady);
        if(_interstitialReady){
          _interstitialAd.show();
        }else{
          if(Platform.isIOS){
            MinimizeApp.minimizeApp();
          }else{
            SystemNavigator.pop();
          }
        }
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Container(
            width: width,
            color: Colors.black,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(child:  _cameraPreviewWidget(context)),

                      !_isfullscreen ?
                      Positioned(
                        top: height * 0.01,
                          left: width * 0.02,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: width * 0.05,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.adaptive.arrow_back),
                              color: Colors.black,
                              onPressed: (){
                                // Fluttertoast.showToast(msg: _interstitialReady.toString());
                                print(_interstitialReady);
                                if(_interstitialReady){
                                  _interstitialAd.show();
                                }else{
                                  if(Platform.isIOS){
                                    MinimizeApp.minimizeApp();
                                  }else{
                                    SystemNavigator.pop();
                                  }
                                }
                              },
                            ),
                          ),
                      ) : SizedBox(),
                      Positioned(
                        top: height * 0.01,
                        right: width * 0.02,
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: width * 0.05,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: _isfullscreen ?  Icon(Icons.fullscreen_exit):Icon(Icons.fullscreen),
                                color: Colors.black,
                                onPressed: () {
                                  setState(() {
                                    _isfullscreen = !_isfullscreen;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: height * 0.02,),
                            !_isfullscreen ?
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: width * 0.05,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.flip_camera_ios_outlined),
                                color: Colors.black,
                                onPressed: () {
                                  if(controller.description.lensDirection
                                      == CameraLensDirection.back){
                                    onNewCameraSelected(widget.cameras[1]);
                                  }else{
                                    onNewCameraSelected(widget.cameras[0]);
                                  }
                                },
                              ),
                            ) : SizedBox(),
                          ],
                        )
                      ),

                      !_isfullscreen ? Positioned(
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xbf000000),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: height * 0.08,
                                child: type == 0 ?
                              Container(
                                height: height * 0.08,
                                width: width,
                                padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                                child: Row(
                                  children: [
                                    Text('${_currentValue.toInt()} X' , style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold
                                    ),),
                                    Expanded(
                                      child: Slider(
                                        value: _currentValue,
                                        min: _minAvailableZoom,
                                        max: 10,
                                        onChanged: (double value) {
                                          setState(() {
                                            _handleScaleUpdate1(value);
                                          });
                                        },
                                      ),
                                    ),
                                    Text('10 X' , style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold
                                    ),),
                                  ],
                                ),
                              )
                                  :
                              Container(
                                height: height * 0.08,
                                width: width,
                                padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                                child: Row(
                                  children: [
                                    Icon(Icons.brightness_6 , color: Colors.blue),
                                    Expanded(
                                      child: Slider(
                                        value: _currentExposureOffset,
                                        min: _minAvailableExposureOffset,
                                        max: _maxAvailableExposureOffset,
                                        onChanged: (double value) {
                                          setState(() {
                                            setExposureOffset(value);
                                          });
                                        },
                                      ),
                                    ),
                                    Icon(Icons.brightness_7_rounded , color: Colors.blue,),
                                  ],
                                ),
                              ),

                              ),


                              Container(
                                height: height * 0.08,
                                width: width,
                                child: ListView(
                                  physics: BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          type = 0;
                                        });
                                      },
                                      child: Container(
                                          width: width * 0.2,
                                          alignment: Alignment.center,
                                          child: Image(
                                            image: AssetImage('assets/images/zom.png'),
                                            width: 30,
                                          ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        if(controller.value.flashMode == FlashMode.off){
                                          onSetFlashModeButtonPressed(FlashMode.torch);
                                        }else{
                                          onSetFlashModeButtonPressed(FlashMode.off);
                                        }
                                      },
                                      child: Container(
                                          width: width * 0.2,
                                        alignment: Alignment.center,
                                          child: Image(
                                            image: AssetImage('assets/images/flashlight.png'),
                                            width: 30,
                                          ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        if(sharedPreferences.getString("fm") == 'Video'){
                                          Fluttertoast.showToast(msg: 'Can\'t take picture while in video mode');
                                          return;
                                        }
                                        onTakePictureButtonPressed(context);

                                        // Navigator.of(context).push(MaterialPageRoute(builder: (_)=> FilterScreen()));
                                      },
                                      child: Container(
                                          width: width * 0.2,
                                        alignment: Alignment.center,
                                          child: Image(
                                            image: AssetImage('assets/images/camera.png'),
                                            width: 30,
                                          ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        Navigator.of(context).push(MaterialPageRoute(builder: (_)=> CapturedImages()));
                                      },
                                      child: Container(
                                          width: width * 0.2,
                                        alignment: Alignment.center,
                                          child: Image(
                                            image: AssetImage('assets/images/copy.png'),
                                            width: 30,
                                          ),
                                      ),
                                    ),
                                    // GestureDetector(
                                    //   onTap: () async {
                                    //     if(controller.value.isStreamingImages){
                                    //       await controller.stopImageStream();
                                    //     }else{
                                    //       await controller.startImageStream((image) => {
                                    //
                                    //       });
                                    //     }
                                    //   },
                                    //   child: Container(
                                    //       width: width * 0.2,
                                    //     alignment: Alignment.center,
                                    //       child: Image(
                                    //         image: AssetImage('assets/images/play.png'),
                                    //         width: 30,
                                    //       ),
                                    //   ),
                                    // ),
                                    // Container(
                                    //     width: width * 0.2,
                                    //   alignment: Alignment.center,
                                    //     child: Image(
                                    //       image: AssetImage('assets/images/filters.png'
                                    //       ),
                                    //       width: 30,
                                    //     ),
                                    // ),
                                    GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          type = 1;
                                        });
                                      },
                                      child: Container(
                                          width: width * 0.2,
                                        alignment: Alignment.center,
                                          child: Image(
                                            image: AssetImage('assets/images/brightness.png'),
                                            width: 30,
                                          ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsScreen()));
                                      },
                                      child: Container(
                                          width: width * 0.2,
                                        alignment: Alignment.center,

                                          child: Image(
                                            image: AssetImage('assets/images/gear.png'),
                                            width: 30,
                                          ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ) : SizedBox()
                    ],
                  ),
                ),
                // adwidget(),
              ],
            ),
          ),
        ),

      ),
    );
  }



  CameraController controller;
  XFile imageFile;
  File imgfile;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;

  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _currentValue = 1.0;
  double _baseScale = 1.0;

  double mulp = 0.0;
  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;


  void _rateAndReviewApp() async {
    final _inAppReview = InAppReview.instance;

    if (await _inAppReview.isAvailable()) {
      print('request actual review from store');
      _inAppReview.requestReview();
    } else {
      print('open actual store listing');
      // TODO: use your own store ids
      _inAppReview.openStoreListing(

        appStoreId: 'com.demit.magnifyingglass',

        // microsoftStoreId: '<your microsoft store id>',
      );
    }
  }
  void _showRatingDialog(BuildContext context) {
    final _dialog = RatingDialog(
      // your app's name?
      title: 'Rating Dialog',
      // encourage your user to leave a high rating?
      message:
      'Tap a star to set your rating. Add more description here if you want.',
      // your app's logo?
      image: Image.asset('assets/images/logo.png' , width: 100, height: 100,),
      initialRating: 5,
      itemsize: 20,
      submitButton: 'Submit',
      onCancelled: () => print('cancelled'),
      onSubmitted: (response) {

        Fluttertoast.showToast(msg: '${response.rating}');
        print('rating: ${response.rating}, comment: ${response.comment}');

        // // TODO: add your own logic
        // if (response.rating < 3.0) {
        //   // send their comments to your email or anywhere you wish
        //   // ask the user to contact you instead of leaving a bad review
        // } else {
        //   _rateAndReviewApp();
        // }
      },
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: true, // set to false if you want to force a rating
      builder: (context) => _dialog,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _interstitialAd.dispose();
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  Widget _cameraPreviewWidget(BuildContext buildContext) {

    final CameraController cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {

      return const Text(
        'No camera found',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {

      var camera = controller.value;
      // fetch screen size
      final ar = false ?
      width/(height - AdSize.banner.height.toDouble())
          :
      width / height;

      var scale = ar * camera.aspectRatio;

      if (scale < 1) scale = 1 / scale;


      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        // child: Screenshot(
        //   controller: screenshotController,
          child: Transform.scale(
            scale: scale,
            child: Center(
              child: CameraPreview(
                controller,
                child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        // onScaleStart: _handleScaleStart,
                        // onScaleUpdate: _handleScaleUpdate,
                        onTapDown: (details) => onViewFinderTap(details, constraints),
                      );
                    }),
              ),
            ),
          ),
        // ),
      );
    }
  }

  Future<void> _handleScaleUpdate1(double val) async {

    if (controller == null) {
      return;
    }
    setState((){
      _currentValue = val;
      print("cval $_currentValue" );

      _currentScale = (val * mulp).clamp(_minAvailableZoom, _maxAvailableZoom);

      controller.setZoomLevel(_currentScale);
    });
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    if(sharedPreferences.getString("st") != 'None'){
      cameraController.setFocusPoint(offset);
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    controller = cameraController;


    // If the controller is updated then update the UI.

    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        Fluttertoast.showToast(msg: 'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value){
              if(value > 10){
                _maxAvailableZoom = 10;
              }else{
                _maxAvailableZoom = value;
              }
              mulp = _maxAvailableZoom / 10;
              print(mulp);
              _handleScaleUpdate1(4);
            }),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),


      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  String fileName;
  List<Filter> filters = presetFiltersList;

  void onTakePictureButtonPressed(BuildContext context) {

    assetsAudioPlayer.open(
      Audio("assets/images/cameraclick.mp3"),
    );
    // assetsAudioPlayer.play();
    takePicture().then((XFile file) async {
      if (file == null) return;

      File f = File(file.path);

      // Navigator.of(context).push(MaterialPageRoute(builder: (_)=>FilterScreen(file: f,)));
      //
      // return;
      fileName = basename(f.path);
      var image = imageLib.decodeImage(await f.readAsBytes());
      image = imageLib.copyResize(image, width: 600);
      Map imagefile = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => new PhotoFilterSelector(
            title: Text("Photo Filter Example"),
            image: image,
            filters: presetFiltersList,
            filename: fileName,
            loader: Center(child: CircularProgressIndicator()),
            fit: BoxFit.contain,
          ),
        ),
      );
      print('iifff: $imagefile');
      if (imagefile != null && imagefile.containsKey('image_filtered')) {
        print("object");
        imgfile = imagefile['image_filtered'];

        print("object1");
        final Directory dir = await getExternalStorageDirectory();
        final path = '${dir.path.replaceAll("/storage/emulated/0/", "")
            .replaceAll("/storage/emulated/1/", "").replaceAll("/Internal Storage/", "")}' ;

        print('pathhhhh: $path');

        await GallerySaver.saveImage(imgfile.path , albumName: path ,).then((value) => {
          Fluttertoast.showToast(msg: 'Image Saved'),
        }).catchError((onError){
          Fluttertoast.showToast(msg: 'Failed to save');
        });

        print(imageFile.path);
      }


    });
  }



  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) setState(() {});

    });
  }


  void onSetFocusModeButtonPressed(FocusMode mode) {
    setFocusMode(mode).then((_) {
      if (mounted) setState(() {});

    });
  }
  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }
  Future<void> setExposureMode(ExposureMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller.setExposureMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }
  Future<void> setExposureOffset(double offset) async {
    if (controller == null) {
      return;
    }

    setState(() {
      _currentExposureOffset = offset;
    });
    try {
      offset = await controller.setExposureOffset(offset);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }
  Future<void> setFocusMode(FocusMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller.setFocusMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<XFile> takePicture() async {
    final CameraController cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      return null;
    }

    try {
      XFile xfile = await cameraController.takePicture();

      return xfile;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }
  void _showCameraException(CameraException e) {
    Fluttertoast.showToast(msg: 'Error: ${e.code}${e.description}');
  }
}
