import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_model.dart';

class AuthService {
  final String baseUrl = "http://10.0.2.2:8080/api/auth";
  

  static LoginResponse? loggedUser;

  Future<LoginResponse?> login(LoginRequest request) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      loggedUser = LoginResponse.fromJson(data);
      return loggedUser;
    } else {
      throw Exception("Login Failed");
    }
  }

  static void logout() {
    loggedUser = null;
  }

  static bool isAdmin() => loggedUser?.role == 'ADMIN';
  static bool isHR() => loggedUser?.role == 'HR';
  static bool isEmployee() => loggedUser?.role == 'EMPLOYEE';
}
