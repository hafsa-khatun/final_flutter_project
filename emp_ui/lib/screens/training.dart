import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/training.dart';
import '../service/training.dart';


class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  final TrainingService api = TrainingService();
  late Future<List<TrainingModel>> futureData;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() {
    futureData = api.getAll();
  }

  void refresh() {
    setState(() {
      load();
    });
  }

  void delete(int id) async {
    try {
      await api.delete(id);
      refresh();
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
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

  void showForm([TrainingModel? t]) {
    final title = TextEditingController(text: t?.trainingTitle);
    final trainer = TextEditingController(text: t?.trainerName);
    final desc = TextEditingController(text: t?.description);
    final start = TextEditingController(text: t?.startDate);
    final end = TextEditingController(text: t?.endDate);
    final loc = TextEditingController(text: t?.location);
    final cert = TextEditingController(text: t?.certificateNumber);
    final issue = TextEditingController(text: t?.issueDate);
    final grade = TextEditingController(text: t?.grade);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t == null ? "Add Training" : "Edit Training"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: "Training Title")),
              TextField(controller: trainer, decoration: const InputDecoration(labelText: "Trainer Name")),
              TextField(controller: desc, decoration: const InputDecoration(labelText: "Description")),
              
              // 🔹 Date Pickers
              TextField(
                controller: start,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Start Date",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context, start),
              ),
              TextField(
                controller: end,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "End Date",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context, end),
              ),
              
              TextField(controller: loc, decoration: const InputDecoration(labelText: "Location")),
              TextField(controller: cert, decoration: const InputDecoration(labelText: "Certificate Number")),
              
              TextField(
                controller: issue,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Issue Date",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context, issue),
              ),

              TextField(controller: grade, decoration: const InputDecoration(labelText: "Grade")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final model = TrainingModel(
                id: t?.id,
                trainingTitle: title.text,
                trainerName: trainer.text,
                description: desc.text,
                startDate: start.text,
                endDate: end.text,
                location: loc.text,
                certificateNumber: cert.text,
                issueDate: issue.text,
                grade: grade.text,
              );

              try {
                if (t == null) {
                  await api.create(model);
                } else {
                  await api.update(t.id!, model);
                }
                if (mounted) {
                  Navigator.pop(context);
                  refresh();
                }
              } catch (e) {
                debugPrint("Save Error: $e");
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Training Management")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<TrainingModel>>(
        future: futureData,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }

          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(child: Text("No trainings found"));
          }

          final data = snap.data!;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) {
              final t = data[i];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(t.trainingTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Trainer: ${t.trainerName}\nDate: ${t.startDate}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => showForm(t)),
                      IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => delete(t.id!)),
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
