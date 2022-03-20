class UserModel {
  final String id;
  final String password;
  final String uid;

  UserModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        password = map['password'],
        uid = map['uid'];
}
