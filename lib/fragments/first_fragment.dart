
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class FirstFragment extends StatelessWidget {

 const FirstFragment({ Key key }) : super(key: key);
  
    @override
  Widget build(BuildContext context){
   
    
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
        child:   SizedBox.expand(
          //jika loadng map jika tidak ingin pakai loading map silahkan ganti
         // Container(
             child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[  

                Container(
                  height: MediaQuery.of(context).size.height- 100 ,
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
              
                

              // the fab
              Positioned(
                right: 15.0,
                bottom: 150,
                child: Visibility(
                  visible: true,
                //  maintainAnimation: true,
                  child:  Container(
                      width: 48.0,
                      height: 48.0,
                      child: FloatingActionButton( 
                            child: Icon(
                              Icons.gps_fixed,
                              color: Colors.blue, 
                            ),
                          onPressed: (){  
                             Scaffold.of(context).openDrawer(); 
                            //  _getUserLocation();
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
               
            
            
              
              
             
              
            ], 
          ),
       ),
       
       
     ) 
    );
  }
    
 
   Widget _body(){
    return  GoogleMap( 
     // polylines: Set<Polyline>.of(_polylines.values),
     // markers: _markers,
        
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: false,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled:false , 
      zoomGesturesEnabled: true,
      trafficEnabled: true,
      //  showUserLocation: true,
      // mapViewType: MapViewType.normal,
      //trackCameraPosition: true,
      mapType: MapType.normal,
      //markers: Set.of((marker != null) ? [marker] : []),
      //circles: Set.of((circle != null) ? [circle] : []),
      initialCameraPosition:CameraPosition(
        target:    LatLng(-3.47764787218,119.141805461),
        zoom: 16.0, 
        bearing: 20,//berputar
      ),
      //markers: _markers.values.toSet(),
       onCameraMoveStarted: () {
         // print('onCameraMoveStarted');
      },
      onCameraMove: (CameraPosition cameraPosition) { 
       
      },
      onCameraIdle:(){  
         
      },  
      onMapCreated: (GoogleMapController controller)   { 
        
      },
      
    ); 

  } 

}