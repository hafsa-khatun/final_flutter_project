import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/payroll_process.dart';
import '../service/paroll_process.dart';
import '../service/attandance.dart';
import '../service/leave_request.dart';

class PayrollPage extends StatefulWidget {
  const PayrollPage({super.key});

  @override
  State<PayrollPage> createState() => _PayrollPageState();
}

class _PayrollPageState extends State<PayrollPage> {
  final PayrollService api = PayrollService();
  final AttendanceService attendanceApi = AttendanceService();
  final LeaveRequestService leaveApi = LeaveRequestService();
  
  List<PayrollModel> data = [];
  bool isLoading = false;

  final List<String> monthsList = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  void loadAll() async {
    setState(() => isLoading = true);
    try {
      final res = await api.getAll();
      setState(() { data = res; });
    } catch (e) {
      debugPrint("Load Error: $e");
    }
    setState(() => isLoading = false);
  }

  String _formatToYearMonth(String monthName) {
    int monthIndex = monthsList.indexOf(monthName) + 1;
    String monthNum = monthIndex.toString().padLeft(2, '0');
    String year = DateTime.now().year.toString();
    return "$year-$monthNum";
  }

  int _calculateDaysBetween(String startStr, String endStr, String currentMonthYear) {
    try {
      DateTime start = DateTime.parse(startStr);
      DateTime end = DateTime.parse(endStr);
      int count = 0;
      for (int i = 0; i <= end.difference(start).inDays; i++) {
        DateTime current = start.add(Duration(days: i));
        if (DateFormat('yyyy-MM').format(current) == currentMonthYear) count++;
      }
      return count;
    } catch (e) { return 0; }
  }

  Future<void> process() async {
    setState(() => isLoading = true);
    try {
      String formattedMonth = _formatToYearMonth(selectedMonth);
      final rawPayroll = await api.processPayroll(formattedMonth);
      final allAttendance = await attendanceApi.getAll();
      final allLeaves = await leaveApi.getAll();

      List<PayrollModel> updatedData = [];
      for (var p in rawPayroll) {
        int totalAbsent = allAttendance.where((a) {
          return (a.employeeCode.trim() == p.employeeCode.trim()) && a.date.contains(formattedMonth) && a.status.toUpperCase() == "ABSENT";
        }).length;

        int approvedLeaveCount = 0;
        var employeeLeaves = allLeaves.where((l) => l.employeeName.trim() == p.employeeName.trim() && l.status.toUpperCase() == "APPROVED");
        for (var leave in employeeLeaves) {
          approvedLeaveCount += _calculateDaysBetween(leave.startDate, leave.endDate, formattedMonth);
        }

        double dailySalary = p.grossSalary / 30;
        double calculatedDeduction = totalAbsent * dailySalary; 
        double calculatedNetSalary = p.grossSalary - calculatedDeduction;

        updatedData.add(PayrollModel(
          id: p.id, employeeCode: p.employeeCode, employeeName: p.employeeName,
          basicSalary: p.basicSalary, grossSalary: p.grossSalary, month: p.month,
          absentDays: totalAbsent, approvedLeaveDays: approvedLeaveCount,
          deduction: calculatedDeduction, netSalary: calculatedNetSalary,
        ));
      }
      setState(() { data = updatedData; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payroll Processed Successfully"), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Process Error: $e"), backgroundColor: Colors.red));
    }
    setState(() => isLoading = false);
  }

  void delete(int id) async {
    try {
      await api.delete(id);
      setState(() => data.removeWhere((e) => e.id == id));
    } catch (e) { debugPrint("Delete Error: $e"); }
  }

  void showDetails(PayrollModel p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text(p.employeeName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("Month: ${p.month} | Code: ${p.employeeCode}", style: TextStyle(color: Colors.grey.shade600)),
            const Divider(height: 30),
            _infoRow("Gross Salary", "\$${p.grossSalary.toStringAsFixed(2)}"),
            _infoRow("Absent Days", "${p.absentDays} Days", color: Colors.orange),
            _infoRow("Approved Leaves", "${p.approvedLeaveDays} Days", color: Colors.green),
            _infoRow("Deductions", "-\$${p.deduction.toStringAsFixed(2)}", color: Colors.red),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Net Salary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("\$${p.netSalary.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Payroll Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade900,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMonth,
                        isExpanded: true,
                        items: monthsList.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                        onChanged: (v) => setState(() => selectedMonth = v!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : process,
                  icon: const Icon(Icons.bolt, size: 18),
                  label: const Text("PROCESS"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
                ),
              ],
            ),
          ),
          if (isLoading) const LinearProgressIndicator(),
          Expanded(
            child: data.isEmpty && !isLoading
              ? const Center(child: Text("No Payroll Data. Select a month and process."))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final p = data[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: () => showDetails(p),
                        borderRadius: BorderRadius.circular(12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: const Icon(Icons.payments, color: Colors.blue)),
                          title: Text(p.employeeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Net Payable: \$${p.netSalary.toStringAsFixed(2)}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => delete(p.id!),
                          ),
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

  Widget _infoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
