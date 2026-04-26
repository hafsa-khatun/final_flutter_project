import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/document.dart';
import '../models/employee.dart';
import '../service/document.dart';
import '../service/employee.dart';


class DocumentPage extends StatefulWidget {
  final int? employeeId;

  const DocumentPage({super.key, this.employeeId});

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  final DocumentService api = DocumentService();
  final EmployeeService employeeApi = EmployeeService();
  
  List<DocumentModel> data = [];
  List<EmployeeModel> employees = [];
  
  final List<String> docTypes = ["CV", "NID", "OFFER_LETTER"];
  String selectedType = "CV";
  int? selectedEmployeeId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedEmployeeId = widget.employeeId;
    loadEmployees();
    loadData();
  }

  void loadEmployees() async {
    try {
      final res = await employeeApi.getEmployees();
      setState(() {
        employees = res;
      });
    } catch (e) {
      debugPrint("Employee Load Error: $e");
    }
  }

  void loadData() async {
    setState(() => isLoading = true);
    try {
      List<DocumentModel> res;
      if (selectedEmployeeId != null) {
        res = await api.getByEmployee(selectedEmployeeId!);
      } else {
        res = await api.getAll();
      }
      setState(() {
        data = res;
      });
    } catch (e) {
      debugPrint("Load Error: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> pickAndUpload() async {
    if (selectedEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an employee first")),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      try {
        await api.uploadFile(
          employeeId: selectedEmployeeId!,
          file: file,
          documentType: selectedType,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upload Successful"), backgroundColor: Colors.green),
        );
        loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload Failed: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void delete(int id) async {
    try {
      await api.delete(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Deleted successfully"), backgroundColor: Colors.red),
      );
      loadData();
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Documents"),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: loadData)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // 🔹 এমপ্লয়ী সিলেক্ট করার ড্রপডাউন
                DropdownButtonFormField<int>(
                  value: selectedEmployeeId,
                  hint: const Text("Select Employee"),
                  items: employees.map((e) => DropdownMenuItem(
                    value: e.id,
                    child: Text(e.fullName),
                  )).toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedEmployeeId = v;
                    });
                    loadData();
                  },
                  decoration: const InputDecoration(labelText: "Employee"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedType,
                        items: docTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => selectedType = v!),
                        decoration: const InputDecoration(labelText: "Document Type"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: pickAndUpload, 
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Upload"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isLoading) const LinearProgressIndicator(),
          Expanded(
            child: data.isEmpty && !isLoading
                ? const Center(child: Text("No documents found"))
                : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final d = data[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.description, color: Colors.blue),
                    title: Text(d.fileName),
                    subtitle: Text("Type: ${d.documentType}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download, color: Colors.green),
                          onPressed: () async {
                            await api.downloadFile(d.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Downloaded ${d.fileName}")),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => delete(d.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
