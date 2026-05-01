import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/leave.dart';
import '../models/registration.dart';
import '../service/leave.dart';
import '../service/registration.dart';


class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  final LeaveService api = LeaveService();
  final RegistrationService regApi = RegistrationService();

  late Future<List<LeaveModel>> futureLeaves;
  List<RegistrationModel> registrations = [];

  @override
  void initState() {
    super.initState();
    loadData();
    loadRegistrations();
  }

  void loadData() {
    futureLeaves = api.getLeaves();
  }

  void loadRegistrations() async {
    final data = await regApi.getRegistrations();
    setState(() {
      registrations = data;
    });
  }

  void refresh() {
    setState(() {
      loadData();
    });
  }

  void deleteLeave(int id) async {
    await api.deleteLeave(id);
    refresh();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateFormat('yyyy-MM-dd').parse(controller.text);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }


  void showForm([LeaveModel? leave]) {
    final typeController = TextEditingController(text: leave?.leaveType);
    final startController = TextEditingController(text: leave?.startDate);
    final endController = TextEditingController(text: leave?.endDate);
    final statusController = TextEditingController(text: leave?.status);

    int? selectedRegId = leave?.registrationId;
    final isEdit = leave != null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEdit ? "Edit Leave" : "Add Leave"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: typeController,
                    decoration: const InputDecoration(labelText: "Leave Type"),
                  ),
                  TextField(
                    controller: startController,
                    decoration: const InputDecoration(
                      labelText: "Start Date",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      await _selectDate(context, startController);
                      setDialogState(() {});
                    },
                  ),
                  TextField(
                    controller: endController,
                    decoration: const InputDecoration(
                      labelText: "End Date",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      await _selectDate(context, endController);
                      setDialogState(() {});
                    },
                  ),
                  TextField(
                    controller: statusController,
                    decoration: const InputDecoration(labelText: "Status"),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "Select Employee"),
                    value: selectedRegId,
                    items: registrations.map((r) {
                      return DropdownMenuItem<int>(
                        value: r.id,
                        child: Text(r.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRegId = value;
                      });
                    },
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (typeController.text.isNotEmpty && selectedRegId != null) {
                    final newLeave = LeaveModel(
                      id: leave?.id,
                      leaveType: typeController.text,
                      startDate: startController.text,
                      endDate: endController.text,
                      status: statusController.text,
                      registrationId: selectedRegId!,
                    );

                    if (isEdit) {
                      await api.updateLeave(leave.id!, newLeave);
                    } else {
                      await api.createLeave(newLeave);
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      refresh();
                    }
                  }
                },
                child: const Text("Save"),
              )
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
        title: const Text("Leave Management"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<LeaveModel>>(
        future: futureLeaves,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text("No Leave Found"));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final l = data[index];

              final regName = registrations
                  .firstWhere((r) => r.id == l.registrationId,
                  orElse: () => RegistrationModel(id: 0, name: "Unknown", phone: "", reason: ""))
                  .name;

              return Card(
                child: ListTile(
                  title: Text(l.leaveType),
                  subtitle: Text("$regName | ${l.startDate} → ${l.endDate}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showForm(l),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (l.id != null) deleteLeave(l.id!);
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
