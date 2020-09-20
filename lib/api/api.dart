import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constans.dart';
class CallApi{
  final String _url = GojekGlobal.DomainUrl; 
  static String token ='';

    Future<http.Response> postData(data, apiUrl) async {
        
        var localStorage = await SharedPreferences.getInstance();
        token  = localStorage.getString('token');
        var fullUrl =apiUrl == 'gcm' ? 'https://fcm.googleapis.com/fcm/send': _url + apiUrl   ; 
        
        return await http.post(
            fullUrl, 
            body: jsonEncode(data), 
            headers: apiUrl == 'gcm' ? _setHeaders_gcm() : _setHeaders()
        );
    }
    Future<http.Response> getData(apiUrl) async {
        var localStorage = await SharedPreferences.getInstance();
       token  = localStorage.getString('token');
       var fullUrl = apiUrl == 'gcm' ? 'https://fcm.googleapis.com/fcm/send':  _url + apiUrl   ; 
        
       return await http.get(
         fullUrl, 
         headers: apiUrl == 'gcm' ? _setHeaders_gcm() : _setHeaders()
       );
    }

    Map<String, String> _setHeaders() => {
        'Content-type' : 'application/json',
        'Accept' : 'application/json',
        'Authorization' : 'Bearer $token',
    };

    Map<String, String> _setHeaders_gcm() => {
        'Content-type' : 'application/json',
        'Accept' : 'application/json',
        'Authorization' : 'key=AAAAqb3QmLo:APA91bGYHDpiqCE__s7kOJud_mScdRynRzZEGj_usgg6N4yZ1nDY3RNwBWVbxzYSzTxhbixR3zT3h84CbVOO1ISV3RUwMAls42K5iDmS9cyFaTrA1QpNgKKuM2SfRSbzG_R-y8iN4ksk',
         
    };
}