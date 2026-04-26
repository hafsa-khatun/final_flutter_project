import 'package:flutter/material.dart';
import '../models/registration.dart';
import '../service/registration.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final RegistrationService api = RegistrationService();
  late Future<List<RegistrationModel>> futureData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      futureData = api.getRegistrations();
    });
  }

  void _deleteData(int id) async {
    try {
      await api.deleteRegistration(id);
      _loadData();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted successfully")));
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  void _showForm([RegistrationModel? reg]) {
    final nameController = TextEditingController(text: reg?.name);
    final phoneController = TextEditingController(text: reg?.phone);
    final reasonController = TextEditingController(text: reg?.reason);
    final bool isEdit = reg != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(isEdit ? Icons.edit_note : Icons.app_registration, color: Colors.blue.shade900),
            const SizedBox(width: 10),
            Text(isEdit ? "Update Entry" : "New Registration", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPopupField(nameController, "Full Name", Icons.person),
              _buildPopupField(phoneController, "Phone Number", Icons.phone, keyboardType: TextInputType.phone),
              _buildPopupField(reasonController, "Reason for Contact", Icons.info_outline, maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade900,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              if (nameController.text.isEmpty || phoneController.text.isEmpty) return;
              
              final newReg = RegistrationModel(
                id: reg?.id,
                name: nameController.text,
                phone: phoneController.text,
                reason: reasonController.text,
              );

              try {
                if (isEdit) await api.updateRegistration(reg.id!, newReg);
                else await api.createRegistration(newReg);
                if (mounted) { Navigator.pop(context); _loadData(); }
              } catch (e) {
                debugPrint("Save error: $e");
              }
            },
            child: const Text("Save Entry"),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupField(TextEditingController ctrl, String label, IconData icon, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 22, color: Colors.blue.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.all(15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Registrations", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: Colors.blue.shade900,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add New", style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<List<RegistrationModel>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          
          final data = snapshot.data ?? [];
          if (data.isEmpty) return const Center(child: Text("No Registrations Found"));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final r = data[index];
              return Card(
                elevation: 1.5,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(r.name[0].toUpperCase(), style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [const Icon(Icons.phone, size: 14, color: Colors.grey), const SizedBox(width: 5), Text(r.phone)]),
                        const SizedBox(height: 3),
                        Text(r.reason, style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showForm(r)),
                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _deleteData(r.id!)),
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
