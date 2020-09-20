import 'package:driverojek/fragments/first_fragment.dart';
import 'package:driverojek/pages/topup_saldo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:driverojek/pages/go_driver.dart';
import 'package:driverojek/pages/transaksi_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account.dart';
import 'inboxs.dart';

 
class DrawerItem {
  String title;
  IconData icon;
  DrawerItem(this.title, this.icon);
}

class HomePage extends StatefulWidget {

  final drawerItems = [
      DrawerItem("Order", Icons.map),
      DrawerItem("Transaksi", Icons.monetization_on),
      DrawerItem("Top Up", Icons.payment),
      DrawerItem("Inbox", Icons.email),
      DrawerItem("Akun", Icons.account_circle),
    
  ];
  final Map<String, dynamic> data_p; 
  HomePage({Key key, this.data_p}) : super(key: key);
  @override
  State<StatefulWidget> createState() {  return new HomePageState();  }
}

class HomePageState extends State<HomePage>   { //with WidgetsBindingObserver
  
  
  HomePageState() {
		platform_keluar.setMethodCallHandler((call) { 
	   //print(call.method);  print(call.method); 
		if(call.method=="Logout"){ 
		   //keluar dari program
       Navigator.pushReplacementNamed(context, '/login');
		}

		});
  } 
  static const platform_keluar = const MethodChannel('platform_keluar'); 
  
  //mebuka navigasi kanan  Scaffold.of(context).openDrawer();
  
  //akun driver
  // String id_driver="-";
  String driver_nama="-";
  String driver_hp="-";
  String driver_email="-";
  int driver_saldo=0;
  int driver_point=0 ;  
 
  int radius_driver=10000;
  bool status_siap=true;
  String on_off="ON";
  //var order masuk
  final databaseRef = Firestore.instance;

   //GCM FIRBASE 
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool isSubscribed = false;
  String gcm_token = ""; 
  String _homeScreenText = "Waiting for token...";
  String _messageText = "Waiting for message...";
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var uang =   NumberFormat.currency(locale: 'ID', symbol: '',decimalDigits:0); 
 
   // navigation
  int _selectedDrawerIndex = 0;
  int terbuka = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // List json_data; 
  String dataShared = "No data";
  Map<dynamic, dynamic> sharedData = Map();
   
  static const _channel = const MethodChannel('app.channel.shared.data');
    /* HomePageState() {
     _channel.setMethodCallHandler((call) { 
         print(call.method);
       
        
      });
   }*/    
    
  
    
