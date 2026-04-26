import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/project.dart';
import '../service/project.dart';
import '../service/auth_service.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final ProjectService api = ProjectService();
  late Future<List<ProjectModel>> futureProjects;
  String selectedFilter = "ALL";

  final List<String> statusList = ["PENDING", "RUNNING", "COMPLETED"];
  final List<String> priorityList = ["HIGH", "MEDIUM", "LOW"];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      futureProjects = api.getProjects();
    });
  }

  void refresh() {
    _loadData();
  }

  void deleteProject(int id) async {
    await api.deleteProject(id);
    refresh();
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

  // 🔹 প্রজেক্ট ডিটেইলস দেখানোর ফাংশন
  void showProjectDetails(ProjectModel p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              Text(p.projectName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text("Code: ${p.projectCode}", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
              const Divider(height: 30),
              _detailRow(Icons.person, "Client Name", p.clientName),
              _detailRow(Icons.monetization_on, "Budget", "\$${p.budget.toStringAsFixed(2)}"),
              _detailRow(Icons.priority_high, "Priority", p.priority),
              _detailRow(Icons.info_outline, "Status", p.status),
              _detailRow(Icons.calendar_today, "Start Date", p.startDate),
              _detailRow(Icons.calendar_month, "End Date", p.endDate),
              const SizedBox(height: 15),
              const Text("Description:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 5),
              Text(p.description, style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade900, size: 22),
          const SizedBox(width: 15),
          Text("$label: ", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  void showForm([ProjectModel? p]) {
    final name = TextEditingController(text: p?.projectName);
    final code = TextEditingController(text: p?.projectCode);
    final desc = TextEditingController(text: p?.description);
    final start = TextEditingController(text: p?.startDate);
    final end = TextEditingController(text: p?.endDate);
    final budget = TextEditingController(text: p?.budget.toString());
    final client = TextEditingController(text: p?.clientName);

    String status = p?.status ?? "PENDING";
    String priority = p?.priority ?? "MEDIUM";
    final isEdit = p != null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(isEdit ? "Update Project" : "New Project", style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInput(name, "Project Name", Icons.assignment),
                  _buildInput(code, "Project Code", Icons.qr_code),
                  _buildInput(desc, "Description", Icons.description, maxLines: 2),
                  _buildInput(start, "Start Date", Icons.calendar_today, readOnly: true, onTap: () => _selectDate(context, start)),
                  _buildInput(end, "End Date", Icons.calendar_month, readOnly: true, onTap: () => _selectDate(context, end)),
                  _buildInput(budget, "Budget", Icons.monetization_on, isNum: true),
                  _buildInput(client, "Client Name", Icons.person),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: _inputDecoration("Status", Icons.info_outline),
                    items: statusList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setDialogState(() => status = v!),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: priority,
                    decoration: _inputDecoration("Priority", Icons.priority_high),
                    items: priorityList.map((pr) => DropdownMenuItem(value: pr, child: Text(pr))).toList(),
                    onChanged: (v) => setDialogState(() => priority = v!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900, foregroundColor: Colors.white),
                onPressed: () async {
                  final newProject = ProjectModel(
                    id: p?.id,
                    projectName: name.text,
                    projectCode: code.text,
                    description: desc.text,
                    startDate: start.text,
                    endDate: end.text,
                    budget: double.tryParse(budget.text) ?? 0,
                    status: status,
                    clientName: client.text,
                    priority: priority,
                  );
                  if (isEdit) await api.updateProject(p.id!, newProject);
                  else await api.createProject(newProject);
                  if (mounted) { Navigator.pop(context); refresh(); }
                },
                child: const Text("Save"),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool readOnly = false, VoidCallback? onTap, bool isNum = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl, readOnly: readOnly, onTap: onTap, maxLines: maxLines,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: _inputDecoration(label, icon),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label, prefixIcon: Icon(icon, color: Colors.blue.shade900),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = AuthService.isAdmin() || AuthService.isHR();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text("Project Management", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["ALL", "PENDING", "RUNNING", "COMPLETED"].map((status) {
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
        ),
      ),
      floatingActionButton: isAdmin ? FloatingActionButton(
        onPressed: () => showForm(),
        backgroundColor: Colors.blue.shade900,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
      body: FutureBuilder<List<ProjectModel>>(
        future: futureProjects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          var data = snapshot.data ?? [];
          
          if (selectedFilter != "ALL") {
            data = data.where((p) => p.status == selectedFilter).toList();
          }

          if (data.isEmpty) return const Center(child: Text("No Projects Found"));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final p = data[index];
              return _buildProjectCard(p, isAdmin);
            },
          );
        },
      ),
    );
  }

  Widget _buildProjectCard(ProjectModel p, bool isAdmin) {
    Color statusColor = p.status == "COMPLETED" ? Colors.green : (p.status == "RUNNING" ? Colors.blue : Colors.orange);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: statusColor.withOpacity(0.3))),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        hoverColor: statusColor.withOpacity(0.05),
        onTap: () => showProjectDetails(p), // 🔹 ক্লিক করলে ডিটেইলস দেখাবে
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(p.projectName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  _statusBadge(p.status, statusColor),
                ],
              ),
              const SizedBox(height: 10),
              Text(p.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const Divider(height: 25),
              Row(
                children: [
                  _iconInfo(Icons.person, p.clientName),
                  const Spacer(),
                  _iconInfo(Icons.flag, p.priority, color: p.priority == "HIGH" ? Colors.red : Colors.grey),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _iconInfo(Icons.calendar_today, "${p.startDate} - ${p.endDate}"),
                  const Spacer(),
                  if (isAdmin) ...[
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => showForm(p)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => deleteProject(p.id!)),
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color)),
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _iconInfo(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.blue.shade900),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
