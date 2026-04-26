import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/attandance.dart';


class AttendanceService {
  final String baseUrl = "http://10.0.2.2:8080/attendance";

  // GET ALL
  Future<List<AttendanceModel>> getAll() async {
    final res = await http.get(Uri.parse(baseUrl));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      List data = jsonDecode(res.body);
      return data.map((e) => AttendanceModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load attendance");
    }
  }

  // CREATE
  Future<AttendanceModel> create(AttendanceModel a) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(a.toJson()),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return AttendanceModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("Failed to create");
    }
  }

  // UPDATE
  Future<void> update(int id, AttendanceModel a) async {
    final res = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(a.toJson()),
    );

    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception("Failed to update");
    }
  }

  // DELETE
  Future<void> delete(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));

    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception("Failed to delete");
    }
  }
}
