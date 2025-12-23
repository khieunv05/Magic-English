import 'dart:core';

class User {
  String? name;
  String? email;
  String? dateOfBirth;
  String? phone;
  String? gender;

  User({this.name, this.email,this.dateOfBirth, this.phone, this.gender = 'Nam'});

  factory User.fromJson(Map<String,dynamic> json){
    return User(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],

    );
  }
}