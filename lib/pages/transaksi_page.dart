
import 'package:flutter/material.dart';

 

class Transaksi extends StatefulWidget {
   final Map<String, dynamic> data_p; 
  Transaksi({Key key, this.data_p}) : super(key: key);
  @override
  _TransaksiState createState() => _TransaksiState();
}
  
class _TransaksiState extends State<Transaksi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        title: Text('Transaksi'), 
         leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
                Navigator.pop(context,true);
            }),
      ),
      body:Container(

      ),
    );   
  }
}