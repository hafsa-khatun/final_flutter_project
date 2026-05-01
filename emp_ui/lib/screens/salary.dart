import 'package:flutter/material.dart';
import '../models/salary.dart';
import '../models/employee.dart';
import '../service/salary.dart';
import '../service/employee.dart';

class SalaryPage extends StatefulWidget {
  const SalaryPage({super.key});

  @override
  State<SalaryPage> createState() => _SalaryPageState();
}

class _SalaryPageState extends State<SalaryPage> {
  final SalaryService api = SalaryService();
  final EmployeeService empApi = EmployeeService();
  
  late Future<List<SalaryModel>> futureSalary;
  List<EmployeeModel> employees = [];

  @override
  void initState() {
    super.initState();
    loadData();
    loadEmployees();
  }

  void loadData() {
    futureData();
  }

  void futureData() {
    futureSalary = api.getAllSalary();
  }

  void loadEmployees() async {
    try {
      final data = await empApi.getEmployees();
      setState(() {
        employees = data;
      });
    } catch (e) {
      debugPrint("Error loading employees: $e");
    }
  }

  void refresh() {
    setState(() {
      futureData();
    });
  }


  void showSalaryDetails(SalaryModel s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 20),
            Text(s.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("Salary Code: ${s.salaryCode}", style: TextStyle(color: Colors.grey.shade600)),
            const Divider(height: 30),
            _buildDetailRow(Icons.account_balance, "Bank Name", s.bankName),
            _buildDetailRow(Icons.money, "Basic Salary", "\$${s.basicSalary}"),
            _buildDetailRow(Icons.home, "House Rent", "\$${s.houseRent}"),
            _buildDetailRow(Icons.medical_services, "Medical", "\$${s.medical}"),
            _buildDetailRow(Icons.directions_bus, "Transport", "\$${s.transport}"),
            _buildDetailRow(Icons.timer, "Overtime (Rate x Hour)", "\$${s.overTimeRate} x ${s.overTimeHour}"),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Gross Salary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("\$${s.grossSalary.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 22),
          const SizedBox(width: 15),
          Text("$label:", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void deleteSalary(int id) async {
    try {
      await api.deleteSalary(id);
      refresh();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Salary deleted")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void showFormDialog([SalaryModel? salary]) {
    final bool isEditing = salary != null;
    final salaryCodeController = TextEditingController(text: salary?.salaryCode);
    final basicSalaryController = TextEditingController(text: salary?.basicSalary.toString() ?? "0");
    final houseRentController = TextEditingController(text: salary?.houseRent.toString() ?? "0");
    final medicalController = TextEditingController(text: salary?.medical.toString() ?? "0");
    final transportController = TextEditingController(text: salary?.transport.toString() ?? "0");
    final otRateController = TextEditingController(text: salary?.overTimeRate.toString() ?? "0");
    final otHourController = TextEditingController(text: salary?.overTimeHour.toString() ?? "0");
    final bankNameController = TextEditingController(text: salary?.bankName);
    
    int? selectedEmpId = salary?.employeeId;
    double calculatedGross = salary?.grossSalary ?? 0.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          void calculateGross() {
            double basic = double.tryParse(basicSalaryController.text) ?? 0;
            double rent = double.tryParse(houseRentController.text) ?? 0;
            double med = double.tryParse(medicalController.text) ?? 0;
            double trans = double.tryParse(transportController.text) ?? 0;
            double otRate = double.tryParse(otRateController.text) ?? 0;
            double otHour = double.tryParse(otHourController.text) ?? 0;
            setDialogState(() => calculatedGross = basic + rent + med + trans + (otRate * otHour));
          }

          return AlertDialog(
            title: Text(isEditing ? "Edit Salary" : "Add Salary"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: employees.any((e) => e.id == selectedEmpId) ? selectedEmpId : null,
                    decoration: const InputDecoration(labelText: "Select Employee"),
                    items: employees.map((e) => DropdownMenuItem(value: e.id, child: Text(e.fullName))).toList(),
                    onChanged: isEditing ? null : (v) {
                      setDialogState(() {
                        selectedEmpId = v;
                        final emp = employees.firstWhere((e) => e.id == v);
                        basicSalaryController.text = emp.salary.toString();
                        salaryCodeController.text = "SAL-${emp.id}";
                        calculateGross();
                      });
                    },
                  ),
                  _buildFormTextField(salaryCodeController, "Salary Code", readOnly: true),
                  _buildFormTextField(basicSalaryController, "Basic Salary", keyboardType: TextInputType.number, onChanged: (_) => calculateGross()),
                  _buildFormTextField(houseRentController, "House Rent", keyboardType: TextInputType.number, onChanged: (_) => calculateGross()),
                  _buildFormTextField(medicalController, "Medical Allowance", keyboardType: TextInputType.number, onChanged: (_) => calculateGross()),
                  _buildFormTextField(transportController, "Transport Allowance", keyboardType: TextInputType.number, onChanged: (_) => calculateGross()),
                  _buildFormTextField(otRateController, "OT Rate", keyboardType: TextInputType.number, onChanged: (_) => calculateGross()),
                  _buildFormTextField(otHourController, "OT Hours", keyboardType: TextInputType.number, onChanged: (_) => calculateGross()),
                  _buildFormTextField(bankNameController, "Bank Name"),
                  const SizedBox(height: 10),
                  Text("Gross Salary: \$${calculatedGross.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  if (selectedEmpId == null) return;
                  final emp = employees.firstWhere((e) => e.id == selectedEmpId);
                  final s = SalaryModel(
                    id: salary?.id,
                    employeeId: selectedEmpId,
                    salaryCode: salaryCodeController.text,
                    name: emp.fullName,
                    phone: emp.phone,
                    basicSalary: double.tryParse(basicSalaryController.text) ?? 0,
                    houseRent: double.tryParse(houseRentController.text) ?? 0,
                    medical: double.tryParse(medicalController.text) ?? 0,
                    transport: double.tryParse(transportController.text) ?? 0,
                    overTimeRate: double.tryParse(otRateController.text) ?? 0,
                    overTimeHour: double.tryParse(otHourController.text) ?? 0,
                    grossSalary: calculatedGross,
                    bankName: bankNameController.text,
                  );
                  if (isEditing) await api.updateSalary(salary.id!, s);
                  else await api.createSalary(s);
                  if (mounted) { Navigator.pop(context); refresh(); }
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFormTextField(TextEditingController controller, String label, {bool readOnly = false, TextInputType keyboardType = TextInputType.text, Function(String)? onChanged}) {
    return TextField(controller: controller, decoration: InputDecoration(labelText: label), readOnly: readOnly, keyboardType: keyboardType, onChanged: onChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text("Salary Management", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.blue.shade900, foregroundColor: Colors.white, elevation: 0),
      floatingActionButton: FloatingActionButton(onPressed: () => showFormDialog(), backgroundColor: Colors.blue.shade900, child: const Icon(Icons.add, color: Colors.white)),
      body: FutureBuilder<List<SalaryModel>>(
        future: futureSalary,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data ?? [];
          if (data.isEmpty) return const Center(child: Text("No Records Found"));

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final s = data[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell( // 🔹 স্যালারি কার্ড ক্লিকযোগ্য করা হয়েছে
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => showSalaryDetails(s), // 🔹 ক্লিক করলে ডিটেইলস দেখাবে
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(backgroundColor: Colors.blue.shade100, child: Icon(Icons.monetization_on, color: Colors.blue.shade900)),
                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Bank: ${s.bankName}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("\$${s.grossSalary.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                        const SizedBox(width: 10),
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => showFormDialog(s)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => deleteSalary(s.id!)),
                      ],
                    ),
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
