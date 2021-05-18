import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BaseAlertDialog extends StatelessWidget {

  //When creating please recheck 'context' if there is an error!

  String _title;
  String _content;
  String _yes;
  String _no;
  Function _yesOnPressed;
  Function _noOnPressed;

  BaseAlertDialog({String title, String content, Function yesOnPressed, Function noOnPressed, String yes = "Yes", String no = "No"}){
    this._title = title;
    this._content = content;
    this._yesOnPressed = yesOnPressed;
    this._noOnPressed = noOnPressed;
    this._yes = yes;
    this._no = no;
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid ? androidAlert() : iosAlert();
  }

  CupertinoAlertDialog iosAlert() {
    return CupertinoAlertDialog(
      title: new Text(this._title ,),
      content: new Text(this._content ),

      actions: <Widget>[
        new CupertinoDialogAction(
          child: new Text(this._yes),
          onPressed: () {
            this._yesOnPressed();
          },
        ),
        new CupertinoDialogAction(
          child: Text(this._no),
          onPressed: () {
            this._noOnPressed();
          },
        ),
      ],
    );
  }
  AlertDialog androidAlert() {
    return AlertDialog(
    title: new Text(this._title ),
    content: new Text(this._content ),

    actions: <Widget>[
      new TextButton(
        child: new Text(this._yes,),
        onPressed: () {
          this._yesOnPressed();
        },
      ),
      new TextButton(
        child: Text(this._no ,),
        onPressed: () {
          this._noOnPressed();
        },
      ),
    ],
  );
  }
}