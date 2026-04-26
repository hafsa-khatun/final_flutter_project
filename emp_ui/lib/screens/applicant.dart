import 'package:flutter/material.dart';

import '../models/applicant.dart';
import '../service/applicant.dart';


class ApplicantPage extends StatefulWidget {
  const ApplicantPage({super.key});

  @override
  State<ApplicantPage> createState() => _ApplicantPageState();
}

class _ApplicantPageState extends State<ApplicantPage> {
  final ApplicantService api = ApplicantService();
  List<ApplicantModel> data = [];

  final List<String> statusList = [
    "APPLIED",
    "INTERVIEW_SCHEDULED",
    "SELECTED",
    "REJECTED"
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    try {
      final res = await api.getAll();
      setState(() {
        data = res;
      });
    } catch (e) {
      debugPrint("Load Error: $e");
    }
  }

  void refresh() {
    loadData();
  }

  void delete(int id) async {
    try {
      await api.delete(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Applicant deleted successfully"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Delete failed: $e"),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // 🔹 Add Applicant
  void showForm() {
    final name = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Applicant"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: phone, decoration: const InputDecoration(labelText: "Phone")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await api.create(
                  ApplicantModel(
                    fullName: name.text,
                    email: email.text,
                    phone: phone.text,
                    status: "APPLIED",
                  ),
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Applicant saved successfully"),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                  refresh();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to save: $e"),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "SELECTED":
        return Colors.green;
      case "REJECTED":
        return Colors.red;
      case "INTERVIEW_SCHEDULED":
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Applicants"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: refresh)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showForm,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final a = data[index];

          return Card(
            child: ListTile(
              title: Text(a.fullName),
              subtitle: Text(a.email),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // 🔹 Status Dropdown
                  DropdownButton<String>(
                    value: a.status,
                    items: statusList.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(
                          s,
                          style: TextStyle(color: getStatusColor(s)),
                        ),
                      );
                    }).toList(),
                    onChanged: (newStatus) async {
                      if (newStatus != null) {
                        try {
                          await api.updateStatus(a.id!, newStatus);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Status updated to $newStatus"),
                                backgroundColor: Colors.blue,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                          refresh();
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Update failed: $e"),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),

                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      if (a.id != null) delete(a.id!);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
