import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/home_page.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    cekLogin();
    super.initState();
  }
  void cekLogin(){
    FirebaseAuth.instance
        .currentUser()
        .then((currentUser)  {
            //print(currentUser);

            if (currentUser == null)  {
                Navigator.pushReplacementNamed(context, '/login');
            } else {
                Firestore.instance  .collection('flutter_driver')
                    .document(currentUser.uid)
                    .get()
                    .then((DocumentSnapshot result){  
                     // print( result['uid'].toString()) ;
                     Map<String, dynamic> data_p; 
                     data_p={
                       'uid': result['uid'], 
                       'name': result['name'],
                       'email':result['email'],
                       'hp': result['hp'],
                       'aktivasi': result['aktivasi'],
                       'point': result['point']
                     };
                
                    Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage(
                                    data_p: data_p,
                        )
                      )
                    );
                                    
                  }).catchError((err) {  
                    // print("jjjjjjjjjjjjjjjjjjjjj");print(err);
                  });  
              
              }
             
        }) .catchError((err){  
          //print("vvvvvvvvvvvvvvvv"); print(err);  
        });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
       // child: Container(
       //   child: Text("Loading..."),
       // ),
        child:   Image.asset(
          'assets/img_logo.png',
          height: 100.0,
          width: 200.0,
        ), 

      ),
    );
  }
}
