 
import 'dart:async';
import 'dart:convert';
 
 
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driverojek/api/api.dart';

import 'package:flutter/cupertino.dart';
 
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
 
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

 
 
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter_rating_bar/flutter_rating_bar.dart'; 
 
import 'package:url_launcher/url_launcher.dart';
 
 
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../constans.dart';
import 'file_order/chat.dart';
import 'dart:collection'; 
   
class GoDriverPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) { 
     return Scaffold(
      body: GoDriver( ),
    );
  }
}

class GoDriver extends StatefulWidget {
  
  final Map<String, dynamic> dataP; 
  GoDriver({Key key, this.dataP}) : super(key: key);
  @override
  GoDriverState createState() => GoDriverState();
   
}


class GoDriverState extends State<GoDriver>  { 
   
  GoDriverState() {
		platform1.setMethodCallHandler((call) { 
      // print(call.method);
      //  print(call.arguments);  
      if(call.method=="gcm_masuk"){ 
        // print("aaaaaaaaaaaaaaaaaa ${call.arguments.cast<String, dynamic>()}");
        setData(call.arguments); 
      }

		});
  } 
  
  static const platform1 = const MethodChannel('ada_pesan_masuk'); 
  String  bear_token  ='';
  String   gcm_token  ='';

  //pesan driver
  final databaseRef = Firestore.instance;
  String map_tempat =  '';
  String map_alamat=''; 
  HashMap data_order_filter =   HashMap<dynamic, dynamic>(); 
  bool visible_button_terima_tolak= false;
  bool visible_bottom_bawah= false;
  bool  visible_button_sama_pelanggan= false;
  bool visible_tombol_chat= false;
  bool visible_nota_dilometer= false;
  bool visible_berikan_rating= false;

  int _state_terima = 0;
  //order
  String order = '';
  String order_uid = '';
  String timing='';   
  String judul_driver='OJEK'; 
  String category_order="";  
  double rating_value=0.0;
  var  Orderan = Orderan_Json.fromJson(  jsonDecode('{"category_driver": "category_driver","total_prices":0,"charge":0,"point_transaction":0,"polyline" :"polyline", "pay_categories": "pay_categories","pelanggan": "pelanggan","pelanggan_uid": "pelanggan_uid","pelanggan_avatar": "pelanggan_avatar","pelanggan_hp": "pelanggan_hp","pelanggan_bintang": "pelanggan_bintang","pelanggan_trip": "pelanggan_trip", "pelanggan_gcm": "pelanggan_gcm",   "jemput_judul": "jemput_judul","jemput_alamat": "jemput_alamat","jemput_ket": "jemput_ket","tujuan_judul":"tujuan_judul","tujuan_alamat": "tujuan_alamat","distance_text":"distance_text" }')  );
  String pay_label="TUNAI"; 
   
  
  int point_transaction=0;
  int charge=0; 

  bool visible_jemput= true;  
  static  LatLng jemputPosition = _initialPosition; 
  static  LatLng tujuanPosition = _initialPosition;
  bool visible_tujuan= false;  
  static int mode_map=0;
  static int mode_cari=0;
  static String status_order='';
 String   pelanggan_gcm  =''; 
  //var button 
  bool visible_header_jemput= false; 
  bool visible_button_set= false; 

  //var text keterangan
  bool visible_text_keterangan= true;  
  //var button mode bayar
  bool visible_mode_bayar= false;  
  //var divider
  bool visible_divider_buttom_jemput= false; 
  bool visible_divider_buttom_tujuan= false; 
  bool visible_divider_buttom_keterangan= false;  


  //marker jemput
  double iconSize = 40.0;  
  bool visible_marker_jemput= false;

  //marker tujuan
  bool visible_marker_tujuan= false;

  //tombol harga pesan 
  bool visible_harga_invalid = false;
  bool visible_button_order= false;
  bool visible_animation_waiting_order= false; 
  Timer _timer;
  int _start = 30;
  //SlidingUpPanel
   
  double  maxHeight  = 0.0;
  double  minHeight  = 0;  
  double  minBottomMap  =0;  
  PanelController _pc =   PanelController(); 
    
  //map
  String  key_api= "AIzaSyA706610W0aD4w2ueNR6seGrlHj5SpYOyM";
   
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  static  LatLng _initialPosition= LatLng(-3.47764787218,119.141805461); 
  static LatLng _lastMapPosition = LatLng(-3.47764787218,119.141805461)   ;
  Position _currentPosition;
 

  //map direction 
  Map<PolylineId, Polyline> _polylines = <PolylineId, Polyline>{}; 
  final Set<Marker> _markers = {};
  //GoogleMapPolyline _googleMapPolyline =  GoogleMapPolyline(apiKey: "AIzaSyBTokiA2EScfsUgZeuTcsTdpcrV11qAw8E");
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  //membuat respon google 
  //Polyline patterns
  List<List<PatternItem>> patterns = <List<PatternItem>>[
    <PatternItem>[], //line
    <PatternItem>[PatternItem.dash(30.0), PatternItem.gap(20.0)], //dash
    <PatternItem>[PatternItem.dot, PatternItem.gap(10.0)], //dot
    <PatternItem>[
      //dash-dot
      PatternItem.dash(30.0),
      PatternItem.gap(20.0),
      PatternItem.dot,
      PatternItem.gap(20.0)
    ],
  ];
   
  //pencarian tempat
  String _tempInput = "";
  
  String _currentInput = "";
  
  List<dynamic> _placePredictions = [];
  //Place _selectedPlace;
  PersistentBottomSheetController _controllerBottom; 
  
  double  heightOfModalBottomSheet =110;
   
