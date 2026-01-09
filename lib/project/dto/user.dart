import 'dart:core';

import 'package:intl/intl.dart';

class User {
  int? id;
  String? name;
  String? email;
  String? dateOfBirth;
  String? phone;
  String? gender;
  String? imagePath;

  User({this.id,this.name, this.email,this.dateOfBirth, this.phone, this.gender = 'nam',this.imagePath});

  factory User.fromJson(Map<String,dynamic> json){
    final rawAvatar = json['avatar']?.toString();
    final rawImage = json['image']?.toString();
    return User(
      id:json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      gender: normalizeGender(json['gender']?.toString()),
      dateOfBirth: formatDate(json['date_of_birth']?.toString()),
      imagePath: normalizeAvatarUrl(rawAvatar) ?? normalizeAvatarUrl(rawImage),
    );
  }

  static String? normalizeAvatarUrl(String? raw) {
    if (raw == null) return null;
    final v = raw.trim();
    if (v.isEmpty) return null;

    // If backend returns storage path, keep it as-is.
    // Keep the original scheme (http/https) to avoid surprises.
    var url = v;

    // Bypass ngrok browser warning for image fetches (Image.network can't set headers).
    if (url.contains('ngrok-free.app') && !url.contains('ngrok-skip-browser-warning')) {
      final joiner = url.contains('?') ? '&' : '?';
      url = '$url${joiner}ngrok-skip-browser-warning=true';
    }
    return url;
  }

  static String? normalizeGender(String? raw) {
    if (raw == null) return null;
    final v = raw.trim();
    if (v.isEmpty) return null;

    final lower = v.toLowerCase();
    if (lower == 'nam' || lower == 'male') return 'nam';
    if (lower == 'nữ' || lower == 'nu' || lower == 'female') return 'nữ';

    // Handle common UI values
    if (v == 'Nam') return 'nam';
    if (v == 'Nữ' || v == 'Nu') return 'nữ';

    // If API starts returning already-normalized unexpected values, keep them.
    return lower;
  }

  static String genderLabel(String? raw) {
    final v = normalizeGender(raw);
    if (v == 'nam') return 'Nam';
    if (v == 'nữ') return 'Nữ';
    return raw?.toString() ?? '';
  }
  static String? formatDate(String? dateString){
    if(dateString == null || dateString.isEmpty){
      return '';
    }
    try{
      DateTime parsedDate = DateTime.parse(dateString).toLocal();
      return DateFormat('dd/MM/yyyy').format(parsedDate);

    }
    catch(e){
      return dateString;
    }
  }
}