import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/applicant.dart';


class ApplicantService {
  final String baseUrl = "http://10.0.2.2:8080/api/applicants";

  //  Get all
  Future<List<ApplicantModel>> getAll() async {
    final res = await http.get(Uri.parse(baseUrl));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      List data = jsonDecode(res.body);
      return data.map((e) => ApplicantModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load applicants");
    }
  }

  //  Create
  Future<ApplicantModel> create(ApplicantModel a) async {
    final res = await http.post(
      Uri.parse("$baseUrl/create-applicant"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(a.toJson()),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return ApplicantModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("Failed to create");
    }
  }

  // Update Status
  Future<void> updateStatus(int id, String status) async {
    final res = await http.put(
      Uri.parse("$baseUrl/$id/status?status=$status"),
    );

    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception("Failed to update status");
    }
  }

  //  Delete
  Future<void> delete(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));

    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception("Delete failed");
    }
  }
}
