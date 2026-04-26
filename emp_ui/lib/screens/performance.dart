import 'package:flutter/material.dart';
import '../models/parformance.dart';
import '../service/parformance.dart';
import '../service/auth_service.dart';

class PerformancePage extends StatefulWidget {
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  final PerformanceService api = PerformanceService();
  late Future<List<PerformanceModel>> futureData;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadAll() {
    setState(() {
      futureData = api.getAll();
    });
  }

  void delete(int id) async {
    await api.delete(id);
    _loadAll();
  }

  void showForm([PerformanceModel? p]) {
    final empId = TextEditingController(text: p?.employeeId.toString());
    final rating = TextEditingController(text: p?.performanceRatting.toString());
    final kpi = TextEditingController(text: p?.kpiScore.toString());
    final review = TextEditingController(text: p?.annualReview);
    bool promotion = p?.promotion ?? false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(p == null ? "Add Performance Record" : "Update Performance", style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField(empId, "Employee ID", Icons.badge, isNum: true),
                _buildField(rating, "Rating (1.0 - 5.0)", Icons.star_half, isNum: true),
                _buildField(kpi, "KPI Score", Icons.analytics, isNum: true),
                _buildField(review, "Annual Review Note", Icons.rate_review, maxLines: 3),
                SwitchListTile(
                  title: const Text("Eligible for Promotion?"),
                  activeColor: Colors.blue.shade900,
                  value: promotion,
                  onChanged: (val) => setStateDialog(() => promotion = val),
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900, foregroundColor: Colors.white),
              onPressed: () async {
                final model = PerformanceModel(
                  id: p?.id,
                  employeeId: int.parse(empId.text),
                  performanceRatting: double.parse(rating.text),
                  kpiScore: double.parse(kpi.text),
                  annualReview: review.text,
                  promotion: promotion,
                );
                if (p == null) await api.create(model);
                else await api.update(p.id!, model);
                if (mounted) { Navigator.pop(context); _loadAll(); }
              },
              child: const Text("Save Record"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool isNum = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label, prefixIcon: Icon(icon, color: Colors.blue.shade900),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = AuthService.isAdmin() || AuthService.isHR();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Performance Tracking", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        actions: [IconButton(onPressed: _loadAll, icon: const Icon(Icons.refresh))],
      ),
      floatingActionButton: isAdmin ? FloatingActionButton(
        onPressed: () => showForm(),
        backgroundColor: Colors.blue.shade900,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
      body: FutureBuilder<List<PerformanceModel>>(
        future: futureData,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final data = snap.data ?? [];
          if (data.isEmpty) return const Center(child: Text("No Performance Records Found"));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (_, i) {
              final p = data[i];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: _getRatingColor(p.performanceRatting).withOpacity(0.1),
                    child: Text(p.performanceRatting.toString(), style: TextStyle(color: _getRatingColor(p.performanceRatting), fontWeight: FontWeight.bold)),
                  ),
                  title: Text("Employee ID: ${p.employeeId}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text("KPI Score: ${p.kpiScore}"),
                      Text("Promotion: ${p.promotion ? "Yes (Eligible)" : "No"}", style: TextStyle(color: p.promotion ? Colors.green : Colors.grey, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  trailing: isAdmin ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit_note, color: Colors.blue), onPressed: () => showForm(p)),
                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => delete(p.id!)),
                    ],
                  ) : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green.shade700;
    if (rating >= 3.5) return Colors.blue.shade700;
    if (rating >= 2.5) return Colors.orange.shade700;
    return Colors.red.shade700;
  }
}
