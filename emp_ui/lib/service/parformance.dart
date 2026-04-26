import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/parformance.dart';


class PerformanceService {
  final String baseUrl = "http://10.0.2.2:8080/performances";

  //  Get All
  Future<List<PerformanceModel>> getAll() async {
    final res = await http.get(Uri.parse(baseUrl));

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => PerformanceModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load");
    }
  }

  //  Create
  Future<void> create(PerformanceModel model) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(model.toJson()),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to create");
    }
  }

  //  Update
  Future<void> update(int id, PerformanceModel model) async {
    final res = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(model.toJson()),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to update");
    }
  }

  //  Delete
  Future<void> delete(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));

    if (res.statusCode != 200) {
      throw Exception("Failed to delete");
    }
  }
}
