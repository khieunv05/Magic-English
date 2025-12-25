import 'dart:async';
import 'dart:convert';
import 'package:magic_english_project/api_service/apiservice.dart';
import 'package:magic_english_project/project/dto/user.dart';
import 'package:magic_english_project/project/dto/writingdto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class Database{
  final String _baseUrl = 'http://localhost:8000';
  Future<String> addUser(String username,String password,String passwordConfirmation)async {
      final response = await http.post(
          Uri.parse('$_baseUrl/api/register'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode({
            "email": username,
            "password": password,
            "password_confirmation":passwordConfirmation
          })

      );
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body['message'];
      }
      else {
          throw Exception(body['message']);
      }
  }

  Future<User> login(String username,String password)async{
      final response = await http.post(
        Uri.parse('$_baseUrl/api/login'),
        headers: {
          "Content-Type":"application/json"
        },
        body: jsonEncode({
          "email":username,
          "password":password
        })
      ).timeout(const Duration(seconds: 10));
    final body = jsonDecode(response.body);
    if(response.statusCode == 200){
      if(body['result'].isEmpty){
        throw Exception(body['message']);
      }
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('accessToken', body['result']['token']);
      User user = User.fromJson(body['result']);
      return user;
    }
    else{
      throw Exception(body['message']);
    }



  }
  Future<User> getUserData()async{
    Uri uri = Uri.parse('$_baseUrl/api/show');
    final response = await ApiService.get(uri);
    if(response.statusCode == 200){
      final body = jsonDecode(response.body);
      User user = User.fromJson(body['result']);
      return user;
    }
    else{
      throw Exception('Lỗi lấy thông tin');
    }

  }
  Future<List<WritingDto>> getAllParagraph()async{
    Uri uri = Uri.parse('$_baseUrl/api/grammar-checks?page_size=20');
    final response = await ApiService.get(uri);
    if(response.statusCode == 200){
      final body = jsonDecode(response.body);
      List<dynamic> rawData = body['data']??[];
      List<WritingDto> data = rawData.map((item){
        return WritingDto.fromMap(item);
      }).toList();
      return data;
    }
    else{
      throw Exception('Lỗi lấy dữ liệu');
    }



    
    
  }

  Future<WritingDto> addParagraph(String text) async{
      Uri uri = Uri.parse('$_baseUrl/api/grammar-checks');
      final response = await ApiService.post(uri,body: jsonEncode({
        "text":text
      }));
      if(response.statusCode == 200){
        final body = jsonDecode(response.body);
        return WritingDto.fromMap(body['data']);
      }
      else{
        throw Exception('Lỗi khi thêm mới');
      }
  }

  Future<String> deleteParagraph(int? id,int index) async {
    if(id == null){
      throw Exception('Gặp lỗi với id null');
    }
    Uri uri = Uri.parse('$_baseUrl/api/grammar-checks/$id');
    final response =await ApiService.delete(uri);
    if(response.statusCode == 200){
      final body = jsonDecode(response.body);
      return body['message'];
    }
    else{
      throw Exception('Gặp lỗi khi xóa ');
    }
  }

}