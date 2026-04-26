import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee.dart';

class EmployeeService {
  final String baseUrl = 'http://10.0.2.2:8080/api/employees';

  Future<List<EmployeeModel>> getEmployees() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => EmployeeModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load employees');
    }
  }

  Future<EmployeeModel> createEmployee(EmployeeModel emp) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(emp.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return EmployeeModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to create employee');
    }
  }

  Future<EmployeeModel> updateEmployee(int id, EmployeeModel emp) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(emp.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return EmployeeModel.fromJson(jsonDecode(res.body));
    } else {
      print('Update Error: ${res.body}');
      throw Exception('Failed to update employee: ${res.statusCode}');
    }
  }

  Future<void> deleteEmployee(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));
    
    if (res.statusCode == 400 || res.statusCode == 500) {
      // This is usually a Foreign Key constraint error
      throw Exception('Cannot delete: Employee has linked records (Salary, Attendance, or Leaves). Delete those first.');
    } else if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Delete failed with status: ${res.statusCode}');
    }
  }
}
