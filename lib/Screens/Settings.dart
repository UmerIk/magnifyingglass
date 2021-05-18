import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  // const SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double width , height;

  List<String> camerasoundchoices = <String>[
    "On" , "Off",
  ];

  String camerasound = 'On';

  List<String> focuschoices = <String>[
    "Picture" , "Video",
  ];

  String focus = 'Picture';

  List<String> singletapchoices = <String>[
    "None" , "Focus",
  ];

  String singletap = 'Focus';

  SharedPreferences sharedPreferences;



  @override
  void initState(){
    initsp();
    super.initState();
  }
  Future<void> initsp() async {
    sharedPreferences = await SharedPreferences.getInstance();
    getmodes();
  }
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Container(

          padding: EdgeInsets.symmetric(vertical: height * 0.02 , horizontal: width * 0.03 ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.of(context).pop();
                },
                  child: Icon(Icons.adaptive.arrow_back)
              ),
              SizedBox(height: height * 0.01,),
              Text('Settings',style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),),
              SizedBox(height: height * 0.03,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ImageIcon(
                         AssetImage('assets/images/speaker.png'),
                      ),
                      SizedBox(width: width * 0.03,),
                      Text('Camera Sound',style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),),
                    ],
                  ),

                  PopupMenuButton(
                    child: Row(children: [
                      Text(camerasound , style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),),

                      Icon(Icons.arrow_drop_down),
                    ],),
                    padding: EdgeInsets.all(0),
                    onSelected: (value){
                      _selectcs(value);
                    },
                    // initialValue: choices[_selection],
                    itemBuilder: (BuildContext context) {
                      return camerasoundchoices.map((String choice) {
                        return  PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice ,
                            style: TextStyle(
                            ),
                          ),
                        );
                      }
                      ).toList();
                    },
                  ),
                ],
              ),
              SizedBox(height: height * 0.01,),
              Divider(),

              SizedBox(height: height * 0.01,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ImageIcon(
                        AssetImage('assets/images/focusmode.png'),
                      ),
                      SizedBox(width: width * 0.03,),
                      Text('Focus Mode',style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),),
                    ],
                  ),

                  PopupMenuButton(
                    child: Row(children: [
                      Text(focus , style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),),

                      Icon(Icons.arrow_drop_down),
                    ],),
                    padding: EdgeInsets.all(0),
                    onSelected: (value){
                      _selectfm(value);
                    },
                    // initialValue: choices[_selection],
                    itemBuilder: (BuildContext context) {
                      return focuschoices.map((String choice) {
                        return  PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice ,
                            style: TextStyle(
                            ),
                          ),
                        );
                      }
                      ).toList();
                    },
                  ),
                ],
              ),
              SizedBox(height: height * 0.01,),
              Divider(),

              SizedBox(height: height * 0.01,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ImageIcon(
                        AssetImage('assets/images/focus.png'),
                      ),
                      SizedBox(width: width * 0.03,),
                      Text('Single Tap',style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),),
                    ],
                  ),

                  PopupMenuButton(
                    child: Row(children: [
                      Text(singletap , style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),),

                      Icon(Icons.arrow_drop_down),
                    ],),
                    padding: EdgeInsets.all(0),
                    onSelected: (value){
                      _selectst(value);
                    },
                    // initialValue: choices[_selection],
                    itemBuilder: (BuildContext context) {
                      return singletapchoices.map((String choice) {
                        return  PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice ,
                            style: TextStyle(
                            ),
                          ),
                        );
                      }
                      ).toList();
                    },
                  ),
                ],
              ),

              SizedBox(height: height * 0.01,),
              Divider(),


              SizedBox(height: height * 0.04,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ImageIcon(
                        AssetImage('assets/images/headphones.png'),
                      ),
                      SizedBox(width: width * 0.03,),
                      Text('Contact us',style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),),
                    ],
                  ),

                  Icon(Icons.navigate_next),
                ],
              ),
              SizedBox(height: height * 0.01,),
              Divider(),
              SizedBox(height: height * 0.01,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ImageIcon(
                        AssetImage('assets/images/share.png'),
                      ),
                      SizedBox(width: width * 0.03,),
                      Text('Share',style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),),
                    ],
                  ),

                  Icon(Icons.navigate_next),
                ],
              ),
              SizedBox(height: height * 0.01,),
              Divider(),

              SizedBox(height: height * 0.01,),
              GestureDetector(
                onTap: () async {
                  String url = 'https://sites.google.com/view/biggbizzprivacypolicy';

                  await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ImageIcon(
                          AssetImage('assets/images/ppolicy.png'),
                        ),
                        SizedBox(width: width * 0.03,),
                        Text('Privacy Policy',style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),),
                      ],
                    ),

                    Icon(Icons.navigate_next),
                  ],
                ),
              ),
              SizedBox(height: height * 0.01,),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }

  void _selectcs(String choice) {
    sharedPreferences.setString("cs", choice);
    getmodes();
  }

  void _selectfm(String choice) {
    print('Choice : $choice');
    sharedPreferences.setString("fm", choice);
    getmodes();
  }

  void _selectst(String choice) {
    sharedPreferences.setString("st", choice);
    getmodes();
  }

  void getmodes(){
    setState(() {
      camerasound = sharedPreferences.getString("cs");
      if(camerasound == null || camerasound.isEmpty){
        camerasound = "On";
      }
      focus = sharedPreferences.getString("fm");
      if(focus == null || focus.isEmpty){
        focus = "Picture";
      }
      singletap = sharedPreferences.getString("st");
      if(singletap == null || singletap.isEmpty){
        singletap = "Focus";
      }
    });
  }
}
