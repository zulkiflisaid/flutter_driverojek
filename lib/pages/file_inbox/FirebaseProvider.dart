import 'package:cloud_firestore/cloud_firestore.dart';
//flutter_inbox/inbox_customer
class FirebaseProvider {
  Future<List<DocumentSnapshot>> fetchFirstList() async {
    return (await Firestore.instance
            .collection('flutter_inbox')
            .document('inbox_driver')
            .collection('inbox')  
            .orderBy('time')
            .limit(10)
            .getDocuments())
        .documents;
  }

  Future<List<DocumentSnapshot>> fetchNextList(
      List<DocumentSnapshot> documentList) async {
    return (await Firestore.instance
            .collection('flutter_inbox')
            .document('inbox_driver')
            .collection('inbox')
            .orderBy('time')
            .startAfterDocument(documentList[documentList.length - 1])
            .limit(10)
            .getDocuments())
        .documents;
  }
}