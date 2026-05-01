import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/attandance.dart';
import '../models/employee.dart';
import '../service/attandance.dart';
import '../service/employee.dart';
import '../service/auth_service.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final AttendanceService api = AttendanceService();
  final EmployeeService empApi = EmployeeService();
  
  late Future<List<AttendanceModel>> futureData;
  List<EmployeeModel> employees = [];
  String selectedFilter = "ALL";

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadAll() {
    setState(() {
      futureData = api.getAll();
    });
    _loadEmployees();
  }

  void _loadEmployees() async {
    try {
      final data = await empApi.getEmployees();
      setState(() { employees = data; });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void delete(int id) async {
    await api.delete(id);
    _loadAll();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() { controller.text = DateFormat('yyyy-MM-dd').format(picked); });
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      setState(() { controller.text = DateFormat('HH:mm:ss').format(dt); });
    }
  }

  void showForm([AttendanceModel? a]) {
    final isEdit = a != null;
    int? selectedEmpId;
    if (isEdit) {
      final emp = employees.where((e) => e.fullName == a.employeeName).firstOrNull;
      selectedEmpId = emp?.id;
    }

    final code = TextEditingController(text: a?.employeeCode);
    final date = TextEditingController(text: a?.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final inTime = TextEditingController(text: a?.inTime ?? "09:00:00");
    final outTime = TextEditingController(text: a?.outTime ?? "18:00:00");
    String status = a?.status ?? "PRESENT";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isEdit ? "Update Attendance" : "Mark Attendance", style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: employees.any((e) => e.id == selectedEmpId) ? selectedEmpId : null,
                  decoration: _inputDecoration("Select Employee", Icons.person),
                  items: employees.map((e) => DropdownMenuItem(value: e.id, child: Text(e.fullName))).toList(),
                  onChanged: (v) {
                    setDialogState(() {
                      selectedEmpId = v;
                      final emp = employees.firstWhere((e) => e.id == v);
                      code.text = "EMP-${emp.id}";
                    });
                  },
                ),
                const SizedBox(height: 15),
                _buildPopupField(code, "Employee Code", Icons.qr_code, readOnly: true),
                _buildPopupField(date, "Date", Icons.calendar_today, readOnly: true, onTap: () async {
                  await _selectDate(context, date);
                  setDialogState(() {});
                }),
                Row(
                  children: [
                    Expanded(child: _buildPopupField(inTime, "In Time", Icons.login, readOnly: true, onTap: () async {
                      await _selectTime(context, inTime);
                      setDialogState(() {});
                    })),
                    const SizedBox(width: 10),
                    Expanded(child: _buildPopupField(outTime, "Out Time", Icons.logout, readOnly: true, onTap: () async {
                      await _selectTime(context, outTime);
                      setDialogState(() {});
                    })),
                  ],
                ),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: _inputDecoration("Status", Icons.info_outline),
                  items: ["PRESENT", "ABSENT", "LATE"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setDialogState(() => status = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900, foregroundColor: Colors.white),
              onPressed: () async {
                if (selectedEmpId == null) return;
                final emp = employees.firstWhere((e) => e.id == selectedEmpId);
                final newData = AttendanceModel(
                  id: a?.id, employeeCode: code.text, employeeName: emp.fullName,
                  date: date.text, inTime: inTime.text, outTime: outTime.text, status: status,
                );
                if (isEdit) await api.update(a.id!, newData);
                else await api.create(newData);
                if (mounted) { Navigator.pop(context); _loadAll(); }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupField(TextEditingController ctrl, String label, IconData icon, {bool readOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl, readOnly: readOnly, onTap: onTap,
        decoration: _inputDecoration(label, icon),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label, prefixIcon: Icon(icon, size: 20, color: Colors.blue.shade900),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdminOrHR = AuthService.isAdmin() || AuthService.isHR();
    final user = AuthService.loggedUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Attendance Record", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        // 🔹 ফিল্টার ট্যাব বার
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["ALL", "PRESENT", "ABSENT", "LATE"].map((status) {
                  final isSelected = selectedFilter == status;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      selectedColor: Colors.white,
                      backgroundColor: Colors.blue.shade700,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.blue.shade900 : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          selectedFilter = status;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: isAdminOrHR 
        ? FloatingActionButton(onPressed: () => showForm(), backgroundColor: Colors.blue.shade900, child: const Icon(Icons.add, color: Colors.white))
        : null,
      body: FutureBuilder<List<AttendanceModel>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          var data = snapshot.data ?? [];
          if (!isAdminOrHR) data = data.where((a) => a.employeeName == user?.fullName).toList();
          
          // 🔹 ফিল্টার অনুযায়ী ডাটা আলাদা করা
          if (selectedFilter != "ALL") {
            data = data.where((a) => a.status == selectedFilter).toList();
          }

          if (data.isEmpty) return const Center(child: Text("No Records Found"));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final a = data[index];
              return Card(
                elevation: 2, margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(a.employeeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${a.date} | ${a.inTime} - ${a.outTime}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _statusBadge(a.status),
                      if (isAdminOrHR) ...[
                        const SizedBox(width: 5),
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => showForm(a)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => delete(a.id!)),
                      ]
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

  Widget _statusBadge(String status) {
    Color color = status == "PRESENT" ? Colors.green : (status == "LATE" ? Colors.orange : Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
