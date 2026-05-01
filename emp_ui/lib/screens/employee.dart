import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../service/employee.dart';
import 'document.dart';
import 'add_employee.dart';
import '../service/auth_service.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  final EmployeeService api = EmployeeService();
  List<EmployeeModel> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  void loadAll() async {
    setState(() => isLoading = true);
    try {
      final res = await api.getEmployees();
      setState(() {
        data = res;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void delete(int id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await api.deleteEmployee(id);
      loadAll();
    }
  }

  void showDetails(EmployeeModel e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            CircleAvatar(radius: 40, backgroundColor: Colors.blue.shade100, child: Text(e.fullName[0].toUpperCase(), style: const TextStyle(fontSize: 30))),
            const SizedBox(height: 15),
            Text(e.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("${e.designationName} | ${e.departmentName}", style: TextStyle(color: Colors.grey.shade600)),
            const Divider(height: 30),
            _row(Icons.email, "Email", e.email),
            _row(Icons.phone, "Phone", e.phone),
            _row(Icons.monetization_on, "Salary", "\$${e.salary}"),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String val) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Icon(icon, size: 20, color: Colors.blue), const SizedBox(width: 15), Text("$label: ", style: const TextStyle(color: Colors.grey)), Text(val, style: const TextStyle(fontWeight: FontWeight.bold))]));
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = AuthService.isAdmin() || AuthService.isHR();
    return Scaffold(
      appBar: AppBar(title: const Text("Employees"), backgroundColor: Colors.blue.shade900, foregroundColor: Colors.white),
      floatingActionButton: isAdmin ? FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEmployeePage())).then((_) => loadAll()),
        backgroundColor: Colors.blue.shade900,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
      body: isLoading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final e = data[index];
          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () => showDetails(e),
              borderRadius: BorderRadius.circular(12),
              hoverColor: Colors.blue.shade50,
              child: ListTile(
                leading: CircleAvatar(child: Text(e.fullName[0])),
                title: Text(e.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(e.designationName ?? ""),
                trailing: isAdmin ? IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => delete(e.id!)) : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