  @override
  void initState() { 


   //_startActivity();
    getCurrentUser();
    _getSharedData(); 
     _init();
	 
    //akun driver 
     radius_driver=10000;
     status_siap=true; 
    //WidgetsBinding.instance.addObserver(this); 
    flutterLocalNotificationsPlugin =   FlutterLocalNotificationsPlugin();
    var android =   AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS =   IOSInitializationSettings();
    var initSetttings =   InitializationSettings(android, iOS);
    
    flutterLocalNotificationsPlugin.initialize(initSetttings, onSelectNotification: onSelectNotification);
  
     _firebaseMessaging.configure( 
      onMessage: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";   
        }); 
          // print("onMessage: $message"); 
        //_closeActivity();  
         showNotification(message);  
      },
      onLaunch: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onResume: $message"); 
      },
     /* onBackgroundMessage: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onBackgroundMessage: $message");  
      },*/ 
   // onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler1 ,
     //  onBackgroundMessage:  HelperClass.myBackgroundMessageHandler  
      
   
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered   .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  
    _firebaseMessaging.getToken().then((String tokenGcm)   {
      assert(tokenGcm != null);
      setState(() {
        this.gcm_token = tokenGcm; 
        _homeScreenText = "Push Messaging token: $tokenGcm";
      }); 
      
        print(_homeScreenText);
    });  

     super.initState();
  }
  
 @override
  void dispose() {
    //WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  } 
  /* @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
  if(state == AppLifecycleState.resumed){
    // user returned to our app
     print("resumed");
  }else if(state == AppLifecycleState.inactive){
     
      print("inactive");
  }else if(state == AppLifecycleState.paused){
    print("paused11");
   SystemChannels.lifecycle.setMessageHandler((msg){
      debugPrint('SystemChannels> $msg');
    }); 
    // user is about quit our app temporally
  }//else if(state == AppLifecycleState.suspending){
    // app suspended (not used in iOS)
  //}
  }*/

  void getCurrentUser() async {
    //currentUser = await FirebaseAuth.instance.currentUser();
   // print(widget.data_p['uid']);
     await databaseRef
        .collection('flutter_driver')
        .document(widget.data_p['uid'])
        .snapshots()
        .forEach((element) {
          
              if(element['blok']){
                userBlok();
              }
            setState(() { 
                driver_saldo=element['saldo'];
                driver_point=element['point'];  
                //driver_trip=element['trip']; 
                widget.data_p['uid']= element['uid']; 
                widget.data_p['name']=element['name']; 
                widget.data_p['email']=element['email']; 
                widget.data_p['hp']=element['hp']; 
                widget.data_p['aktivasi']=element['aktivasi']; 
                widget.data_p['point']=element['point']; 
                widget.data_p['trip']=element['trip']; 
                widget.data_p['avatar']=element['avatar']; 
                var bintang=0;
                if (element['counter_reputation']!=0 && element['divide_reputation']!=0 ){
                    bintang = element['counter_reputation'] ~/ element['divide_reputation']  ;
                }else{
                    bintang= 0;
                }  
                 widget.data_p['bintang']=bintang; 
                
               
            });  

          }).catchError((err) {
              //print(err);
               if (mounted){
                  setState(() {
                      driver_saldo=0 ;
                      driver_point=0 ;  
                     // driver_trip=0 ;
                
                  });  
               }
          }); 
  }

  void setGCM() async{
     
       SharedPreferences localStorage = await SharedPreferences.getInstance(); 
       await localStorage.setString("gcm", gcm_token); 
       
      //  print(localStorage.getString('key'));
       
  }
    

  Future<Map> _getSharedData() async => await _channel.invokeMethod('getSharedData');
  
  Future<Map> _startActivity() async {
    try {
      sharedData = await _channel.invokeMethod('getSharedData');
      //setData(sharedData  );
     // debugPrint('Result: $sharedData ');
    } on PlatformException catch (e) {
      //debugPrint("Error: '${e.message}'.");
    }
  }

  _init() async { 
        SystemChannels.lifecycle.setMessageHandler((msg) async {
            print("SystemChannels $msg");
             
            if (msg.contains('resumed')) { 
             ///_startActivity();
               var data = await _getSharedData();
                setState(() {  
                 // sharedData = data;
                }); 
                ///print(sharedData);
                 
            }   
        });  
  }  


  static Future<dynamic> myBackgroundMessageHandler1(Map<String, dynamic> message) async {
   /*
      try {
      final String result = await platform.invokeMethod('onMessage');
      debugPrint('Result: $result ');
    } on PlatformException catch (e) {
      debugPrint("Error: '${e.message}'.");
    }*/
     //await platform1.invokeMethod('CloseSecondActivity');
     print("myBackgroundMessageHandler1 $message"); 
  //SharedPreferences localStorage = await SharedPreferences.getInstance();
    //   localStorage.setString("key", "value");
     
      
  //showNotification ( message);
    
    /*
    var android =   AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High,importance: Importance.Max
    );
    var iOS =   IOSNotificationDetails();
    var platform =   NotificationDetails(android, iOS);
   
    
    if (message.containsKey('data')) {
     // Handle data message
    //final dynamic data = message['data'];
      await flutterLocalNotificationsPlugin.show(
          0, '1111', '2222', platform,
          payload: '33333'); 
    }else if (message.containsKey('notification')) {
     // Handle notification message
      //final dynamic notification = message['notification'];
      await flutterLocalNotificationsPlugin.show(
        0, '5555555', '666666666', platform,
        payload: '77777777'); 
    } */
    return Future<void>.value();
     //return null;  
  }

  //persedian notifikasi untuk aplikasi sedang jalan
  static  showNotification(Map<String, dynamic> message) async {
    
     // await platform1.invokeMethod('CloseSecondActivity');
      
     var android =   AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
       priority: Priority.High,importance: Importance.Max
     );
     var iOS =   IOSNotificationDetails();
     var platform =   NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0, message['data']['body'], message['data']['title'], platform,
        payload: message['data']['message']);
         
  } 

  //jika notofikasi di atas di klik maka akan membuka ini
  Future  onSelectNotification(String payload ) {
    print("payload : $payload");
     
  }
    
  _getDrawerItemWidget(int pos) { 
     
    switch (_selectedDrawerIndex) {
      case 0:
        return   GoDriver(dataP: widget.data_p,);
        // return   SecondFragment();
      case 1:
      // return   FirstFragment();
         //return   SecondFragment(todo: "$_messageText");
      case 2:
        //return   ThirdFragment(); 
         // return   ScanScreen();  
      default: 
         //return   SecondFragment();
       return   GoDriver(dataP: widget.data_p, );
    }
  }
  
  _onSelectItem(int index) {
    // setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer 
   // _scaffoldKey.currentState.openEndDrawer(); 
      if( index==1){ 
           Navigator.push(  context, MaterialPageRoute(builder: (context) => Transaksi(data_p: widget.data_p,  )),  );
      }else  if( index==2){ 
           Navigator.push(  context, MaterialPageRoute(builder: (context) => TopUpSaldo( data_p: widget.data_p,)),  );
      }else if(index==3){
          Navigator.push(  context, MaterialPageRoute(builder: (context) => Inboxs( )),  );
      }else if(index==4){
          Navigator.push(  context, MaterialPageRoute(builder: (context) => Accounts (data_p: widget.data_p, )),  );
      } 
  }
  
  /*Future<void> _closeActivity() async {
    try {
      final String result = await platform1.invokeMethod('CloseSecondActivity');
      debugPrint('Result: $result ');
    } on PlatformException catch (e) {
      debugPrint("Error: '${e.message}'.");
    }
  }*/

  @override
  Widget build(BuildContext context) {
    List<Widget> drawerOptions = [];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      drawerOptions.add(
        new ListTile(
          leading: new Icon(d.icon),
          title: new Text(d.title),
          selected: i == _selectedDrawerIndex ,
          onTap: () => _onSelectItem(i),
        )
      );
    }

    return   Scaffold(
          //appBar: new AppBar(
            // here we display the title corresponding to the fragment
            // you can instead choose to have a static title
           // title: new Text(widget.drawerItems[_selectedDrawerIndex].title),
         // ),
          drawerEdgeDragWidth: 0, // TH
         // drawer: AppDrawerWidget( ), 
            key: _scaffoldKey,
           drawer:   Drawer(
            child:   Column(
              children: <Widget>[ 
                UserAccountsDrawerHeader(
                   //margin: EdgeInsets.all(1.0),
                  accountName: Text("${widget.data_p['name']}"),
                  accountEmail: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[ 
                     // Text("${widget.data_p['email']}"),  
                      Text("$driver_point pint"), 
                      Text("Saldo: Rp ${uang.format(driver_saldo)}"), 
                    ],
                  ), 

                  currentAccountPicture: CircleAvatar(
                    backgroundColor:
                    Theme.of(context).platform == TargetPlatform.iOS
                        ? Colors.blue
                        : Colors.white,
                    child: Text("${widget.data_p['name'][0]}",style: TextStyle(fontSize: 40.0),
                    ),
                  ),
                  otherAccountsPictures: <Widget>[
                    status_siap == true ? 
                    CircleAvatar(
                      backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                          ? Colors.white
                          : Colors.white ,
                      child: InkWell(
                        splashColor: Colors.grey[300], // splash color
                        onTap: () {
                            Navigator.of(context).pop();
                           setState(() {    
                                     status_siap = false; 
                              }); 
                            
                        }, // button pressed
                        child:Text("ON", 
                                style: TextStyle( 
                                  fontFamily: 'NeoSans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,color: Colors.green,
                                  ), 
                             ),
                        ),
                    ): 
                    CircleAvatar(
                      backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                            ? Colors.white
                            : Colors.white,
                        child:InkWell(
                        splashColor: Colors.grey[300], // splash color
                        onTap: () {
                          Navigator.of(context).pop();
                              setState(() {    
                                     status_siap = true; 
                              });   
                        }, // button pressed
                        child:Text("OFF", 
                                style: TextStyle( 
                                  fontFamily: 'NeoSans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0,color: Colors.red,
                                  ), 
                             ),
                        ),
                    )  
                  ] ), 
                  
                  Column(children: drawerOptions)
              ],
            ),
          ), 

           body: Builder(    builder: (context) =>   SafeArea( child :_getDrawerItemWidget(0)),  ),
          //body: SafeArea( child :_getDrawerItemWidget(0)) 
           //body: SafeArea(child: _optionButton[_selectedDrawerIndex]),
        ) ;  
  }

  void userBlok() {
       FirebaseAuth.instance
            .signOut()
            .then((result) { 
               //Navigator.of(context).pop();
               Navigator.pushReplacementNamed(context, '/login');  
                        
        });
     
  }

  void _showToast(BuildContext context) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Added to favorite'),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
}


 

 

 
    

 
 
 