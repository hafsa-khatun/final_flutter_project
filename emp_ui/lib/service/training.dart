import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/training.dart';


class TrainingService {
  final String baseUrl = "http://10.0.2.2:8080/api/trainings";

  // GET all
  Future<List<TrainingModel>> getAll() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        List data = jsonDecode(res.body);
        return data.map((e) => TrainingModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // CREATE
  Future<void> create(TrainingModel training) async {

    final res = await http.post(
      Uri.parse("$baseUrl/create-training"), 
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(training.toJson()),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      print("Create Error Response: ${res.body}");
      throw Exception("Failed to create: ${res.statusCode}");
    }
  }

  // UPDATE
  Future<void> update(int id, TrainingModel training) async {
    final res = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(training.toJson()),
    );

    if (res.statusCode != 200) {
      print("Update Error Response: ${res.body}");
      throw Exception("Failed to update");
    }
  }

  // DELETE
  Future<void> delete(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception("Failed to delete");
    }
  }
}
