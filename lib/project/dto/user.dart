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

  User({this.id,this.name, this.email,this.dateOfBirth, this.phone, this.gender = 'Nam',this.imagePath});

  factory User.fromJson(Map<String,dynamic> json){
    return User(
      id:json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      dateOfBirth: formatDate(json['date_of_birth'])
    );
  }
  static String? formatDate(String? dateString){
    if(dateString == null || dateString.isEmpty){
      return '';
    }
    try{
      DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(parsedDate);

    }
    catch(e){
      return dateString;
    }
  }
}