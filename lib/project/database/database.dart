import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:magic_english_project/api_service/apiservice.dart';
import 'package:magic_english_project/app/app.dart';
import 'package:magic_english_project/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:magic_english_project/login.dart';
import 'package:magic_english_project/project/dto/user.dart';
import 'package:magic_english_project/project/dto/writingdto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class Database{
  final String _baseUrl = 'http://localhost:8000';
  Future<String?> addUser(String username,String password)async {
    try {
      final response = await http.post(
          Uri.parse('$_baseUrl/api/register'),
          headers: {
            'Content-Type': 'application/json'
          },
          body: jsonEncode({
            "username": username,
            "password": password
          })

      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 201) {
        print("Đăng ký thành công");
        return null;
      }
      else {
        try {
          final body = json.decode(response.body);
          print("Lỗi đăng ký: ${body['error']}");
          return body['error'] ?? "Đăng ký thất bại";
        }
        catch (err) {
          print('Lỗi máy chủ : ${response.statusCode}');
          return 'Lỗi máy chủ';
        }
      }
    }
    catch(err){
      if(err is SocketException){
        return 'Không có Internet';
      }
      else if(err is TimeoutException){
        return 'Kết nối quá thời gian, vui lòng thử lại';
      }
      else{
        return 'Lỗi không xác định';
      }
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
  Future<List<WritingDto>> getAllParagraph(String userId)async{
    List<WritingDto> listParagraph = [];
      final response = await http.get(
          Uri.parse('$_baseUrl/api/paragraphs/$userId'),
          headers: {
            "Content-Type":"application/json"
          }
      ).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          List<dynamic> listData = body['data'];
          listParagraph = listData.map((item){
            return WritingDto.fromMap(item);
          }).toList();
          return listParagraph;
        }
        return listParagraph;

    
    
  }

  Future<void> addParagraph(String userId,WritingDto writingDto) async{
    try{
      final response = await http.post(
        Uri.parse('$_baseUrl/api/submit-paragraph'),
        headers: {
          "Content-Type":"application/json"
        },
        body: jsonEncode({
          "content":writingDto.content,
          "point":writingDto.point,
          "mistakes":writingDto.mistakes,
          "suggest":writingDto.suggests,
          "userId":userId
      })
      ).timeout(const Duration(seconds: 10));
      if(response.statusCode == 201){
        print("Thêm thành công");
      }
    }
    catch(e){
      print("Thêm thất bại");
    }
  }

  Future<String?> deleteParagraph(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/paragraph/$id'),
        headers: {
          "Content-Type": "application/json"
        },

      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return null;
      }
      else {
        return 'Lỗi server';
      }
    }
    catch (err){
      if(err is SocketException){
        return 'Lỗi mạng';
      }
      if(err is TimeoutException){
        return 'Bị quá thời gian,vui lòng thực hiện lại';
      }
      return 'Lỗi server';
    }
  }
}