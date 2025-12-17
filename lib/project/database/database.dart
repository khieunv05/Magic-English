import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:magic_english_project/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:magic_english_project/project/dto/writingdto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class Database{
  final String _baseUrl = 'https://magic-english-api-production.up.railway.app';
  static Future<void> addToParagraph(WritingDto writingDto)async{
    final user = FirebaseAuth.instance.currentUser;
    if(user == null) return;
    CollectionReference path = FirebaseFirestore.instance.collection('users')
        .doc(user.uid).collection('writing_history');
    await path.add(writingDto.toMap());
  }
  // static Future<void> deleteParagraph(String paragraphId) async{
  //   final user = FirebaseAuth.instance.currentUser;
  //   if(user == null) return;
  //   CollectionReference path = FirebaseFirestore.instance.collection('users')
  //     .doc(user.uid).collection('writing_history');
  //   path.doc(paragraphId).delete();
  //
  // }
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

  Future<Map<String,String?>> login(String username,String password)async{
    Map<String, String?> result = {};
    try{
      final response = await http.post(
        Uri.parse('$_baseUrl/api/login'),
        headers: {
          "Content-Type":"application/json"
        },
        body: jsonEncode({
          "username":username,
          "password":password
        })
      ).timeout(const Duration(seconds: 10));
      try {

        final body = jsonDecode(response.body);
        if (response.statusCode == 200) {
          result['id'] = body['data']["_id"];
          result['message'] = body['message'];
          return result;
        }
        else {
          result['id'] = null;
          result['message'] = body['error'];
          return result;
        }
      }
      catch(error){
        result['id'] = null;
        result['message'] = "Lỗi máy chủ";
        return result;
      }

    }
    catch(err){
      if(err is SocketException){
        result['id'] = null;
        result['message'] = "Không có kết nối mạng";
        return result;
      }
      else if(err is TimeoutException){
        result['id'] = null;
        result['message'] = "Kết nối bị quá thời gian,vui lòng thử lại";
        return result;
      }
      else{
        result['id'] = null;
        result['message'] = "Lỗi không xác định";
        return result;
      }
    }
  }

  Future<List<WritingDto>> getAllParagraph(String userId)async{
    List<WritingDto> listParagraph = [];
    try {
      final response = await http.get(
          Uri.parse('$_baseUrl/api/paragraphs/$userId'),
          headers: {
            "Content-Type":"application/json"
          }
      ).timeout(const Duration(seconds: 10));
      try {
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
      catch(err){
        return listParagraph;
      }

    }
    catch(err){
      return listParagraph;
    }
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