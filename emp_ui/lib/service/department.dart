import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/department.dart';

class DepartmentService {
  final String baseUrl = 'http://10.0.2.2:8080/api/departments';

  // GET all
  Future<List<DepartmentModel>> getDepartments() async {
    final res = await http.get(Uri.parse(baseUrl));

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => DepartmentModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load departments');
    }
  }

  // POST
  Future<DepartmentModel> createDepartment(DepartmentModel dept) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dept.toJson()),
    );

    if (res.statusCode == 200) {
      return DepartmentModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to create');
    }
  }

  // PUT
  Future<void> updateDepartment(int id, DepartmentModel dept) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dept.toJson()),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update');
    }
  }

  // DELETE
  Future<void> deleteDepartment(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));

    if (res.statusCode != 200) {
      throw Exception('Failed to delete');
    }
  }
}