  bool checkingOrdering = false; 
  bool success_checking = false;

  

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }  
  
  @override
  void initState(){  
      super.initState(); 
  
      setGCM(); 
      _modeFirstOpen();
    
  }

  void setGCM() async{
     SharedPreferences localStorage = await SharedPreferences.getInstance();
       bear_token  = localStorage.getString('token');
       gcm_token  = localStorage.getString('gcm'); 
  }
   
  //persedian notifikasi untuk aplikasi sedang jalan
  void  setData(Map<dynamic, dynamic> dataMasuk) async { 
   //  debugPrint(dataMasuk.toString());
    print(dataMasuk['data_json']);
     
    try { 
      if(dataMasuk['timing'] != timing && dataMasuk['order'] != "" && dataMasuk['order'] != null){ 
       
        setState(() {   
              //order and prices 
              timing = dataMasuk['timing'];   
              order=dataMasuk['order'];
              //category_order=dataMasuk['category_order']; 
              
               Orderan = Orderan_Json.fromJson(jsonDecode(dataMasuk['data_json']));
               
             /* //category_driver
              if( Orderan.category_driver=="ojek")   {
                judul_driver="OJEK";
              }else if(  Orderan.category_driver=="car4"){
                judul_driver="MOBIL-4";
              }else if(  Orderan.category_driver=="car6"){
                judul_driver="MOBIL-6";
              }else if(  Orderan.category_driver=="food"){
                judul_driver="FOOD"; 
                //total_gofood=dataMasuk['total_gofood']; 
              }else if(  Orderan.category_driver=="sembako"){
                judul_driver="SEMBAKO";
              /// total_sembako=dataMasuk['total_gofood']; 
              }else if(  Orderan.category_driver=="shop"){
                judul_driver="SHOP";
                //total_shop=dataMasuk['total_gofood'];
              }else if(  Orderan.category_driver=="kurir"){
                judul_driver="KURIR";
                //total_kurir=dataMasuk['total_kurir'];
              }
              //pay_categories
              if(  Orderan.pay_categories=="tunai")   {
                pay_label="TUNAI";
              }else if(  Orderan.pay_categories=="saldo"){
                pay_label="SALDO";
              } */
 
           //print('Howdy, ${Orderan.pelanggan}!');
           //print('We sent the verification link to ${user.email}.');
           // sharedData.put("body" ,intent.getStringExtra("body").toString() ) 
           // sharedData.put("title" ,intent.getStringExtra("title").toString() )
           // sharedData.put("message" ,intent.getStringExtra("message").toString() )  
            
            status_order='masuk';
            checkingOrdering = false;
            success_checking = false;
            _modeIncomingNewOrder();
            _start=5;
        });  
        _timer = Timer.periodic(  Duration(milliseconds:   1300), (time) { 
            if (_start < 1) { 
             
              setState(() {  
                FlutterRingtonePlayer.stop(); 
                _timer.cancel();
                 time.cancel();
               // _start=5;
              }); 
              
            } else {
              setState(() {    
                _start = _start - 1;
              });
              if(_start>=1){
                  FlutterRingtonePlayer.play(
                  android: AndroidSounds.ringtone,
                  ios: const IosSound(1023),
                  looping: false,
                  volume: 100.0,
                );
              } else{
                  if(status_order!='terima' && status_order!='tolak'){
                    setState(() {   
                        status_order='timeout';
                        _modeIncomingTimeOut();
                    }); 
                  }  
                FlutterRingtonePlayer.stop(); 
              }

            }  
          }); 
      }  
    } catch (e) {
      print('print err, from service: $e');
      throw (e.toString());
    } 
  } 
 
  //map 
  void  _getUserLocation() async {
   await  geolocator .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)  .then((Position position) {
      setState(() {
           _initialPosition = LatLng(position.latitude, position.longitude);
           _lastMapPosition = _initialPosition;
           _currentPosition = position;
           
          _moveToPosition(position);
      }); 
     
    }).catchError((e) {
       //_modeLoadingAdress();
       print(e);
    });
  }

  Future<void> _moveToPosition(Position pos) async {
    final GoogleMapController mapController = await _controller.future;
    if(mapController == null) return;
    print('moving to position ${pos.latitude}, ${pos.longitude}');
    await mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(pos.latitude, pos.longitude),
          zoom: 16.0, bearing: -20,
        )
      )
    );
  }
 
  void _getAdressLocation() async {  
    try {  
     
        List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(_lastMapPosition.latitude, _lastMapPosition.longitude);
        setState(() {  
          Placemark placeMark  = placemark[0]; 
          String name = placeMark.name;
          String subLocality = placeMark.subLocality;
          String locality = placeMark.locality;
          String administrativeArea = placeMark.administrativeArea;
          String postalCode = placeMark.postalCode;
          String country = placeMark.country;
          String address = "$name, $subLocality, $locality, $administrativeArea $postalCode, $country";
          
          print(address);  
          if (mode_map==0){ 
             
             jemputPosition = _lastMapPosition; 
           //  prov_1 = "$administrativeArea $postalCode"; 
            // ModeJemput();
          }else if (mode_map==1){
             
              tujuanPosition = _lastMapPosition;
             // prov_2 = "$administrativeArea $postalCode"; 
            // ModeTujuan(); 
          }  
        });

    } catch (e) {
     print('ERRORku>>$_lastMapPosition:$e');
     //_modeLoadingAdress() ; 
    }  
  }
    
  void _addPolyline(List<LatLng> _coordinates) {
    PolylineId id = PolylineId("poly$tujuanPosition");
    Polyline polyline = Polyline(
        polylineId: id,
        patterns: patterns[0],
        color: Colors.blueAccent,
        points: _coordinates,
        width: 7,
        onTap: () {
         
        } 
    ); 
    setState(() {
      _polylines[id] = polyline; 
      //_polylineCount++;
    });

       double latMin=  0 ;
       double latMax=  0; 
       double longMin =  0 ;
       double longMax =  0;

    if (jemputPosition.latitude >=   tujuanPosition.latitude){  
        latMin=   tujuanPosition.latitude ;
        latMax=   jemputPosition.latitude;
        longMin =   tujuanPosition.longitude ;
        longMax =   jemputPosition.longitude ;

        if(longMin >=   longMax){
              longMin =   jemputPosition.longitude ;
               longMax =   tujuanPosition.longitude ;
        }   
    }else{   
        latMin=   jemputPosition.latitude ;
        latMax=   tujuanPosition.latitude;

        longMin =   tujuanPosition.longitude ;
        longMax =   jemputPosition.longitude ;

        if(longMin >=   longMax){
              longMin =   jemputPosition.longitude ;
              longMax =   tujuanPosition.longitude ;
        }  
    } 

    mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(southwest: LatLng(latMin, longMin),  northeast:LatLng(latMax, longMax)),
          50.0,
    ));  
     print("setelah kamera");
  }

  //direction
  List<LatLng> decodeEncodedPolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p =   LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }
    
  Future<void>  getJsonDirection() async  { 
   try {
     //  String origin =  "${jemputPosition.latitude},${jemputPosition.longitude}";
       // String destination="${tujuanPosition.latitude},${tujuanPosition.longitude}";
 
       var data_post = { 
         
              
              'origin_lat': "${jemputPosition.latitude}",
              'origin_long': "${jemputPosition.longitude}",
              'destination_lat': "${tujuanPosition.latitude}",
              'destination_long': "${tujuanPosition.longitude}",
              //"category": category_driver,
             // "pay_categories": pay_categories  
           };
            
         await  http.post(
          //Uri.encodeFull removes all the dashes or extra characters present in our Uri
          Uri.encodeFull(GojekGlobal.DomainUrl+"gojekprice"),
          headers: {
            //if your api require key then pass your key here as well e.g "key": "my-long-key"
             "Accept": "application/json" ,
             "Content-type" : "application/json", 
             "Authorization" : "Bearer $bear_token", 
          },
          body:json.encode(data_post) 
        )
        .timeout(const Duration(seconds: 10))
        .then((onResponse){
              print(onResponse.body);
             //onResponse.request.finalize();
             if (onResponse.statusCode == 200) {
 
              String body = onResponse.body;
              String receivedJson = "[$body]";
              List  data = json.decode(receivedJson); 
              //print(  data[0]['routes'][0]['legs'][0]['distance']['text']); 
              // print(  data[0]['routes'][0]['legs'][0]['distance']['value']); 
              //print(  data[0]['routes'][0]['legs'][0]['duration']['text']); 
              // print(  data[0]['routes'][0]['legs'][0]['duration']['value']); 
              // print(  data[0]['routes'][0]['overview_polyline']['points'] );

              setState(() {
               // distance_text =  data[0]['routes'][0]['legs'][0]['distance']['text'];
               // distance_value= data[0]['routes'][0]['legs'][0]['distance']['value'].toString();
              // duration_text= data[0]['routes'][0]['legs'][0]['duration']['text']; 
              // duration_value=data[0]['routes'][0]['legs'][0]['duration']['value'].toString();

                //  distance_text = data[0]['distance_text'];
                //  distance_value= data[0]['distance_value'].toString();
                //  duration_text= data[0]['duration_text']; 
                //  duration_value=data[0]['duration_value'].toString();
                //   category_driver=data[0]['category'];
                  // pay_categories=data[0]['pay_categories'];
                 
                  point_transaction=data[0]['point_transaction'] ;
                  charge=data[0]['charge'];
                 // total_prices=data[0]['total_prices'];   
                   _polylines.clear(); 
              });
              //_addPolyline(decodeEncodedPolyline( data[0]['routes'][0]['overview_polyline']['points']));
               _addPolyline(decodeEncodedPolyline( data[0]['polyline']));
              print("object1");
              //ModeReadyToOrder(true,"");  

            }else if (onResponse.statusCode == 409) {
               String body = onResponse.body;
               String receivedJson = "[$body]";
               List  data = json.decode(receivedJson); 
               if(data[0]['prov_zona']!=null){
                    print("object prov_zona");
                    //ModeReadyToOrder(false,"Harga untuk di kota ini belum dapat ditampilkan :) ");
               }else{
                  print("object2");
                  //ModeReadyToOrder(false,"");
               }
                
            }else{ 
                 print("object222");
                 //ModeReadyToOrder(false,"");
            }
          }).catchError((onerror){
                print(onerror.toString());
                print("object3");
                //ModeReadyToOrder(false,"");
          });
          
           
      
    } catch (e) {
        print("object4");
       
        //ModeReadyToOrder(false,"");
        print('error!!!! $e');
    }  
       
  }

  Future<void>  getJsonPostOrder() async  { 
    try{ 
         var data_post = {
              'order':order, 
           };
         await  http.post( 
          Uri.encodeFull(GojekGlobal.DomainUrl+"gojekorder"),
          headers: { 
             "Accept": "application/json" , 
             "Authorization" : "Bearer $bear_token"
          },
          body: json.encode(data_post) 
        )
        .timeout(const Duration(seconds: 10))
        .then((onResponse){
            //print(onResponse.body);
            //onResponse.request.finalize();
            if (onResponse.statusCode == 200) { 
              String body = onResponse.body;
              String receivedJson = "[$body]";
              List  data = json.decode(receivedJson); 
             
              setState(() {
              
              }); 
             
              print("object1");
             // ModeReseiveTrue( );  

            }else{ 
              print("object2");
              //ModeReseiveFalse( );
            }
          }).catchError((onerror){
            print(onerror.toString());
            print("object3");
           // ModeReseiveFalse( );
          }); 
      
    } catch (e) {
        print("object4"); 
       /// ModeReseiveFalse( );
        print('error!!!! $e');
    }   
  }
 
  void  _tolakOrder() { 
    status_order='tolak';
    _modeTolakOrder();
    FlutterRingtonePlayer.stop();
    setState(() {    
      _start = 0;
    });

  }   
             
  void  _cekTerimaOrder() { 
    status_order='terima' ;
    _modeCekTerimaOrder();
    FlutterRingtonePlayer.stop();
    setState(() {    
      _start = 0;
    });
  }  
 
  void _kirimGcmTerimaOrder( ) async{ 
     
    data_order_filter.clear(); 
    data_order_filter['kd_transaksi']='$order'; 
   // data_order_filter['driver_id']= '';
    //data_order_filter['status_driver']= '';
    //data_order_filter['status_order']= '';
    data_order_filter['charge']=Orderan.charge ;
    data_order_filter['distance_text']=Orderan.distance_text ; 
   
    data_order_filter['pay_categories']= Orderan.pay_categories;
	  data_order_filter['category_driver']= Orderan.category_driver;
    data_order_filter['category_order']= Orderan.category_driver;
    data_order_filter['point_transaction']= Orderan.point_transaction;
    data_order_filter['polyline']= Orderan.polyline; 
    data_order_filter['total_prices']= Orderan.total_prices;
    data_order_filter['tujuan_alamat']= Orderan.tujuan_alamat;
    data_order_filter['tujuan_judul']= Orderan.tujuan_judul;
    data_order_filter['jemput_alamat']=Orderan.jemput_alamat;
    data_order_filter['jemput_judul']= Orderan.jemput_judul;
    data_order_filter['jemput_ket']=Orderan.jemput_ket;

    data_order_filter['driver_uid']= widget.dataP['uid'] ;
    data_order_filter['driver']=widget.dataP['name'] ; 
    data_order_filter['driver_hp']= widget.dataP['hp'];
    data_order_filter['driver_bintang']=widget.dataP['bintang'] ;
    data_order_filter['driver_trip']= widget.dataP['trip'] ; ;
    data_order_filter['driver_avatar']=widget.dataP['avatar'] ;
    data_order_filter['driver_gcm']=gcm_token;  

    var data = {  
        'to' : pelanggan_gcm,
        'priority' : 'high', 
        'time_to_live' : 60,  
        'data' : {  
            'body' : 'body',
            'title': 'title',
            'message': 'message',   
            'order' : '$order' , 
            'category_message': 'accept_order',  
            'data_json' : data_order_filter  ,  
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',  
      }
     };
    var res = await CallApi().postData(data, 'gcm');
     if (res.statusCode == 200) {  
        var receivedJson = '[${res.body}]';

        List  data = json.decode(receivedJson);  
           print(data[0]['success']);
        if(data[0]['success']=='0'){
           //setState(() {    habis_waktu_menunggu = false;  });
          // ModeReseiveFalse('Koneksi internet mungkin lagi lelet, Silah ulangi order' );
        } else{
           print('pertahankan mode sampai timer habis dan sampai dibalas oleh driver');
        }   
    }else{
       // setState(() {    habis_waktu_menunggu = false;  });
       // ModeReseiveFalse('Koneksi internet mungkin lagi lelet, Silah ulangi order' );
    }   
  }

  @override
  Widget build(BuildContext context){
    //_panelHeightOpen = MediaQuery.of(context).size.height ;
    //double fullSizeHeight = MediaQuery.of(context).size.height; 
    return MaterialApp(   
      debugShowCheckedModeBanner: false, 
     // theme:   ThemeData(
        //primarySwatch: Colors.teal,
       // canvasColor: Colors.transparent,
     // ),
      home:AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
           statusBarColor: Colors.transparent, // transparent status bar
          systemNavigationBarColor: Colors.black, // navigation bar color
          statusBarIconBrightness: Brightness.dark, // status bar icons' color
          systemNavigationBarIconBrightness: Brightness.dark, //navigation bar icons' color
        ),
        child:  //SizedBox.expand(
          //jika loadng map jika tidak ingin pakai loading map silahkan ganti
           _initialPosition == null ? Container(child: Center(child:Text('loading map..', style: TextStyle(fontFamily: 'Avenir-Medium', color: Colors.grey[400]),),),) : Container(
             child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[  

              Container(
                  height: MediaQuery.of(context).size.height- minBottomMap ,
                    alignment: Alignment.topCenter,
                    child:    Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                              
                          InkWell( 
                            child:  _body()
                          )
                        ],
                      ),
                ),
               
            
             // menu
              Positioned(
                left: 16.0,
                top: 16,
                child:    Container(
                      width: 48.0,
                      height: 48.0,
                      child: FloatingActionButton( 
                          heroTag: null,
                            child: Icon(
                              Icons.menu,
                              color: Colors.blue, 
                            ),
                          onPressed: (){   
                             Scaffold.of(context).openDrawer();
                          },
                          backgroundColor: Colors.white, 
                        ),  
                  ),  
               
              ),
            

              // the fab
              Positioned(
                right: 15.0,
                top:  15.0,
                child: Visibility(
                  visible: true,
                  child:  Container(
                      width: 48.0,
                      height: 48.0,
                       child: FloatingActionButton( 
                            heroTag: null,
                            child: Icon(
                              Icons.gps_fixed,
                              color: Colors.blue, 
                            ),
                          onPressed: () async {   
                              _getUserLocation();
                             
                           /* mapController.animateCamera(CameraUpdate.newCameraPosition(  CameraPosition(
                              //bearing: 192.8334901395799,
                              target: LatLng(_initialPosition.latitude, _initialPosition.longitude),
                              //tilt: 0,
                              zoom: 18.00))); */
                          },
                          backgroundColor: Colors.white, 
                        ), 

                       
                  ), 
                  
                ),
              ),
               
             
              SlidingUpPanel(
                  backdropEnabled: false,
                 // maxHeight: maxHeight,//_panelHeightOpen,
                  minHeight: minHeight,//_panelHeightClosed, minHeight
                  parallaxEnabled: true,
                  parallaxOffset: .5,
                  controller: _pc, 
                  // body:    _body(), 
                  panelBuilder: (sc) => _panel(sc),
                  // panel:  _panel(sc),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
                  onPanelSlide: (double pos) => setState((){ 
                  
                     
                  }),
              ), 
              
              //button terima tolak
              Positioned(
                bottom:   0.0, 
                child: Visibility(
                  visible: visible_bottom_bawah ,//false  true
                  child: Container(
                      // height: 100,
                      width: MediaQuery.of(context).size.width  ,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        //borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
                        boxShadow: [BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, .25),
                          blurRadius: 16.0
                        )],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                      children: <Widget>[
                        _tombolterima(),  
                        //SheetButton() 
                        !checkingOrdering ? SizedBox( height: 0.0, ) :  
                        !success_checking ?  CircularProgressIndicator(semanticsValue:  "Loading",semanticsLabel: "Loading",)   : 
                         Container( height: 50.0,
                           child:  Icon(Icons.check,color: Colors.green,size: 32,),
                         ),
                        _tombolSamaPelanggan(),    
                      ],
                    )  , 
                  ),  
                ),
              ), 

            ], 
          ),
       ),
       
       
     ) 
    );
  }
   
  Widget _body(){
    return  GoogleMap( 
      polylines: Set<Polyline>.of(_polylines.values),
      markers: _markers,
      mapToolbarEnabled: false,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: false,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      compassEnabled:false , 
      zoomGesturesEnabled: true,
      trafficEnabled: true, 
       zoomControlsEnabled: false,     
      // showUserLocation: true,
      // mapViewType: MapViewType.normal,
      //trackCameraPosition: true,
      mapType: MapType.normal,
      //markers: Set.of((marker != null) ? [marker] : []),
      //circles: Set.of((circle != null) ? [circle] : []),
      initialCameraPosition:CameraPosition(
        target:  _initialPosition  ?? LatLng(-3.47764787218,119.141805461),
        zoom: 16.0, 
        bearing: 20,//berputar
      ),
      //markers: _markers.values.toSet(),
       onCameraMoveStarted: () {
         // print('onCameraMoveStarted');
      },
      onCameraMove: (CameraPosition cameraPosition) { 
        _lastMapPosition = cameraPosition.target; 
         // maxHeight   = 350; 
        //  minHeight   = 280;
      },
      onCameraIdle:(){  
        if ( mode_map==0 || mode_map==1 ){
          if(_currentPosition!=null){
           // _getAdressLocation(); 
          }else{
            _getUserLocation() ;
          }
        }  
        
      },  
      onMapCreated: (GoogleMapController controller)   { 
        setState(() {
         
          if( mapController == null ){  
                  mapController=controller;  
                  _controller.complete(controller); 
          }
        });  
      },  
    ); 

  }

  Widget _panel(ScrollController sc){
    return   MediaQuery.removePadding(
      context: context, 
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.only(left: 16,right: 16,top: 0),
        child: ListView(
          controller: sc,
          children: <Widget>[  
            //icon drag
            Icon(Icons.drag_handle, size: 16.0, color: Colors.grey),

            //2 header pilihan kategori kedaraan
            Visibility(
              visible: true, 
              child: Row(  
                 //crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[ 
                  Text(
                    "$judul_driver",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black,fontFamily: 'NeoSansBold',
                      fontSize: 18,    decoration: TextDecoration.none, 
                    ),
                  ),  
                  Align(  
                    child:  Visibility(
                      visible: visible_tombol_chat, 
                      child:  Container(  
                        width: 27,
                        height: 27,
                        margin:   EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
                        child:  SizedBox.fromSize(
                              size: Size(30, 40), // button width and height
                              child: ClipOval(
                                child: Material(
                                  color: Colors.white, // button color
                                  child: InkWell(
                                    splashColor: Colors.grey[300], // splash color
                                    onTap: () {
                                      print(widget.dataP);
                                      Navigator.push(
                                          context,  MaterialPageRoute(  builder: (context) => Chat(
                                            dataP: widget.dataP,
                                            peerId: '${Orderan.pelanggan_uid}',
                                            //peerAvatar: '${Orderan.pelanggan_avatar}',
                                           peerAvatar: 'https://miro.medium.com/fit/c/96/96/2*Wl0tiOnPz15_5MIjocdjVQ.jpeg',
                                          ))); /* */
                                    },  
                                    child:   Icon(Icons.message,color: Colors.blue,), // ico
                                  ),
                                ),
                              ),
                           ),
                      /* 
                       Row( 
                        crossAxisAlignment: CrossAxisAlignment.center,
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                           SizedBox.fromSize(
                              size: Size(30, 40), // button width and height
                              child: ClipOval(
                                child: Material(
                                  color: Colors.white, // button color
                                  child: InkWell(
                                    splashColor: Colors.grey[300], // splash color
                                    onTap: () {
                                       //buka chat order chat
                                    },  
                                    child:   Icon(Icons.message,color: Colors.blue,), // ico
                                  ),
                                ),
                              ),
                           ),
                           SizedBox(width: 16,),
                            SizedBox.fromSize(
                              size: Size(30, 40), // button width and height
                              child: ClipOval(
                                child: Material(
                                  color: Colors.white, // button color
                                  child: InkWell(
                                    splashColor: Colors.grey[300], // splash color
                                    onTap: () {
                                        //buka telepon $pelanggan_hp
                                        launch("tel://${Orderan.pelanggan_hp}");
                                    },  
                                    child:   Icon(Icons.call,color: Colors.green, ), // ico
                                  ),
                                ),
                              ),
                           ),
                          
                        ],
                      ),*/
                       ),
                    ),
                  )
                ],
              ),
            ),
            
            //garis
            Divider(  color: Colors.grey,  height:5, ),
 
             //dipesan oleh pelanggan
            Visibility(
              visible: true,
              child: RaisedButton(
                onPressed: () {
                 
                },
                shape:   RoundedRectangleBorder(
                  borderRadius:   BorderRadius.circular(5.0),
                ), 
                color: Colors.white,elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
                child: Row(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [ 
                    /*Padding(
                      padding: const EdgeInsets.only( right: 6),
                      child: 
                        Icon(  Icons.adjust ,  size: 32.0, color: Colors.orange ), 
                    ), */ 
                    Expanded(
                    child:
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [  
                          Text("Dipesan oleh : " , maxLines: 1,
                            style: TextStyle( 
                                  fontFamily: 'NeoSans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  letterSpacing: 0,
                            ), 
                          ),
                          Text("${Orderan.pelanggan}" , maxLines: 1,
                            style: TextStyle( 
                                  fontFamily: 'NeoSans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0,
                            )
                          ), 
                          Container(
                            child: Row(
                              //crossAxisAlignment: CrossAxisAlignment.start,
                              children: [  
                                    Icon(  Icons.grade ,  size: 16.0, color: Colors.orange ), 
                                    Text(" ${Orderan.pelanggan_bintang}" , maxLines: 1,
                                        style: TextStyle( 
                                              fontFamily: 'NeoSans',
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0,
                                        ), 
                                      ),
                                    SizedBox(width: 16,),
                                    Icon(  Icons.directions_bike ,  size: 16.0, color: Colors.orange ),
                                     
                                    Text(" ${Orderan.pelanggan_trip}" , maxLines: 3,
                                        style: TextStyle( 
                                              fontFamily: 'NeoSans',
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                              letterSpacing: 0,
                                        )
                                      ),  
                              ],
                            ),
                          ) 
                        ],
                      ),
                    ),
                   //  Icon(  Icons.search ,  size: 16.0, color: Colors.grey ),  
                  ],
                ),
              ), 
            ),

             //garis
            Visibility(
                visible: true,maintainSize:false,
                child:  Divider(  color: Colors.grey,  height:5,  ),
            ),
  
            //3 alamat jemput  
            Visibility(
                visible: true,
                child:    RaisedButton(
                onPressed: () {  
                  
                },
                shape:   RoundedRectangleBorder(
                  borderRadius:   BorderRadius.circular(5.0),
                ), 
                color: Colors.white,elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
                child: Row(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [ 
                  Padding(
                    padding: const EdgeInsets.only( right: 6),
                    child: 
                       Icon(  Icons.gps_fixed ,  size: 32.0, color: Colors.blue ), 
                  ),  
                  Expanded(
                  child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Jemput : ${Orderan.jemput_judul}" , maxLines: 1,
                          style: TextStyle( 
                                fontFamily: 'NeoSans',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0,
                          ), 
                        ),
                        Text("${Orderan.jemput_alamat}"  , maxLines: 3, softWrap: true,
                            style: TextStyle( 
                                  fontFamily: 'NeoSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  letterSpacing: 0,
                            ),
                        ),
                         
                      ],
                    ),
                  ),
                  // Icon(  Icons.search ,  size: 16.0, color: Colors.grey ),  
                ],
              ),
            ), 
            ),
           
           
            //8 keterangan jemput    
            Visibility(  maintainSize:false,
                visible: true,
                child:Container(  
                  //padding:   EdgeInsets.symmetric(vertical: 1.0, horizontal: 0.0),
                  //margin:   EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                  decoration: BoxDecoration(
                      color: GojekPalette.grey200,
                      border: Border.all(
                        color: Colors.grey,
                        width: 0.3,
                      ), 
                      borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Row( 
                      crossAxisAlignment: CrossAxisAlignment.center,
                     //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(6) ,
                        child: Icon(Icons.message, size: 24.0, color: Colors.green),
                      ), 
                      Expanded( 
                        child: Text("${Orderan.jemput_ket}" , maxLines: 2, softWrap: true,
                            style: TextStyle( 
                                  fontFamily: 'NeoSans',
                                  fontSize: 11,color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  letterSpacing: 0,
                            ),
                        ),
                      ),
                      
                    ],
                  ),
                ),
             ),   
           
           
            //garis
            Visibility(
                visible: true,maintainSize:false,
                child:  Divider(  color: Colors.white,  height:10,  ),
            ),
  
             //6 alamat tujuan    
            Visibility(
              visible: true,
              child: RaisedButton(
                onPressed: () {
                 
                },
                shape:   RoundedRectangleBorder(
                  borderRadius:   BorderRadius.circular(5.0),
                ), 
                color: Colors.white,elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
                child: Row(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [ 
                    Padding(
                      padding: const EdgeInsets.only( right: 6),
                      child: 
                        Icon(  Icons.adjust ,  size: 32.0, color: Colors.orange ), 
                    ),  
                    Expanded(
                    child:
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [  
                          Text("Tujuan : ${Orderan.tujuan_judul}" , maxLines: 1,
                            style: TextStyle( 
                                  fontFamily: 'NeoSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0,
                            ), 
                          ),
                          Text("${Orderan.tujuan_alamat}"  , maxLines: 3,
                            style: TextStyle( 
                                  fontFamily: 'NeoSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  letterSpacing: 0,
                            )
                          ), 
                          /*Text(tujuan_alamat , maxLines: 2,
                            style: TextStyle( 
                                  fontFamily: 'NeoSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  letterSpacing: 0,
                            )
                          ),*/ 
                        ],
                      ),
                    ),
                   //  Icon(  Icons.search ,  size: 16.0, color: Colors.grey ),  
                  ],
                ),
              ), 
            ),

             //garis
            Visibility( 
                visible: true ,maintainSize:false,
                child:  Divider(  color: Colors.white, height:5,   ),
            ),
  
            //nota dan km
            Visibility( 
              maintainSize:false,
              visible: visible_nota_dilometer,
              child: Container(  
                padding:   EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
                child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, 
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[  
                    Text(
                      "${Orderan.distance_text}",
                      style: TextStyle(
                       letterSpacing: 0,
                        fontSize: 14.0,color: Colors.black, decoration: TextDecoration.none, 
                      ),
                    ),
                    Text(
                      "$order",
                      style: TextStyle(
                       letterSpacing: 0,
                        fontSize: 14.0,color: Colors.black, decoration: TextDecoration.none, 
                      ),
                    ),
                ]
              ),
               ),
            ), 

            // mode bayar    dan harga
            Visibility( 
                maintainSize:false,
                visible: true,
                child:Container(   
                   padding:   EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                  //margin:   EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                   decoration: BoxDecoration(
                      //color: Colors.grey[100],
                      border: Border.all(
                        color: Colors.grey,
                        width: 0.3,
                      ), 
                      borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Row(  
                    children: <Widget>[
                         Expanded(child: 
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Text("$pay_label",
                                style: TextStyle( 
                                      fontFamily: 'NeoSans',
                                      fontSize: 13, color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                      letterSpacing: 1,
                                ), 
                              ),
                            ) 
                          ),
                          SizedBox(height:60 ,),
                         Expanded(child: 
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text("Rp1ttt11 . ${Orderan.total_prices}",
                                style: TextStyle( 
                                      fontFamily: 'NeoSans',
                                      fontSize: 16,  color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0,
                                ), 
                              ),
                            ) 
                          ) 
                    ],
                  ),
                ),
             ),  
   
            SizedBox(height:  16,), 

             //berikan rating
            Visibility(  
              maintainSize:false, 
              visible: visible_berikan_rating,
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[ 
                  Text(
                    "Bagaimana pelanggan anda?",
                    style: TextStyle(
                      fontWeight: FontWeight.w300, letterSpacing: 0,
                      fontSize: 20.0,color: Colors.black, decoration: TextDecoration.none, 
                    ),
                  ),
                  SizedBox(     height: 16.0,   ),
                   RatingBar(
                    initialRating: 3,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                        rating_value= rating;
                    },
                  ), 
                ]
              ),
            ),
                    
          
          ],
        ),
      ),  
    );
  }

  Widget _tombolterima() {
    return  Visibility(
      visible: visible_button_terima_tolak ,//false  true
      child: Container( 
        child: Row(  
          children: <Widget>[
            Expanded(
              child:  Align(
                alignment: Alignment.topLeft,  
                child: MaterialButton(
                  onPressed:(){ 
                      _tolakOrder();
                  },
                  shape:   RoundedRectangleBorder(
                    borderRadius:   BorderRadius.circular(20.0),
                  ), 
                  color: Colors.orange[100], 
                  padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
                  child:  Icon(Icons.clear, size: 26.0, color: Colors.red),
                  
                  ), 
              ) 
            ),
            Expanded(
            child:  Align(
                alignment: Alignment.topLeft,  
                child: MaterialButton(
                  color: Colors.green,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[ 
                      Text("TERIMA",
                        style: TextStyle( 
                              fontFamily: 'NeoSans',
                              fontSize: 14,color: Colors.white,
                              fontWeight: FontWeight.normal,
                              letterSpacing: 1,
                        ), 
                        ),
                        SizedBox(width: 6,),
                        Container(
                            decoration: BoxDecoration(
                              color:  Color(0xff319055), 
                              borderRadius: BorderRadius.circular(132.0),
                          ), 
                          height: 27, width: 28,
                            child: Center(
                            child: Text("$_start",
                                style: TextStyle( 
                                  fontFamily: 'NeoSans',
                                  fontSize: 14,color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  letterSpacing: 1,
                            ), 
                          ),  
                        )  
                      ) 
                      
                    ],
                  ),
                  onPressed: ()  { 
                     setState(() {
                        checkingOrdering = true;  
                     }); 
                      _cekTerimaOrder(); 

                    },
                  shape:   RoundedRectangleBorder(
                    borderRadius:   BorderRadius.circular(20.0),
                  ) ,
                ) 
              ), 
            ),   
          ]
        ),
      ) , 
    );

   
  }  

  Widget _tombolSamaPelanggan() {
    return  Visibility(
      visible: visible_button_sama_pelanggan ,//false  true
      child: Container( 
        child:
            //  Padding(
            //  padding: const EdgeInsets.all(16.0),
           // child: 
               MaterialButton(
                shape:   RoundedRectangleBorder(
                    borderRadius:   BorderRadius.circular(20.0),
                ), 
                child: setUpButtonChild(),
                onPressed: () {
                  setState(() {
                    if (_state_terima == 0) {
                      _modeSamaPelanggan() ;
                      animateButton(0); 
                    }else if (_state_terima == 2) {
                      _modeSelesai(); 
                      animateButton(2); 
                    }else if (_state_terima == 4) {
                      _modeSimpanRating( );
                      animateButton(4);
                    }
                  });
                },
                elevation: 4.0,
                minWidth: double.infinity,
                 height: 40.0,
                color: 
                _state_terima == 0 ? Colors.green : 
                _state_terima == 1 ? Colors.green : 
                _state_terima == 2 ? Colors.blue : 
                _state_terima == 3 ? Colors.blue : Colors.purple ,
              ),
           // ), 
      ) , 
    );

   
  }  

  Widget setUpButtonChild() {
    if (_state_terima == 0) { 
       return  Text(
        "BERSAMA PELANGGAN",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ); 
    } else if (_state_terima == 1) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else if (_state_terima == 2) {
      return Text(
        "SELESAI MENGANTAR",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      );
    }else if (_state_terima == 3) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else if (_state_terima == 4) {
      return Text(
        "SIMPAN RATING",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      );
    }else if (_state_terima == 5) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    }else {
      return Icon(Icons.check, color: Colors.white);
    }
  }

  void animateButton(int _step) {
    setState(() {
        if (_step == 0) {
           _state_terima = 1;
        }else if (_step == 2) {
          _state_terima = 3;
        }else if (_step == 4) {
          _state_terima = 5;
        }
      
    });

    Timer(Duration(milliseconds: 500), () {
      setState(() {
        if (_state_terima == 1) {
           _state_terima = 2;
        }else if (_state_terima == 3) {
          _state_terima = 4;
        }else if (_state_terima ==5) {
          _state_terima = 6;
           _pc.hide();
          _pc.close(); 
          _modeFirstOpen();
        }
      
      });
    });
  }
 
  void _modeFirstOpen() {
    print('ModeFirstOpen');
    maxHeight  = 1 ; 
    minHeight  = 0 ;  
    //_pc.hide();
    //_pc.close(); 
    _polylines.clear(); 
    _markers.clear();
    _start=0; 
    _placePredictions = [];  
    status_order='kosong';
  
    maxHeight  =1; // maxHeight   =350;
    minHeight  =0;  // minHeight  =150;  
    minBottomMap  = 0; //137;  122
  
    visible_button_terima_tolak = false;  
    visible_bottom_bawah= false;
    visible_button_sama_pelanggan= false;
    visible_tombol_chat= false;
    visible_nota_dilometer= false;
    visible_berikan_rating= false;
    _state_terima=0;
    /* map_tempat= '';
    map_alamat=''; 

    //orderan
    order='';
    timing='';
    judul_driver='';


    visible_header_jemput= true; 
    visible_jemput= true; 
    visible_marker_jemput= true;
  
    
    visible_tujuan= false; 
    visible_mode_bayar= false; 
    visible_marker_tujuan= false;
    
  
    visible_text_keterangan= true;
    visible_button_set= false; 
    visible_divider_buttom_jemput= false; 
    visible_divider_buttom_tujuan= false; 
    visible_divider_buttom_keterangan= false;  
    visible_button_order= false;
    visible_harga_invalid = false;
    visible_animation_waiting_order= false;
    */
       
  }
  
  void _modeIncomingNewOrder() {
    _pc.show();
    _pc.open();
    maxHeight  = 350 ;  // maxHeight   =350; maxHeight  =1;
    minHeight  = 150 ;  // minHeight  =150;   minHeight  =0;
    minBottomMap  = 137; //137;  122
  
    visible_button_terima_tolak = true;  
    visible_bottom_bawah= true;
    visible_button_sama_pelanggan= false  ; 
    visible_tombol_chat= false;
    visible_nota_dilometer= true;
    visible_berikan_rating= false;
    /**
     * pempentukan tampilan order berdasarkan kenis pesanan masuk
     * 
     */
     //category_driver
      if( Orderan.category_driver=="ojek")   {
        judul_driver="OJEK";
      }else if(  Orderan.category_driver=="car4"){
        judul_driver="MOBIL-4";
      }else if(  Orderan.category_driver=="car6"){
        judul_driver="MOBIL-6";
      }else if(  Orderan.category_driver=="food"){
        judul_driver="FOOD"; 
        //total_gofood=dataMasuk['total_gofood']; 
      }else if(  Orderan.category_driver=="sembako"){
        judul_driver="SEMBAKO";
      /// total_sembako=dataMasuk['total_gofood']; 
      }else if(  Orderan.category_driver=="shop"){
        judul_driver="SHOP";
        //total_shop=dataMasuk['total_gofood'];
      }else if(  Orderan.category_driver=="kurir"){
        judul_driver="KURIR";
        //total_kurir=dataMasuk['total_kurir'];
      }
      //pay_categories
      if(  Orderan.pay_categories=="tunai")   {
        pay_label="TUNAI";
      }else if(  Orderan.pay_categories=="saldo"){
        pay_label="SALDO";
      } 

  }

  void _modeIncomingTimeOut() {
    print("_modeIncomingTimeOut");
    
    maxHeight  = 1 ; 
    minHeight  = 0 ;   
    _pc.hide();
    _pc.close();
    minBottomMap  = 0; 

    visible_button_terima_tolak = false; 
    visible_bottom_bawah= false; 
  }

  void _modeTolakOrder() {
    print("_modeTolakOrder");
    maxHeight  = 1 ; 
    minHeight  = 0 ;  
    _pc.hide();
    _pc.close(); 
    minBottomMap  = 0; 
  
    visible_button_terima_tolak = false;  
    visible_bottom_bawah= false;  
    _state_terima=0;
  }

  Future<void> _modeCekTerimaOrder() async {
    print("_modeCekTerimaOrder");
    maxHeight  = 1 ; 
    minHeight  = 0 ;   
    minBottomMap  = 60; 
    _pc.hide();
    _pc.close(); 

    visible_button_terima_tolak = false;  
    visible_bottom_bawah= true;  
     visible_button_sama_pelanggan= false;
    /**
     * pembuatan data order masuk
     * jika sukses artinya belum ada driver yg menerima order
     * jika gagal kemungkinan dimbil sama driver lain atau
     * gagal dijaringan
     */
    //print("order:$order");
      //metode cek apakah kode belum terpakai  
       databaseRef.collection('flutter_order')
     // .document(Orderan.category_driver)
     // .collection('order')
      .where('kd_transaksi',isEqualTo: '$order')
      .where('driver_id',isEqualTo: '')
      .getDocuments().then((event)   {
          if (event.documents.isNotEmpty) {
             order_uid=event.documents[0].documentID;
             print('mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm $order_uid');
              databaseRef .collection('flutter_order') 
                .document(order_uid)
                .updateData({
              'kd_transaksi':'$order',  
              'driver_id': widget.dataP['uid'],
              'status_driver': 'terima',
            }).then((res) {
                  print('success' ); 
                   _kirimGcmTerimaOrder( );
                  _updateStatusDriver('sibuk'); 
                  _modeTerimaOrder(); 
                  setState(() {
                        success_checking = true; 
                    }); 
                 // Future.delayed(Duration(milliseconds: 500)); 
                 
            }).catchError( (err) {
                 setState(() {
                        success_checking = true; 
                    }); 
                 /// Future.delayed(Duration(milliseconds: 500));
                _modeTolakOrder(); 
                _toas("Telah diambil driver lain") ; 
                   print('belum_gaga1'); 
            });

          }else{ 
              print('belum_gaga2'); 
                setState(() {
                        success_checking = true; 
                }); 
                 // Future.delayed(Duration(milliseconds: 500)); 
                _modeTolakOrder(); 
                _toas("Telah diambil driver lain") ;  
          }
      }).catchError((e) {
         print('ada_gaga1');
         setState(() {
                        success_checking = true; 
         }); 
         // Future.delayed(Duration(milliseconds: 500)); 
        _modeTolakOrder(); 
        _toas("Telah diambil driver lain") ;  
         
      });   
     
  }

  void _modeTerimaOrder() {
    print("_modeTerimaOrder");
    _pc.show();
    _pc.open();
    maxHeight  = 350 ;  
    minHeight  = 150 ;  
    minBottomMap  = 137;  
    setState(() {
        visible_button_terima_tolak = false;  
        visible_bottom_bawah = true; 
        visible_button_sama_pelanggan= true;
        visible_tombol_chat= true;

        checkingOrdering = false;  
        success_checking = false;  
    }); 
  }

  void _modeSamaPelanggan() {
      print("_modeSamaPelanggan");
      databaseRef .collection('flutter_order') 
      .document(order_uid)
      .updateData({ 
        'status_driver': 'antar', 
      
      }).then((res) { 
        
      }).catchError( (err) { 
          
      });
  }

  void _modeSelesai() {
      print("_modeSelesai");
   databaseRef .collection('flutter_order')
    . document(order_uid)
    .updateData({ 
        'status_driver': 'finish',
        'status_order': 'finish',   
    }).then((res) { 
       visible_berikan_rating=true;
       _simpanPointDriver( );
       _simpanPointPelanggan();
    }).catchError( (err) {
      
    });
  }

  void _modeSimpanRating() {
    print("_modeSimpanRating");

     databaseRef.collection('flutter_customer') 
      .where('uid',isEqualTo: Orderan.pelanggan_uid) 
      .getDocuments().then((event)   {
          if (event.documents.isNotEmpty) {
             // counter_reputation
             //divide_reputation point trip
            // int trip_baru=event.documents[0]['trip']+1;
            // int point_baru=event.documents[0]['point']+Orderan.point_transaction;
             double counter_reputation_baru=event.documents[0]['counter_reputation'] +rating_value;
             int divide_reputation_baru=event.documents[0]['divide_reputation']+1;
              
              databaseRef .collection('flutter_customer')
                .document( Orderan.pelanggan_uid)
                .updateData({ 
                   // 'trip': trip_baru,
                   // 'point': point_baru, 
                    'counter_reputation': counter_reputation_baru,
                    'divide_reputation': divide_reputation_baru,  
                }).then((res) {
                  
                }).catchError( (err) {
                  
                });

          }else{ 
              
          }
      }).catchError((e) {
         
         
      });   
  }
  
  void _simpanPointDriver() {
    print("_simpanPointDriver");

     databaseRef.collection('flutter_driver') 
      .where('uid',isEqualTo: widget.dataP['uid']) 
      .getDocuments().then((event)   {
          if (event.documents.isNotEmpty) {
             // counter_reputation
             //divide_reputation point trip
              int trip_baru=event.documents[0]['trip']+1;
             int point_baru=event.documents[0]['point']+Orderan.point_transaction;
            // double counter_reputation_baru=event.documents[0]['counter_reputation'] +rating_value;
            // int divide_reputation_baru=event.documents[0]['divide_reputation']+1;
              
              databaseRef .collection('flutter_driver')
                .document( widget.dataP['uid'])
                .updateData({ 
                     'trip': trip_baru,
                     'point': point_baru, 
                   // 'counter_reputation': counter_reputation_baru,
                   // 'divide_reputation': divide_reputation_baru,  
                }).then((res) {
                  
                }).catchError( (err) {
                  
                });

          }else{ 
              
          }
      }).catchError((e) {
         
         
      });   
  }
  
  void _simpanPointPelanggan() {
    print("_modeSimpanPointPelanggan");

     databaseRef.collection('flutter_customer') 
      .where('uid',isEqualTo: Orderan.pelanggan_uid) 
      .getDocuments().then((event)   {
          if (event.documents.isNotEmpty) {
             // counter_reputation
             //divide_reputation point trip
              int trip_baru=event.documents[0]['trip']+1;
             int point_baru=event.documents[0]['point']+Orderan.point_transaction;
            // double counter_reputation_baru=event.documents[0]['counter_reputation'] +rating_value;
            // int divide_reputation_baru=event.documents[0]['divide_reputation']+1;
              
              databaseRef .collection('flutter_customer')
                .document( Orderan.pelanggan_uid)
                .updateData({ 
                    'trip': trip_baru,
                     'point': point_baru, 
                   // 'counter_reputation': counter_reputation_baru,
                   // 'divide_reputation': divide_reputation_baru,  
                }).then((res) {
                  
                }).catchError( (err) {
                  
                });

          }else{ 
              
          }
      }).catchError((e) {
         
         
      });   
  }

  void _updateStatusDriver( String status_drivernya){
      databaseRef .collection('flutter_driver') 
      .document(widget.dataP['uid'])
      .updateData({ 
             'status_driver': status_drivernya,  
         }).then((res) { 
        
      }).catchError( (err) { 
          
      });
  }
  
  void _toas(String msg){ 
     Fluttertoast.showToast(
                    msg: msg ,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
  }

} 

      

