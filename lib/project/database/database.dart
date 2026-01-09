import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:magic_english_project/api_service/apiservice.dart';
import 'package:magic_english_project/project/dto/category_english.dart';
import 'package:magic_english_project/project/dto/user.dart';
import 'package:magic_english_project/project/dto/writingdto.dart';
import 'package:magic_english_project/core/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:magic_english_project/project/dto/overview_model.dart'; //
import 'package:magic_english_project/project/dto/tracking_activity.dart';
class Database{
  final String _baseUrl = ApiConfig.baseUrl;
  Future<String> addUser(String username,String password,String passwordConfirmation)async {
      final response = await http.post(
          Uri.parse('$_baseUrl/api/register'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'ngrok-skip-browser-warning': 'true',
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
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
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
  Future<OverviewModel> getOverviewData() async {
    Uri uri = Uri.parse('$_baseUrl/api/tracking/overview');
    final response = await ApiService.get(uri);

    if (response.statusCode == 200) {
      return OverviewModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Không thể tải dữ liệu Overview');
    }
  }
  Future<User> getUserData()async{
    Uri userDataUri = Uri.parse('$_baseUrl/api/show');
    final responseUserData = await ApiService.get(userDataUri);
    if(responseUserData.statusCode == 200){
      final body = jsonDecode(responseUserData.body);
      User user = User.fromJson(body['result']);
      return user;
    }
    else{
      throw Exception('Lỗi lấy thông tin');
    }

  }
  Future<CategoryEnglish> getUserCategoryEnglish() async {
    Uri uri = Uri.parse('$_baseUrl/api/tracking/visualization');
    final response = await ApiService.get(uri);
    if(response.statusCode == 200){
      final body = jsonDecode(response.body);
      CategoryEnglish categoryEnglish = CategoryEnglish.fromJson(body['result']);
      return categoryEnglish;
    }
    else{
      throw Exception('Lỗi lấy thông tin');
    }
  }

  Future<TrackingActivitiesResponse> getTrackingActivities({int page = 1}) async {
    final uri = Uri.parse('$_baseUrl/api/tracking/activities?page=$page');
    final response = await ApiService.get(uri);
    if (response.statusCode == 200) {
      return TrackingActivitiesResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Không thể tải danh sách hoạt động');
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
  Future<User> updateUserData(
    User user, {
    List<int>? avatarBytes,
    String? filename,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/user/update');

    final fields = <String, String>{
      if ((user.name ?? '').trim().isNotEmpty) 'name': user.name!.trim(),
      if ((user.phone ?? '').trim().isNotEmpty) 'phone': user.phone!.trim(),
      if ((user.dateOfBirth ?? '').trim().isNotEmpty) 'birthday': user.dateOfBirth!.trim(),
      if ((user.gender ?? '').trim().isNotEmpty) 'gender': User.normalizeGender(user.gender) ?? 'nam',
    };

    List<int>? bytesToUpload = avatarBytes;
    String? filenameToUpload = filename;

    if (bytesToUpload == null || bytesToUpload.isEmpty) {
      final path = user.imagePath;
      if (path != null && path.trim().isNotEmpty && path.startsWith('assets/')) {
        final data = await rootBundle.load(path);
        bytesToUpload = data.buffer.asUint8List();
        filenameToUpload = path.split('/').isNotEmpty ? path.split('/').last : 'avatar.jpg';
      }
    }

    final response = await ApiService.multipartPost(
      uri,
      fields: fields,
      fileField: bytesToUpload == null ? null : 'avatar',
      fileBytes: bytesToUpload,
      filename: filenameToUpload,
    );

    if (response.statusCode != 200) {
      throw Exception('Cập nhật thất bại');
    }

    final decoded = jsonDecode(response.body);
    final root = decoded is Map ? Map<String, dynamic>.from(decoded) : <String, dynamic>{};
    final result = root['result'];
    final data = root['data'];
    final obj = (result is Map)
        ? Map<String, dynamic>.from(result)
        : (data is Map)
            ? Map<String, dynamic>.from(data)
            : <String, dynamic>{};

    // Some APIs may return nested "data" under result.
    final nestedData = obj['data'];
    final userMap = nestedData is Map ? Map<String, dynamic>.from(nestedData) : obj;

    // Map expected fields back into our User model.
    final avatarUrl = userMap['avatar']?.toString();
    final imageRaw = userMap['image']?.toString();
    final imagePath = User.normalizeAvatarUrl(avatarUrl) ?? User.normalizeAvatarUrl(imageRaw) ?? user.imagePath;

    return User(
      id: user.id,
      name: userMap['name']?.toString() ?? user.name,
      email: userMap['email']?.toString() ?? user.email,
      phone: userMap['phone']?.toString() ?? user.phone,
      gender: User.normalizeGender(userMap['gender']?.toString()) ?? user.gender,
      dateOfBirth: user.dateOfBirth,
      imagePath: imagePath,
    );
  }

}