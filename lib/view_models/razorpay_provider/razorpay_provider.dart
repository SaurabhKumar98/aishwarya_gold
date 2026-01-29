import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RazorpayProvider  with ChangeNotifier{
  bool _loading =false;
  bool get loading => _loading;

  set loading (bool value ){
    _loading =value;
    notifyListeners();
  }
  static const  String baseUrl ="https://api.razorpay.com/v1/orders";
  static const String keyId ="rzp_live_RbbG6ETAwitsPC";
  static const String keySecret ="VOf8dVR8qUcXl1tUjHuutWLe";
  


 static  Future<String?> createOrder(int amount ) async{
    final String credentials = base64Encode(utf8.encode("$keyId:$keySecret"));
    // amount =amount*100;
    try{
      var url = Uri.parse(baseUrl);
      final response = await http.post(url,headers:{
        "Authorization": "Basic $credentials",
          "Content-Type": "application/json",
      },
       body: json.encode({
        "amount": amount*100,
          "currency": "INR",
          "receipt": "order_rcptid_11",
          "payment_capture": 1,
       })
       
       
       );
       if(response.statusCode==200){
        var data = json.decode(response.body);
        return data ['id'];
       }
       else{
        return null;
      
       }


    }
    catch(e ){
      return null;


    }
    finally{
      // _loading =false;

    }



  }

}