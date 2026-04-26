import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/salary.dart';

class SalaryService {
  final String baseUrl = "http://10.0.2.2:8080/api/salary";

  // GET ALL
  Future<List<SalaryModel>> getAllSalary() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/all"));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        List data = jsonDecode(res.body);
        return data.map((e) => SalaryModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load salary");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  // CREATE
  Future<SalaryModel> createSalary(SalaryModel salary) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/save"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(salary.toJson()),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return SalaryModel.fromJson(jsonDecode(res.body));
      } else {
        print("SALARY SAVE ERROR: ${res.body}");
        throw Exception("Failed to create salary: ${res.body}");
      }
    } catch (e) {
      print("SALARY NETWORK ERROR: $e");
      throw Exception("Network error: $e");
    }
  }

  // UPDATE
  Future<void> updateSalary(int id, SalaryModel salary) async {
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/update/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(salary.toJson()),
      );

      if (!(res.statusCode >= 200 && res.statusCode < 300)) {
        print("SALARY UPDATE ERROR: ${res.body}");
        throw Exception("Failed to update salary: ${res.body}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  // DELETE
  Future<void> deleteSalary(int id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/delete/$id"));
      if (!(res.statusCode >= 200 && res.statusCode < 300)) {
        throw Exception("Failed to delete salary");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }
}
