import 'dart:io';
import 'dart:ui'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; 
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';
import 'package:path/path.dart' as Path;  
import 'package:intl/intl.dart';
 
  
 
class UploadBukti extends StatefulWidget {
  
  UploadBukti({
    Key key,
    this.data_p,
    this.jumlah,
    this.kd_transfer,
    this.bank,
    this.pemilik,
    this.no_rek,
    this.logo,
    this.tgl, 
    this.verifikasi,
    this.uid
  }) : super(key: key);

  final Map<String, dynamic> data_p; 
  final int jumlah; 
  final String kd_transfer; 
  final String bank; 
  final String pemilik; 
  final String no_rek; 
  final String logo; 
  final String tgl;  
  final bool verifikasi;  
  final String uid;  
  @override
  _UploadBuktiState createState() => _UploadBuktiState();
   
}


class _UploadBuktiState extends State<UploadBukti> {
   
  final _scaffoldKey = GlobalKey<ScaffoldState>(); 
  var uang =   NumberFormat.currency(locale: 'ID', symbol: '',decimalDigits:0);  
  final dbRef = Firestore.instance;
  
   File _image;    
   String _uploadedFileURL;    



  @override
  void dispose() { 
    super.dispose();
  } 

  @override
  void initState(){ 
    super.initState();   
  }
 
    Future<File> _getLocalFile( ) async { 
    return _image;
  }
  
  @override
  Widget build(BuildContext context){ 
   
    return  Scaffold(
       key: _scaffoldKey,    
      appBar: AppBar(  
        backgroundColor: Colors.white, 
        brightness : Brightness.light,
        title: Text('Upload bukti Top Up',style: TextStyle(color: Colors.black ),), 
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () { 
            Navigator.pop(context);
          },
        ),   
      ), 
      body: Container( 
        child:    Card(  margin:  const EdgeInsets.all(  10.0, ),
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
                                          Text(widget.tgl  ,style: TextStyle(fontSize: 14, color: Colors.grey),),    
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
                                                  color: widget.verifikasi==true ? Colors.green : Colors.blue ,
                                                  width: 1,
                                                ), 
                                                borderRadius: BorderRadius.circular(6.0),
                                            ), 
                                           child: Text( widget.verifikasi == true ? 'Terverifikasi' : 'Belum Verifikasi',style: TextStyle( color: Colors.black),),
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
                                                   'assets/images/bank/${widget.logo}',
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
                                                Text('${widget.bank}',style: TextStyle(fontSize: 20,),),
                                                Text('${widget.pemilik}',style: TextStyle( color: Colors.grey),), 
                                                 Text('${widget.no_rek} ',style: TextStyle(fontSize: 17,color: Colors.black),), 
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
                                        Text('${widget.kd_transfer} ',style: TextStyle(fontSize: 18,color: Colors.blue),), 
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[ 
                                        Text('Nominal',style: TextStyle( color: Colors.grey),),
                                         Text('Rp ${uang.format(widget.jumlah)}',style: TextStyle(fontSize: 18),),  
                                      ],
                                    ),  
                                  ],
                                ),
                                Divider(  color: Colors.grey,  height:10, ),
                                //bukti transaksi
                               
                                 FutureBuilder(
                                  future: _getLocalFile( ),
                                  builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                                    return snapshot.data != null ?   Expanded(  child: Image.file(snapshot.data)  )   :   Container();
                                  }),
                    
                               // _image.existsSync()? FileImage(_image)    : null ,
                                ////select image/////////////////// 
                                FlatButton(color: Colors.green[400],
                                    child: Text('UPLOAD BUKTI TRANSFER',style: TextStyle(fontSize: 14, color: Colors.white),),
                                    onPressed: () {   
                                        chooseFile();
                                    }
                                ),
                                

                              ],
                            )
                          )
                        )  
                  
      ),  
        
    );
  }
   
   
 
   

  //pilih file gambar
  Future chooseFile() async {    
    
   await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {     
     showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(backgroundColor: Colors.transparent,
                      child:   Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                );
     setState(() {    
       _image = image;  
       uploadFile();
     }); 
   }); 

  } 

  //upload bukti trnsaksi
  Future uploadFile() async {    
    

    var storageRef = FirebaseStorage.instance    
        .ref()    
        .child('bukti_topup/${widget.kd_transfer}');    
    var uploadTask = storageRef.putFile(_image);  

    await uploadTask.onComplete; 
       print('File Uploaded');    

    await storageRef.getDownloadURL().then((fileURL) {    
      setState(() {    
        _uploadedFileURL = fileURL;  
         createRecord (fileURL)  ;
      });    
    });  
      
  }  

   void createRecord(String fileURL) async {
     await dbRef
            .collection('flutter_topup')
            .document(widget.uid)
            .updateData({
              'bukti':fileURL, 
              'is_bukti':true
            }).then((result){
                
                 //Future.delayed(  Duration(seconds: 3), () {
                      Navigator.pop(context); //pop dialog
                      
                  //  });
               final snackBar1 = SnackBar(
                content: Text('Sukses upload bukti transfer'),
                action: SnackBarAction(
                  label: 'Close',
                  onPressed: () {
                    //Some code to undo the change!
                  },
                ),
              ); 
              _scaffoldKey.currentState.showSnackBar(snackBar1);  
            }).catchError((onError){  
               _errorUpload();  
            });
   /* await dbRef
        .collection("flutter_topup") 
        .document("kode_order")
        .collection("chat")
        .document(DateTime.now().millisecondsSinceEpoch.toString())
        .setData({
          'bukti': fileURL, 
        });

       var ref = await dbRef.collection("chat_ojek")
        .add({
          'title': 'Flutter in Action',
          'description': 'Complete Programming Guide to learn Flutter'
        }); 
    //print(ref.documentID);*/
  }  

  void _errorUpload() async {
          final snackBar1 = SnackBar(
                content: Text('Gagal upload bukti. Silahkan ulangi'),
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


