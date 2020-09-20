import 'dart:ui'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; 
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
 
  
 
class TopUpHistory extends StatefulWidget {
  
  TopUpHistory({Key key, this.data_p}) : super(key: key);
  final Map<String, dynamic> data_p; 
  @override
  _TopUpHistoryState createState() => _TopUpHistoryState();
   
}


class _TopUpHistoryState extends State<TopUpHistory> {
 
  var uang =   NumberFormat.currency(locale: 'ID', symbol: '',decimalDigits:0);  
  final dbRef = Firestore.instance;
 
 
 

  @override
  void dispose() { 
    super.dispose();
  } 

  @override
  void initState(){ 
    super.initState(); 
   
  }
 

  @override
  Widget build(BuildContext context){ 
    return MaterialApp(
        //theme: ThemeData(
          //primarySwatch: Colors.green,
       // ),
      home: DefaultTabController(length: 2, 
        child: Scaffold(  
          appBar: AppBar(  
           // backgroundColor: Colors.white, 
           // brightness : Brightness.light,
          //  title: Text('Transaksi Top Up',style: TextStyle(color: Colors.black ),), 
              title: Text('Transaksi Top Up',), 
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () { 
                Navigator.pop(context);
              },
            ),  
            bottom: TabBar(
              // labelStyle:  TextStyle( color: Colors.black),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white,
                indicatorColor: Colors. orange,
                labelStyle: TextStyle(color: Colors.black, ),  //For Selected tab
                unselectedLabelStyle: TextStyle(color: Colors.black, ), //F
              tabs: <Widget>[
                Tab( text: 'Dalam Proses',),
                Tab( text: 'Berhasil Top Up',)
              ]
              ),   
          ), 
          body:   TabBarView(
            children: <Widget>[ 
                 _listDalamProses(false ),
                _listDalamProses(true ), 
            ]
          ),   
        )
      )
    ); 
  }
 
  Widget _listDalamProses( bool verifikasi ){ 
    return  Container( 
        child: StreamBuilder<QuerySnapshot>(
          stream: dbRef.collection('flutter_topup')   
           .where('user_id', isEqualTo:widget.data_p['uid'])
           .where('verifikasi', isEqualTo:verifikasi )  
            .where('is_bukti',   isEqualTo: true   )   
           .limit(20)
           .snapshots() , 
          builder: (BuildContext context,  AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return   Text('Internet error');
            } else if (snapshot.data != null) { 
          
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:  return   Text('Loading...'); 
                default:
                  
                  if(snapshot.data.documents.isEmpty){
                        return Center(
                          child:Container(
                            margin:   const EdgeInsets.all( 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                  ClipRRect(
                                    borderRadius:  BorderRadius.circular(8.0),
                                    child:  Image.asset(
                                      'assets/images/topup/topup.png',
                                      // height: 172.0,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                // Image.asset( 'assets/images/promo_3.jpg',   ), 
                                Text( 'Data Top Up akan tampil di sini.'),
                                Text( 'Silahkan tekan tombol kanan bawah untuk Top up.'),
                              ],
                            )
                          ) 
                        );  
                  }else{
                    return ListView(
                      children: snapshot.data.documents.map((DocumentSnapshot document) {
                       //Timestamp t =document['tgl'];
                        var tgl_topup =  '';
                        var d =document['tgl'] ==null ? null : document['tgl'].toDate();  
                        if(d!=null){
                             tgl_topup =  DateFormat('yyyy-MM-dd kk:mm').format(d);
                        } 
                       

                      // var date = new DateTime.fromMillisecondsSinceEpoch(document['tgl'] * (1000));
                     // var tgl_topup =  DateFormat('yyyy-MM-dd kk:mm').format(date);
                       //print(formatDate);  
                        return Card(  margin:  const EdgeInsets.all(  10.0, ),
                          child: Container(
                            padding: const EdgeInsets.all(  15.0), 
                            child: Column( 
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[ 
                                 //////////tanggal//////////////
                                Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[ 
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[ 
                                          Text('Tanggal',style: TextStyle( color: Colors.grey),),
                                         //Text(DateFormat('y:M:d H:m:s') .format(  document['tgl'].toDate() )  .toString(),style: TextStyle(fontSize: 14),),
                                          Text(tgl_topup  ,style: TextStyle(fontSize: 14, color: Colors.grey),),    
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[ 
                                         Container(
                                           padding:   EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
                                            decoration: BoxDecoration(
                                                color:  Colors.white ,
                                                border: Border.all(
                                                  color: document['verifikasi']==true ? Colors.green : Colors.blue ,
                                                  width: 1,
                                                ), 
                                                borderRadius: BorderRadius.circular(6.0),
                                            ), 
                                           child: Text(document['verifikasi']==true ? 'Terverifikasi' : 'Belum Verifikasi',style: TextStyle( color: Colors.black),),
                                         )
                                      ],
                                    ),  
                                  ],
                                ),
                                Divider(  color: Colors.grey,  height:16, ),
                                /////////bank///////////////
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[ 
                                    Expanded(
                                         child: Padding(
                                           padding: const EdgeInsets.all(  0.0, ),
                                           child: Container(
                                              // padding: const EdgeInsets.all(  10.0, ),
                                              margin: const EdgeInsets.all(  6.0, ),
                                              child: Image.asset(
                                                   'assets/images/bank/${document['logo']}',
                                                   height: 50.0, 
                                                  // width: 50.0,
                                                  //width: double.infinity,
                                                  //fit: BoxFit.cover,
                                                ),  
                                            )  
                                         )
                                    ),
                                    Expanded(
                                         child: Padding(
                                           padding:const EdgeInsets.all(  3.0, ),
                                           child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[ 
                                                Text('${document['bank']}',style: TextStyle(fontSize: 20,),),
                                                Text('${document['pemilik']}',style: TextStyle( color: Colors.grey),), 
                                                 Text('${document['no_rek']} ',style: TextStyle(fontSize: 17,color: Colors.black),),  
                                              ],
                                            ),   
                                         )
                                    ),
                                    
                                  ],
                                ),
                                Divider(  color: Colors.grey,  height:16, ),
                                ///////// kode transfer dan nominal///////////////
                                Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[ 
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[ 
                                        Text('Kode Top Up',style: TextStyle( color: Colors.grey),), 
                                        Text('${document['kd_transfer']} ',style: TextStyle(fontSize: 18,color: Colors.blue),),  
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[ 
                                        Text('Nominal',style: TextStyle( color: Colors.grey),),
                                        Text('Rp ${uang.format(document['jumlah'])}',style: TextStyle(fontSize: 18),),  
                                      ],
                                    ),  
                                  ],
                                ),
                                 Divider(  color: Colors.grey,  height:10, ),
                                //bukti transaksi 
                                Image.network(
                                  '${document['bukti']}',
                                ),

                                  

                              ],
                            )
                          )
                        ); 
                    }).toList(),
                  );
                } 
              } 
            } else {
                return Center(
                  child: CircularProgressIndicator() 
                );  
            }
            
          },
        )
      );

  } 
   
} 
 