import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/designation.dart';

class DesignationService {
  final String baseUrl = 'http://10.0.2.2:8080/api/designations';


  Future<List<DesignationModel>> getDesignations() async {
    final res = await http.get(Uri.parse(baseUrl));

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => DesignationModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load designations');
    }
  }


  Future<List<DesignationModel>> getByDepartment(int deptId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/by-department/$deptId'),
    );

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => DesignationModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load by department');
    }
  }


  Future<DesignationModel> createDesignation(DesignationModel desg) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(desg.toJson()),
    );

    if (res.statusCode == 200) {
      return DesignationModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to create designation');
    }
  }


  Future<void> updateDesignation(int id, DesignationModel desg) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(desg.toJson()),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update designation');
    }
  }


  Future<void> deleteDesignation(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/$id'),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to delete designation');
    }
  }
}