class Orderan_Json {
  final String category_driver;
  final int total_prices; 
  final int charge;
  final int point_transaction;
  final String polyline;
  final String pay_categories;
  final String pelanggan;
  final String pelanggan_uid;  
  final String pelanggan_avatar;  
  final String pelanggan_hp;
  final String pelanggan_bintang;
  final String pelanggan_trip;
  final String pelanggan_gcm;
  final String jemput_judul;
  final String jemput_alamat;
  final String jemput_ket;
  final String tujuan_judul;
  final String tujuan_alamat;
  final String distance_text;

  Orderan_Json(
    this.category_driver,
    this.total_prices,
    this.charge,
    this.point_transaction,
    this.polyline,
    this.pay_categories,
    this.pelanggan,
    this.pelanggan_uid,
    this.pelanggan_avatar,
    this.pelanggan_hp,
    this.pelanggan_bintang,
    this.pelanggan_trip,
    this.pelanggan_gcm,
    this.jemput_judul,
    this.jemput_alamat,
    this.jemput_ket,
    this.tujuan_judul,
    this.tujuan_alamat,
     this.distance_text
  );

  Orderan_Json.fromJson(Map<String, dynamic> json)
      : category_driver = json['category_driver'], 
       total_prices = json['total_prices'],
      charge = json['charge'],
      point_transaction = json['point_transaction'],
      polyline = json['polyline'], 
       pay_categories = json['pay_categories'],
       pelanggan = json['pelanggan'],
       pelanggan_uid = json['pelanggan_uid'],
      pelanggan_avatar = json['pelanggan_avatar'],
       pelanggan_hp = json['pelanggan_hp'],
       pelanggan_bintang = json['pelanggan_bintang'],
       pelanggan_trip = json['pelanggan_trip'],
       pelanggan_gcm= json['pelanggan_gcm'],
       jemput_judul = json['jemput_judul'],
       jemput_alamat = json['jemput_alamat'],
       jemput_ket = json['jemput_ket'],
       tujuan_judul = json['tujuan_judul'],
       tujuan_alamat = json['tujuan_alamat'],
       distance_text = json['distance_text']
       ;

  Map<String, dynamic> toJson() =>
    {
       'category_driver': category_driver, 
       'total_prices': total_prices,
      'charge':charge ,
      'point_transaction' :point_transaction ,
      'polyline' :polyline , 
       'pay_categories': pay_categories,
       'pelanggan': pelanggan,
       'pelanggan_uid': pelanggan_uid,
        'pelanggan_avatar': pelanggan_avatar,
       'pelanggan_hp': pelanggan_hp,
       'pelanggan_bintang': pelanggan_bintang,
       'pelanggan_trip': pelanggan_trip,
       'pelanggan_gcm': pelanggan_gcm,
       'jemput_judul': jemput_judul,
       'jemput_alamat': jemput_alamat,
       'jemput_ket': jemput_ket,
       'tujuan_judul': tujuan_judul,
       'tujuan_alamat': tujuan_alamat,
      'distance_text':distance_text 
    };

   
}
