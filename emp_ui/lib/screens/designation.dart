import 'package:emp_ui/service/designation.dart';
import 'package:flutter/material.dart';
import '../models/designation.dart';
import '../service/department.dart';
import '../models/department.dart';

class DesignationPage extends StatefulWidget {
  const DesignationPage({super.key});

  @override
  State<DesignationPage> createState() => _DesignationPageState();
}

class _DesignationPageState extends State<DesignationPage> {
  final DesignationService api = DesignationService();
  final DepartmentService deptApi = DepartmentService();
  
  late Future<List<DesignationModel>> futureDesignations;
  List<DepartmentModel> departments = [];

  @override
  void initState() {
    super.initState();
    loadData();
    loadDepartments();
  }

  void loadData() {
    futureDesignations = api.getDesignations();
  }

  void loadDepartments() async {
    try {
      final data = await deptApi.getDepartments();
      setState(() {
        departments = data;
      });
    } catch (e) {
      debugPrint('Error loading departments: $e');
    }
  }

  void refresh() {
    setState(() {
      loadData();
    });
  }

  // 🔹 Delete
  void deleteDesignation(int id) async {
    try {
      await api.deleteDesignation(id);
      refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  // 🔹 Add/Edit Dialog
  void showFormDialog([DesignationModel? designation]) {
    final nameController = TextEditingController(text: designation?.name);
    int? selectedDeptId = designation?.departmentId;
    final bool isEditing = designation != null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEditing ? 'Edit Designation' : 'Add Designation'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Designation Name'),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Select Department'),
                  items: departments.map((dept) {
                    return DropdownMenuItem<int>(
                      value: dept.id,
                      child: Text(dept.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedDeptId = value;
                    });
                  },
                  value: selectedDeptId,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty && selectedDeptId != null) {
                    try {
                      if (isEditing) {
                        await api.updateDesignation(
                          designation.id!,
                          DesignationModel(
                            id: designation.id,
                            name: nameController.text,
                            departmentId: selectedDeptId!,
                          ),
                        );
                      } else {
                        await api.createDesignation(
                          DesignationModel(
                            name: nameController.text,
                            departmentId: selectedDeptId!,
                          ),
                        );
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                        refresh();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Designations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showFormDialog(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<DesignationModel>>(
        future: futureDesignations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text('No Designations Found'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final desg = data[index];
              final deptName = departments
                  .firstWhere((d) => d.id == desg.departmentId, 
                      orElse: () => DepartmentModel(id: 0, name: 'Unknown'))
                  .name;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(desg.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Dept: $deptName'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showFormDialog(desg),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (desg.id != null) {
                            deleteDesignation(desg.id!);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
