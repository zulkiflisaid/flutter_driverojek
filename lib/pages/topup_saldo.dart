import 'dart:io';
import 'dart:ui'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; 
import 'package:flutter/services.dart';
import 'package:driverojek/pages/file_topup/upload_bukti.dart'; 
import 'dart:math'; 
import 'package:intl/intl.dart';

 
import 'package:driverojek/pages/file_topup/topup_history.dart'; 
  
 
class TopUpSaldo extends StatefulWidget {
  
  TopUpSaldo({Key key, this.data_p}) : super(key: key);
  final Map<String, dynamic> data_p; 
  @override
  _TopUpSaldoState createState() => _TopUpSaldoState();
   
}


class _TopUpSaldoState extends State<TopUpSaldo> {
   
  final _scaffoldKey = GlobalKey<ScaffoldState>(); 
  var uang =   NumberFormat.currency(locale: 'ID', symbol: '',decimalDigits:0);  
  final dbRef = Firestore.instance;
  final List _cities = ['BANK NEGARA INDONESIA', 'BANK RAKYAT INDONESIA'];
  TextEditingController jumlahInputController  =   TextEditingController();
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentCity;
 //SimpleDateFormat sfd =   SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
  // sfd.format(new Date(timestamp));
   File _image;    
   String _uploadedFileURL;    



  @override
  void dispose() { 
    super.dispose();
  } 

