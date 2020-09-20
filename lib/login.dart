import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/home_page.dart'; 
 


enum authProblems { userNotFound, passwordNotValid,networkError }
class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
   final _scaffoldKey = GlobalKey<ScaffoldState>(); // new line
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  TextEditingController emailInputController  =   TextEditingController();
  TextEditingController pwdInputController=   TextEditingController();
  bool _isLoading = false; 
  Map<String,dynamic> data_p ;



  @override
  void initState() {
  
    _getAfterLogin();
    super.initState();
  }
  void _getAfterLogin() async {
      var localStorage = await SharedPreferences.getInstance();
      emailInputController .text=localStorage.getString('email');
      pwdInputController .text=localStorage.getString('pass');
  } 
   
  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    var regex =   RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'Password must be longer than 8 characters';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       key: _scaffoldKey,    
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Form(
              key: _loginFormKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Email*', hintText: 'john.doe@gmail.com'),
                    controller: emailInputController,
                    keyboardType: TextInputType.emailAddress,
                    validator: emailValidator,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Password*', hintText: '********'),
                    controller: pwdInputController,
                    obscureText: true,
                    validator: pwdValidator,
                  ),
                  RaisedButton(
                    child: Text(_isLoading? 'Loging...' : 'Login',),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                     onPressed: _isLoading ? null : _login, 
                    // onPressed: () async {  },
                  ),
                  Text('Belum punya akun?'),
                  FlatButton(
                    child: Text('Buat akun di sini!'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/register_hp');
                    },
                  )
                ],
              ),
            ))));
  }


 void _login(   ) async{ 
    setState(() {
       _isLoading = true;
    });
  
    if (_loginFormKey.currentState.validate()) { 
              var localStorage = await SharedPreferences.getInstance();
              await localStorage.setString('email', emailInputController.text);
              await localStorage.setString('pass',  pwdInputController.text);
               
              try {
                var user = await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailInputController.text,
                    password: pwdInputController.text
                ); 
                 //print('gggggggggggggggggggggggggggggggggggg');
                //var rnd =   Random(); 
                // var min = 100000, max = 999999; 
                // var num = min + rnd.nextInt(max - min);
                // print('$num is in the range of $min and $max');
                // if( user.user.isEmailVerified){
                  await Firestore.instance 
                  .collection('flutter_driver')
                  .document(user.user.uid)
                  .get()
                  .then((DocumentSnapshot result){
                     var bintang=0;
                          if (result['counter_reputation']!=0 && result['divide_reputation']!=0 ){
                            bintang = result['counter_reputation'] ~/ result['divide_reputation']  ;
                          }else{
                            bintang= 0;
                          }  
                          data_p={
                            'uid': result['uid'], 
                            'name': result['name'],
                            'email':result['email'],
                            'hp': result['hp'],
                            'aktivasi': result['aktivasi'],
                            'point': result['point'],
                            'trip': result['trip'],
                            'avatar': result['avatar'],
                            'bintang': bintang,
                          };
                           if(result['blok']){
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return Dialog(backgroundColor: Colors.white,
                                    child:   Container(
                                       padding: const EdgeInsets.all(16.0),
                                      height: 100,
                                      child: Text("Kami mendeteksi akun ini beroperasi tidak wajar, untuk sementara akun ini kami blok."),
                                    ),
                                  );
                                },
                              );
                           }else{

                             
                             Navigator.pushReplacement(
                                  context,  MaterialPageRoute(
                                    builder: (context) => HomePage( data_p:data_p   )
                                    )
                                ); 
                               
                           }
                      }).catchError((err) => print(err));
                // }else{
                //    await FirebaseAuth.instance.signOut().then((result) {     });
                //     print('silahkan verifkasi email');
                // }
            
              } catch (e) {
                authProblems errorType;
                if (Platform.isAndroid) {
                  switch (e.message) {
                    case 'There is no user record corresponding to this identifier. The user may have been deleted.':
                      errorType = authProblems.userNotFound;
                      break;
                    case 'The password is invalid or the user does not have a password.':
                      errorType = authProblems.passwordNotValid;
                      break;
                    case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
                      errorType = authProblems.networkError;
                      break;
                    // ...
                    default:
                      print('Case ${e.message} is not yet implemented');
                  }
                } else if (Platform.isIOS) {
                  switch (e.code) {
                    case 'Error 17011':
                      errorType = authProblems.userNotFound;
                      break;
                    case 'Error 17009':
                      errorType = authProblems.passwordNotValid;
                      break;
                    case 'Error 17020':
                      errorType = authProblems.networkError;
                      break;
                    // ...
                    default:
                      print('Case ${e.message} is not yet implemented');
                  }
                }
                print('The error is $errorType');
                final snackBar = SnackBar(
                  content: Text('Username tidak ditemukan'),
                  action: SnackBarAction(
                    label: 'Close',
                    onPressed: () { 
                    },
                  ),
                ); 
                _scaffoldKey.currentState.showSnackBar(snackBar);  // edited line
              }
         
             /* await FirebaseAuth.instance  
                .signInWithEmailAndPassword(
                  email: emailInputController.text,
                  password: pwdInputController.text)
              .then((currentUser){  
                if( currentUser.user.isEmailVerified){
                  Firestore.instance 
                  .collection('flutter_customer')
                  .document(currentUser.user.uid)
                  .get()
                  .then((DocumentSnapshot result)  {
                          data_p={
                            'uid': result['uid'], 
                            'name': result['name'],
                            'email':result['email'],
                            'hp': result['hp'],
                            'aktivasi': result['aktivasi']
                          };
                          Navigator.pushReplacement(
                          context,  MaterialPageRoute(
                              builder: (context) => LandingPage( data_p:data_p   )
                            )
                          );
                            
                      }).catchError((err) => print(err));
                }else{
                    print('silahkan verifkasi email');
                }
                
                }).catchError((err) => print(err));
             */

    }

    setState(() {
       _isLoading = false;
    });  

  }
  
}
