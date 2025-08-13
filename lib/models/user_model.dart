class UserModel {
  final String email;
  final String password;
  final String? role;

  UserModel({required this.email, required this.password, this.role});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'role': role,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        email: json['email'],
        password: json['password'],
        role: json['role'],
      );
}
