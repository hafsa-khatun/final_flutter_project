import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/leave_request.dart';


class LeaveRequestService {
  final String baseUrl = "http://10.0.2.2:8080/leave";

  // GET ALL
  Future<List<LeaveRequestModel>> getAll() async {
    final res = await http.get(Uri.parse(baseUrl));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      List data = jsonDecode(res.body);
      return data.map((e) => LeaveRequestModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load");
    }
  }

  // CREATE
  Future<LeaveRequestModel> create(LeaveRequestModel leave) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(leave.toJson()),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return LeaveRequestModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("Failed to create");
    }
  }

  // UPDATE
  Future<void> update(int id, LeaveRequestModel leave) async {
    final res = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(leave.toJson()),
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

  // APPROVE
  Future<void> approve(int id) async {
    final res = await http.put(Uri.parse("$baseUrl/approve/$id"));

    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception("Failed to approve");
    }
  }

  // REJECT
  Future<void> reject(int id) async {
    final res = await http.put(Uri.parse("$baseUrl/reject/$id"));

    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception("Failed to reject");
    }
  }
}
