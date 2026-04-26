class LoginRequest {
  String username;
  String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "password": password,
    };
  }
}

class LoginResponse {
  int id;
  String username;
  String role;
  String token;
  String fullName;
  int? employeeId;

  LoginResponse({
    required this.id,
    required this.username,
    required this.role,
    required this.token,
    required this.fullName,
    this.employeeId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      id: json['id'],
      username: json['username'],
      role: json['role'],
      token: json['token'],
      fullName: json['fullName'],
      employeeId: json['employeeId'],
    );
  }
}
