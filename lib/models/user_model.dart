import 'dart:convert';
import 'package:http/http.dart' as http;

class UserModel {
  String? uid;
  String? email;
  String? firstName;
  String? role;
  String? companyName;



  UserModel({this.uid, this.email, this.firstName,  this.role, this.companyName});

  // receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      role:map['role'],
      companyName: map['companyName'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': firstName,
      'role':role,
      'companyName':companyName,

    };
  }


  static Future<List<UserModel>> fetchAll() async{
    final response = await http.get(Uri.parse('https://script.google.com/macros/s/AKfycbxSnFxRkT5RnDfqxpouu9miiHwAUBTG2L4TIiYOq_ESOiUuHuIUeImp5-5HaacpLnel/exec'));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => UserModel.fromMap(data)).toList();
    } else{
      throw Exception('failed to load API');
    }
  }
}

