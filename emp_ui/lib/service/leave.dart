import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/leave.dart';


class LeaveService {
  final String baseUrl = "http://10.0.2.2:8080/api/leaves";

  // GET ALL
  Future<List<LeaveModel>> getLeaves() async {
    final res = await http.get(Uri.parse(baseUrl));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      List data = jsonDecode(res.body);
      return data.map((e) => LeaveModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load leaves");
    }
  }

  // GET BY REGISTRATION
  Future<List<LeaveModel>> getByRegistration(int regId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/registration/$regId"),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      List data = jsonDecode(res.body);
      return data.map((e) => LeaveModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load by registration");
    }
  }

  // CREATE
  Future<LeaveModel> createLeave(LeaveModel leave) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(leave.toJson()),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return LeaveModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("Failed to create leave");
    }
  }

  // UPDATE
  Future<void> updateLeave(int id, LeaveModel leave) async {
    final res = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(leave.toJson()),
    );

    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception("Failed to update leave");
    }
  }

  // DELETE
  Future<void> deleteLeave(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));

    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception("Failed to delete leave");
    }
  }
}
