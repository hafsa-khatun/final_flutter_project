import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/project.dart';


class ProjectService {
  final String baseUrl = "http://10.0.2.2:8080/api/projects";

  // GET ALL
  Future<List<ProjectModel>> getProjects() async {
    final res = await http.get(Uri.parse(baseUrl));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      List data = jsonDecode(res.body);
      return data.map((e) => ProjectModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load projects");
    }
  }

  // CREATE
  Future<ProjectModel> createProject(ProjectModel p) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(p.toJson()),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return ProjectModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("Failed to create project");
    }
  }

  // UPDATE
  Future<void> updateProject(int id, ProjectModel p) async {
    final res = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(p.toJson()),
    );

    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception("Failed to update project");
    }
  }

  // DELETE
  Future<void> deleteProject(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));

    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception("Failed to delete project");
    }
  }
}