  @override
  void initState(){ 
    super.initState(); 
    _dropDownMenuItems = getDropDownMenuItems();
    _currentCity = _dropDownMenuItems[0].value;    
  }
 
  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    var items =  <DropdownMenuItem<String>>[];
    for (String city in _cities) {
      items.add(DropdownMenuItem(
          value: city,
          child:  Text(city)
      ));
    }
    return items;
  }
  
  @override
  Widget build(BuildContext context){ 
   
    return  Scaffold(
       key: _scaffoldKey,    
      appBar: AppBar(  
        //backgroundColor: Colors.white, 
        //brightness : Brightness.light,
        title: Text('Top Up' ), 
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () { 
            Navigator.pop(context);
          },
        ), 
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
               Navigator.push(  context, MaterialPageRoute(
                  builder: (context) => 
                    TopUpHistory(
                      data_p: widget.data_p,  
                    )
                  ),  
                );
            },
          ), 
        ],   
      ), 
      body:   Container(
        // color: Colors.white,
       // padding: const EdgeInsets.all(6.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: dbRef.collection('flutter_topup')   
           .where('user_id', isEqualTo:widget.data_p['uid'])
           .where('verifikasi', isEqualTo:false )  
           // .where('bukti', isEqualTo:'' )    
            .where('is_bukti', isEqualTo:false )  
           .limit(20)
           .snapshots() ,
           
          builder: (BuildContext context,  AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return   Text('Error: ${snapshot.error}');
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
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[ 
                                                    Text('${document['no_rek']} ',style: TextStyle(fontSize: 17,color: Colors.black),), 
                                                    InkWell(
                                                      child:  Icon(Icons.content_copy ,size: 16, color: Colors.green,),
                                                       onTap:  () {
                                                        Clipboard.setData( ClipboardData(text: document['no_rek']));
                                                        _scaffoldKey.currentState.showSnackBar(
                                                        SnackBar(content:  Text('Nomor rekening telah dicopy'),));
                                                      },
                                                      onLongPress: () {
                                                        Clipboard.setData( ClipboardData(text: document['no_rek']));
                                                        _scaffoldKey.currentState.showSnackBar(
                                                        SnackBar(content:  Text('Nomor rekening telah dicopy'),));
                                                      },
                                                    ) 
                                                  ]
                                                ), 
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
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[ 
                                            Text('${document['kd_transfer']} ',style: TextStyle(fontSize: 18,color: Colors.blue),), 
                                            InkWell(
                                              child:  Icon(Icons.content_copy ,size: 16, color: Colors.green,),
                                              onTap:  () {
                                                Clipboard.setData( ClipboardData(text: document['kd_transfer']));
                                                _scaffoldKey.currentState.showSnackBar(
                                                SnackBar(content:  Text('Kode Top Up telah dicopy'),));
                                              }, 
                                              onLongPress: () {
                                                Clipboard.setData( ClipboardData(text: document['kd_transfer']));
                                                _scaffoldKey.currentState.showSnackBar(
                                                SnackBar(content:  Text('Kode Top Up telah dicopy'),));
                                              },
                                            ) 
                                          ]
                                        ) 
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
                                //Image.file(_image)  ,


                                ////select image/////////////////// 
                                FlatButton(color: Colors.green[400],
                                    child: Text('KONFIRMASI TUP UP',style: TextStyle(fontSize: 14, color: Colors.white),),
                                    onPressed: () {   
                                        Navigator.push(  context, MaterialPageRoute(
                                          builder: (context) => 
                                           UploadBukti(
                                              data_p: widget.data_p, 
                                              jumlah: document['jumlah'],
                                              kd_transfer: document['kd_transfer'],
                                              bank: document['bank'],
                                              pemilik: document['pemilik'],
                                              no_rek: document['no_rek'],
                                              logo: document['logo'],
                                              tgl: tgl_topup, 
                                              verifikasi: document['verifikasi'], 
                                              uid: document.documentID, 
                                            )
                                          ),  
                                        );
                                    }
                                ),
                                Divider(  color: Colors.grey,  height:10, ),
                                Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[ 
                                    Text('INFO:',style: TextStyle(fontSize: 12,color: Colors.red),),
                                    Expanded(
                                      child:  Text('Masukkan Kode Top Up pada berita, untuk lebih mempermudah proses Top Up '
                                      ,style: TextStyle( fontSize: 12,color: Colors.black),
                                     )
                                    ) ,
                                  ],
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
      ),  
      floatingActionButton:  Container(
            width: 48.0,
            height: 48.0,
            child:   RawMaterialButton(
              shape:   CircleBorder(),
              elevation: 0.0,
              child: Icon(
                Icons.add_circle, size: 48,
                color: Colors.blue,
              ),
            onPressed: (){
               jumlahInputController.clear(); 
               _showDialog();   

               /*var microsecond =  DateTime.now().microsecondsSinceEpoch.toInt(); 
               var millis =  DateTime.now().millisecondsSinceEpoch.toInt();  
                var minute =  DateTime.now().minute.toInt();  
              ///flutter_topup/qWA1RQ3nL0YwE41t49YtkT1UWTG3/topup
               var _randomId = Firestore.instance
               .collection('flutter_topup')
               .document(widget.data_p['uid']) 
               .collection('topup')
               .document() 
               .documentID;
              print(_randomId);  print(microsecond);print(millis);print(minute);*/

            },
        )
      ),   
    );
  }
   
 
  Widget _listData(ScrollController sc){


  } 

  void _tambahData(int jml, String nm_bank){
    //kd_transfer 8 digit
    var rnd =   Random(); 
    var min = 10000000, max = 99999999;  
    var kd_transfer = min + rnd.nextInt(max - min);
      
      //cek apakah kode belum terpakai
      dbRef.collection('flutter_topup')
      .where('kd_transfer',isEqualTo: '$kd_transfer')
      .getDocuments().then((event) {
          if (event.documents.isEmpty) {
            //var documentData = event.documents.single.data;//if it is a single document
           var logo='';
           if( nm_bank=='BANK NEGARA INDONESIA'){
                 logo='bni.png';
           }else if( nm_bank=='BANK RAKYAT INDONESIA'){
              logo='bri.png';
           }
           //ambil data bank
            dbRef.collection('flutter_bank')
                .where('nm_panjang',isEqualTo: 'BANK NEGARA INDONESIA')
                .getDocuments().then((event1) {
                    if (event1.documents.isNotEmpty) {
                      var documentData = event1.documents.single.data; 
                     // print(documentData);
                      //{nm_panjang: BANK NEGARA INDONESIA, nm_pendek: Bank BNI, cabang: POLEWALI, no_rek: 0696899785, pemilik: ZULKIFLI SAID}
                       dbRef.collection('flutter_topup')
                        .add({ 
                              'kd_transfer':'$kd_transfer', 
                              'jumlah':jml+0, 
                              'user_id':widget.data_p['uid'],  
                              'tgl':FieldValue.serverTimestamp(), 
                              'verifikasi':false, 
                              'bank':'${documentData['nm_pendek']}',  
                              'no_rek':'${documentData['no_rek']}',  
                              'pemilik':'${documentData['pemilik']}',
                              'logo':'$logo', 
                              'bukti':'', 
                              'is_bukti':false, 
                        })  
                        .then((result)   {
                             // _errorUlangi();
                        }).catchError((err) { 
                            _errorUlangi();
                        });
                    } 
                }).catchError((e) {
                    _errorUlangi();
                });  
            
          }else{
             _errorUlangi();
          }
      }).catchError((e) {
          _errorUlangi();
      }); 
  }

  void _showDialog() async {
    await showDialog<String>(
      context: context,
      child:   _SystemPadding(child:   AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content:    Row(
          children: <Widget>[
             Expanded(
              child:   Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[  
                    Text('Silahkan pilih BANK: '),
                    Container(
                      padding:   EdgeInsets.all(16.0),
                    ),
                    /* DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        alignedDropdown: true,
                          child: DropdownButton(isExpanded: true,
                           value: _currentCity,
                            items: _dropDownMenuItems,
                            onChanged: changedDropDownItem,
                            style: Theme.of(context).textTheme.title,
                        ),
                      ),
                    ),*/
                    DropdownButton( isExpanded: true,
                      value: _currentCity,
                      items: _dropDownMenuItems,
                      onChanged: changedDropDownItem,
                    ),
                    Expanded(
                        child:   TextField(

                          controller: jumlahInputController,
                          autofocus: true,maxLength: 7,
                          // keyboardType: TextInputType.numberWithOptions( ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            WhitelistingTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(7), 
                          ],
                           onChanged: (String newVal) {
                               var jml = int.parse(newVal);  
                                if(jml >1000000){  
                                    jumlahInputController.text = '1000000';
                                   // jumlahInputController.clear();
                                } 

                            },
                           
                          decoration:   InputDecoration(
                              counterText: '',
                              labelText: 'Jumlah Top Up', hintText: 'maksimal 1 juta'),
                        ),
                     ),
                      Divider(  color: Colors.grey,  height:1, ),
                      Text('NB: Maksimal 1 juta dan minimal 20.000 Rupiah'),
                  ],
                )  
            ), 
          ],
        ),
        /* Row(
          children: <Widget>[
              Expanded(
              child:   TextField(
                autofocus: true,
                decoration:   InputDecoration(
                    labelText: 'Full Name', hintText: 'eg. John Smith'),
              ),
            )
          ],
        ),*/
        actions: <Widget>[
            FlatButton(
              child: const Text('Batal'),
              onPressed: () { 
                Navigator.pop(context);
              }),
            FlatButton(
              child: const Text('Simpan'),
              onPressed: () {
                if(jumlahInputController.text=='' || jumlahInputController.text=='0'){
                    
                  
                }else  { 
                   var jml = int.parse(jumlahInputController.text);  
                   if(jml>=20000 && jml<=1000000){
                   _tambahData(jml,_currentCity);
                    Navigator.pop(context);
                }else{
                 
                    Navigator.pop(context);
                    final snackBar1 = SnackBar(
                                  content: Text('Gagal menyimpan Top Up. Maksimal 1 juta dan minimal 20.000 Rupiah'),
                                  action: SnackBarAction(
                                    label: 'Close',
                                    onPressed: () {
                                      //Some code to undo the change!
                                    },
                                  ),
                                ); 
                    _scaffoldKey.currentState.showSnackBar(snackBar1); 
                  } 
                } 
                
              })
        ],
      ),),
    );
  } 

  void changedDropDownItem(String selectedCity) {
    setState(() {
      _currentCity = selectedCity;
    });
  }
   
  void _errorUlangi() async {
       final snackBar1 = SnackBar(
                content: Text('Gagal menyimpan Top Up. Silahkan ulangi'),
                action: SnackBarAction(
                  label: 'Close',
                  onPressed: () {
                    //Some code to undo the change!
                  },
                ),
              ); 
              _scaffoldKey.currentState.showSnackBar(snackBar1); 
  }   
 
   
} 

class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    print(mediaQuery.size.height);
    return   AnimatedContainer(
       // padding: mediaQuery.viewInsets,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}


