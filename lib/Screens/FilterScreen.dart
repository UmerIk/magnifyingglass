
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'package:path/path.dart';


class FilterScreen extends StatefulWidget {
  const FilterScreen({Key key , this.file}) : super(key: key);
  final File file;
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {

  String fileName;
  List<Filter> filters = presetFiltersList;
  final picker = ImagePicker();
  File imageFile;


  Future getImage(context) async {
    final pickedFile = widget.file;
    if(pickedFile!=null){
      imageFile = new File(pickedFile.path);
      fileName = basename(imageFile.path);
      var image = imageLib.decodeImage(await imageFile.readAsBytes());
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

      print("iiiiiffff : $imagefile" );
      if (imagefile != null && imagefile.containsKey('image_filtered')) {
        setState(() {
          imageFile = imagefile['image_filtered'];
        });
        print(imageFile.path);
      }
    }
  }

  @override
  void initState() {
    imageFile = widget.file;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Photo Filter Example'),
      ),
      body: Center(
        child: new Container(
          child: imageFile == null
              ?
          Center(
            child: new Text('No image selected.'),
          )
              :
          Column(
            children: [
              Expanded(child: Image.file(new File(imageFile.path))),

              Row(
                children: [
                  Expanded(
                      child: Container(

                        child: ElevatedButton(
                          onPressed: () async {

                            final Directory dir = await getExternalStorageDirectory();
                            final path = '${dir.path.replaceAll("/storage/emulated/0/", "")
                                .replaceAll("/storage/emulated/1/", "")}' ;

                            print('pathhhhh: $path');

                            await GallerySaver.saveImage(imageFile.path , albumName: path ,).then((value) => {
                              Fluttertoast.showToast(msg: 'Image Saved'),
                            }).catchError((onError){
                              Fluttertoast.showToast(msg: 'Failed to save');
                            });

                          },
                          child: Text('Save'),
                        ),
                      ),
                  ),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: (){
                        getImage(context);
                      },
                      child: Text('Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
