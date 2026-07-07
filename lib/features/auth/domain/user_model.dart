class UserModel {
  final String uid;
  final String email;
  final String? role;
  final String? name;

  UserModel({
    required this.uid,
    required this.email,
    this.role,
    this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'],
      name: map['name'],
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? role,
    String? name,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      name: name ?? this.name,
    );
  }
}
