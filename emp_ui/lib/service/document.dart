import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/document.dart';


class DocumentService {
  final String baseUrl = "http://10.0.2.2:8080/documents";


  Future<List<DocumentModel>> getAll() async {
    final res = await http.get(Uri.parse(baseUrl));

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => DocumentModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load documents");
    }
  }


  Future<List<DocumentModel>> getByEmployee(int employeeId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/employee/$employeeId"),
    );

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => DocumentModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load documents");
    }
  }


  Future<void> uploadFile({
    required int employeeId,
    required File file,
    required String documentType,
  }) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/upload/$employeeId"),
    );

    request.fields["documentType"] = documentType;

    request.files.add(
      await http.MultipartFile.fromPath("file", file.path),
    );

    var response = await request.send();

    if (response.statusCode != 200) {
      throw Exception("Upload failed");
    }
  }


  Future<http.Response> downloadFile(int id) async {
    final res = await http.get(
      Uri.parse("$baseUrl/download/$id"),
    );

    if (res.statusCode == 200) {
      return res;
    } else {
      throw Exception("Download failed");
    }
  }



  Future<void> delete(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));

    if (res.statusCode != 200) {
      throw Exception("Delete failed");
    }
  }
}
