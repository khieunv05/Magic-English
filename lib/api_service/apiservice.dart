import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:magic_english_project/app/app.dart';
import 'package:magic_english_project/project/login/signin.dart';
import 'package:magic_english_project/services/shared_preferences_service.dart';
class ApiService {
  static Future<Map<String,String>> _getHeader() async{
    final prefs = SharedPreferencesService.instance;
    final token = prefs.getAccessToken();
    Map<String,String> header = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      "ngrok-skip-browser-warning": "true"
    };
    if(token.isNotEmpty){
      header['Authorization'] = 'Bearer $token';
    }
    return header;
  }
  static Future<http.Response> _handleResponse(http.Response response)async{
    if(response.statusCode == 401){
      final prefs = SharedPreferencesService.instance;
      await prefs.clear();
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context){
          return const SignIn();
        }),
          (route)=>false
      );
      throw Exception('Phiên đăng nhập hết hạn');
    }
    return response;
  }
  static Future<http.Response> get(Uri uri,)async{
    final header = await _getHeader();
    final response = await http.get(uri,headers: header);
    return _handleResponse(response);
  }
  static Future<http.Response> post(Uri uri,{Object? body})async{
    Map<String,String>? header = await _getHeader();
    final response = await http.post(uri,headers: header,body: body);
    return _handleResponse(response);
  }
  static Future<http.Response> put(Uri uri,{Object? body}) async{
    Map<String,String>? header = await _getHeader();
    final response = await http.put(uri,body: body,headers: header);
    return _handleResponse(response);
  }
  static Future<http.Response> delete(Uri uri) async{
    Map<String,String>? header = await _getHeader();
    final response = await http.delete(uri,headers: header);
    return _handleResponse(response);
  }
}