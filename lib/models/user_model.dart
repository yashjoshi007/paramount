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
}

