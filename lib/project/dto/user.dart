import 'dart:core';

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
      gender: json['gender']
    );
  }
}