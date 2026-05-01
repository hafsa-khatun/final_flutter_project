import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/leave_request.dart';
import '../models/employee.dart';
import '../service/leave_request.dart';
import '../service/employee.dart';
import '../service/auth_service.dart';

class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  State<LeaveRequestPage> createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  final LeaveRequestService api = LeaveRequestService();
  final EmployeeService empApi = EmployeeService();
  
  late Future<List<LeaveRequestModel>> futureData;
  List<EmployeeModel> employees = [];
  String selectedFilter = "ALL";

  @override
  void initState() {
    super.initState();
    loadData();
    _fetchEmployees();
  }

  void loadData() {
    futureData = api.getAll();
  }

  Future<void> _fetchEmployees() async {
    try {
      final data = await empApi.getEmployees();
      setState(() {
        final Map<int, EmployeeModel> uniqueMap = {};
        for (var e in data) {
          if (e.id != null) uniqueMap[e.id!] = e;
        }
        employees = uniqueMap.values.toList();
      });
    } catch (e) {
      debugPrint("Employee Load Error: $e");
    }
  }

  void refresh() {
    setState(() {
      loadData();
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void showForm([LeaveRequestModel? leave]) {
    final isEdit = leave != null;
    final user = AuthService.loggedUser;
    int? selectedEmpId;
    if (isEdit) {
      selectedEmpId = leave.employeeId;
    } else if (!AuthService.isAdmin() && !AuthService.isHR()) {
      selectedEmpId = user?.employeeId;
    }

    final typeController = TextEditingController(text: leave?.leaveType);
    final startController = TextEditingController(text: leave?.startDate);
    final endController = TextEditingController(text: leave?.endDate);
    final reasonController = TextEditingController(text: leave?.reason);
    final proposalController = TextEditingController(text: leave?.leaveProposal);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool exists = employees.any((e) => e.id == selectedEmpId);
          int? currentVal = exists ? selectedEmpId : null;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(isEdit ? "Update Request" : "Apply For Leave", style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: currentVal,
                    hint: const Text("Select Employee"),
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    items: employees.map((e) => DropdownMenuItem(value: e.id, child: Text(e.fullName))).toList(),
                    onChanged: (v) => setDialogState(() => selectedEmpId = v),
                  ),
                  const SizedBox(height: 15),
                  _buildInput(typeController, "Leave Type", Icons.category),
                  const SizedBox(height: 10),
                  _buildInput(startController, "Start Date", Icons.calendar_today, readOnly: true, onTap: () => _selectDate(context, startController)),
                  const SizedBox(height: 10),
                  _buildInput(endController, "End Date", Icons.calendar_month, readOnly: true, onTap: () => _selectDate(context, endController)),
                  const SizedBox(height: 10),
                  _buildInput(reasonController, "Reason", Icons.info_outline, maxLines: 2),
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
                  final request = LeaveRequestModel(
                    id: leave?.id,
                    employeeId: selectedEmpId,
                    employeeCode: "EMP-${emp.id}",
                    employeeName: emp.fullName,
                    leaveType: typeController.text,
                    startDate: startController.text,
                    endDate: endController.text,
                    reason: reasonController.text,
                    leaveProposal: proposalController.text,
                    status: leave?.status ?? "PENDING",
                  );
                  if (isEdit) await api.update(leave.id!, request);
                  else await api.create(request);
                  if (mounted) { Navigator.pop(context); refresh(); }
                },
                child: const Text("Submit"),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool readOnly = false, VoidCallback? onTap, int maxLines = 1}) {
    return TextField(
      controller: ctrl, readOnly: readOnly, onTap: onTap, maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon, color: Colors.blue.shade900),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdminOrHR = AuthService.isAdmin() || AuthService.isHR();
    final user = AuthService.loggedUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text("Leave Management", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        bottom: isAdminOrHR ? PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["ALL", "PENDING", "APPROVED", "REJECTED"].map((status) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: selectedFilter == status,
                      onSelected: (_) => setState(() => selectedFilter = status),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ) : null,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        backgroundColor: Colors.blue.shade900,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<LeaveRequestModel>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          var data = snapshot.data ?? [];
          if (!isAdminOrHR) data = data.where((l) => l.employeeName == user?.fullName).toList();
          else if (selectedFilter != "ALL") data = data.where((l) => l.status == selectedFilter).toList();

          if (data.isEmpty) return const Center(child: Text("No Requests Found"));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final l = data[index];
              return _buildColorfulCard(l, isAdminOrHR);
            },
          );
        },
      ),
    );
  }

  Widget _buildColorfulCard(LeaveRequestModel l, bool isAdminOrHR) {
    Color statusColor = l.status == "APPROVED" ? Colors.green : (l.status == "PENDING" ? Colors.orange : Colors.red);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: statusColor.withOpacity(0.3), width: 1.5)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        hoverColor: statusColor.withOpacity(0.05),
        onTap: () {
          if (isAdminOrHR && l.status == "PENDING") {
            _showActionDialog(l);
          }
        },
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(l.employeeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(children: [Icon(Icons.category, size: 14, color: Colors.blue.shade900), const SizedBox(width: 5), Text(l.leaveType)]),
              const SizedBox(height: 4),
              Row(children: [Icon(Icons.date_range, size: 14, color: Colors.blue.shade900), const SizedBox(width: 5), Text("${l.startDate} to ${l.endDate}")]),
              if (l.reason.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text("Reason: ${l.reason}", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ]
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor)),
            child: Text(l.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
      ),
    );
  }

  void _showActionDialog(LeaveRequestModel l) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Review Leave Request"),
        content: Text("Do you want to Approve or Reject this leave request from ${l.employeeName}?"),
        actions: [
          TextButton(
            onPressed: () async {
              await api.reject(l.id!);
              if (mounted) { Navigator.pop(context); refresh(); }
            },
            child: const Text("REJECT", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              await api.approve(l.id!);
              if (mounted) { Navigator.pop(context); refresh(); }
            },
            child: const Text("APPROVE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
