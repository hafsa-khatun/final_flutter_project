import 'package:flutter/material.dart';
import '../models/department.dart';
import '../service/department.dart';

class DepartmentPage extends StatefulWidget {
  const DepartmentPage({super.key});

  @override
  State<DepartmentPage> createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  final DepartmentService api = DepartmentService();
  late Future<List<DepartmentModel>> futureDepartments;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    futureDepartments = api.getDepartments();
  }

  void refresh() {
    setState(() {
      loadData();
    });
  }


  void deleteDepartment(int id) async {
    try {
      await api.deleteDepartment(id);
      refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e')),
        );
      }
    }
  }

  // 🔹 Add/Edit dialog
  void showFormDialog([DepartmentModel? department]) {
    final TextEditingController controller =
        TextEditingController(text: department?.name);
    final bool isEditing = department != null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEditing ? 'Edit Department' : 'Add Department'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Department Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  if (isEditing) {
                    await api.updateDepartment(
                      department.id!,
                      DepartmentModel(id: department.id, name: controller.text),
                    );
                  } else {
                    await api.createDepartment(
                      DepartmentModel(name: controller.text),
                    );
                  }
                  if (mounted) {
                    Navigator.pop(context);
                    refresh();
                  }
                } catch (e) {
                  if (mounted) {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Department'),
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
      body: FutureBuilder<List<DepartmentModel>>(
        future: futureDepartments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final departments = snapshot.data ?? [];
          if (departments.isEmpty) {
            return const Center(child: Text('No Departments Found'));
          }
          return ListView.builder(
            itemCount: departments.length,
            itemBuilder: (context, index) {
              final dept = departments[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(dept.name),
                  subtitle: Text('ID: ${dept.id ?? ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showFormDialog(dept),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (dept.id != null) {
                            deleteDepartment(dept.id!);
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
