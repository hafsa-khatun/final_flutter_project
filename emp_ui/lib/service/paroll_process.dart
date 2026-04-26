import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../models/payroll_process.dart';

class PayrollService {
  final String baseUrl = "http://10.0.2.2:8080/api/payroll";

  //  Process payroll
  Future<List<PayrollModel>> processPayroll(String month) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/process-payroll?month=$month"),
      );

      debugPrint("Status Code: ${res.statusCode}");
      debugPrint("Response Body: ${res.body}");

      if (res.statusCode >= 200 && res.statusCode < 300) {
        List data = jsonDecode(res.body);
        return data.map((e) => PayrollModel.fromJson(e)).toList();
      } else {
        throw Exception("Server Error: ${res.statusCode} - ${res.body}");
      }
    } catch (e) {
      debugPrint("Error in processPayroll: $e");
      rethrow;
    }
  }

  //  Get all
  Future<List<PayrollModel>> getAll() async {
    final res = await http.get(Uri.parse(baseUrl));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      List data = jsonDecode(res.body);
      return data.map((e) => PayrollModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load payroll");
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
