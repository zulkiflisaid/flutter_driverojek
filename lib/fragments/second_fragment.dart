import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecondFragment extends StatelessWidget {

  //String todo;
  //SecondFragment({Key key, @required this.todo}) : super(key: key);
  static const platform = const MethodChannel('channel.tutup.screen');
  //static const platform = const MethodChannel('plugins.flutter.io/firebase_messaging');

  SecondFragment() {
    platform.setMethodCallHandler((call) {
       print("call.method");
      print(call.method);
      
        // return Future<void>.value();
    });
  }


  @override
  Widget build(BuildContext context) {
    //if( todo=="0"){
     //     Navigator.of(context).pop(); // close the drawer
    //  }

    // TODO: implement build
    return new Center(
      child: new Text("fffff"),
    );
  }
 
  
}