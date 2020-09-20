import 'package:flutter/material.dart';
  
 
  
  class Pengaturan extends StatefulWidget {
    @override
    _PengaturanState createState() => _PengaturanState(  ); 
     
  }
  
  class _PengaturanState extends State<Pengaturan>  {
    int _value = 6;
     int _meter = 6*500;
      double _km = (6*500)/1000;
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        //title: 'Slider Tutorial',
        home: Scaffold(
          appBar: AppBar( 
            leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
                Navigator.pop(context,true);
            }),
            title: Text('Pengaturan'), 
          ),
          body: Padding(
            padding: EdgeInsets.all(15.0),
            child: Container(
              child:  Column(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [ 
                  Text("data"),
                  Divider(  color: Colors.grey,  height:5,  ),  
                  Text("data"),
                  Divider(  color: Colors.grey,  height:5,  ),  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(
                        Icons.ac_unit,
                        size: 24,
                      ),
                      new Expanded(
                        child: Slider(
                            value: _value.toDouble(),
                            min: 0.5,
                            max: 200.0,
                            divisions: 100,
                            activeColor: Colors.red,
                            inactiveColor: Colors.black,
                            label: 'Radius jemput $_km km',
                            onChanged: (double newValue) {
                              setState(() {
                                _value = newValue.round();
                                _meter= _value*500;
                                _km= _meter/1000;
                              });
                              
                            },
                            semanticFormatterCallback: (double newValue) {
                              return '${newValue.round()} dollars';
                            }
                        )
                      ),
                    
                    ]
                  ),
                  Divider(  color: Colors.grey,  height:5,  ),  
                  Text("data"),
                  Divider(  color: Colors.grey,  height:5,  ),   
                  Text("data"),
                ]
              )
            ),
          )
        ),
      );
    }
  }