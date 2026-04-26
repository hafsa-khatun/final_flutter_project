import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/registration.dart';


class RegistrationService {
  final String baseUrl = "http://10.0.2.2:8080/api/registrations";

  // GET ALL
  Future<List<RegistrationModel>> getRegistrations() async {
    final res = await http.get(Uri.parse(baseUrl));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      List data = jsonDecode(res.body);
      return data.map((e) => RegistrationModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load registrations");
    }
  }

  // CREATE
  Future<RegistrationModel> createRegistration(RegistrationModel reg) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(reg.toJson()),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return RegistrationModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("Failed to create registration");
    }
  }

  // UPDATE
  Future<void> updateRegistration(int id, RegistrationModel reg) async {
    final res = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(reg.toJson()),
    );

    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception("Failed to update");
    }
  }

  // DELETE
  Future<void> deleteRegistration(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));

    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception("Failed to delete");
    }
  }
}
