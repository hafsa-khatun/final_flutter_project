import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../models/department.dart';
import '../models/designation.dart';
import '../service/employee.dart';
import '../service/department.dart';
import '../service/designation.dart';

class AddEmployeePage extends StatefulWidget {
  final EmployeeModel? employee;
  const AddEmployeePage({super.key, this.employee});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  final EmployeeService empService = EmployeeService();
  final DepartmentService deptService = DepartmentService();
  final DesignationService desigService = DesignationService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final salaryController = TextEditingController();

  String selectedGender = 'MALE';
  String selectedEmpType = 'FULL_TIME';
  int? selectedDeptId;
  int? selectedDesigId;

  List<DepartmentModel> departments = [];
  List<DesignationModel> allDesignations = [];
  List<DesignationModel> filteredDesignations = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      // এডিট মোড হলে ডাটা সেট করুন
      nameController.text = widget.employee!.fullName;
      emailController.text = widget.employee!.email;
      phoneController.text = widget.employee!.phone;
      salaryController.text = widget.employee!.salary.toString();
      selectedGender = widget.employee!.gender;
      selectedEmpType = widget.employee!.employeeType;
      selectedDeptId = widget.employee!.departmentId;
      selectedDesigId = widget.employee!.designationId;
    }
    _loadInitialData();
  }

  void _loadInitialData() async {
    try {
      final depts = await deptService.getDepartments();
      final desigs = await desigService.getDesignations();
      setState(() {
        departments = depts;
        allDesignations = desigs;
        if (selectedDeptId != null) {
          filteredDesignations = allDesignations.where((d) => d.departmentId == selectedDeptId).toList();
        }
      });
    } catch (e) {
      debugPrint("Load Error: $e");
    }
  }

  void _saveEmployee() async {
    if (_formKey.currentState!.validate()) {
      if (selectedDeptId == null || selectedDesigId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select Dept & Desig")));
        return;
      }

      setState(() => isLoading = true);
      final model = EmployeeModel(
        id: widget.employee?.id,
        fullName: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        gender: selectedGender,
        employeeType: selectedEmpType,
        salary: double.parse(salaryController.text),
        departmentId: selectedDeptId!,
        designationId: selectedDesigId!,
      );

      try {
        if (widget.employee == null) {
          await empService.createEmployee(model);
        } else {
          await empService.updateEmployee(widget.employee!.id!, model);
        }
        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        debugPrint("Save Error: $e");
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee == null ? "Add Employee" : "Edit Employee"),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(nameController, "Full Name", Icons.person),
              _buildField(emailController, "Email", Icons.email),
              _buildField(phoneController, "Phone", Icons.phone),
              _buildField(salaryController, "Salary", Icons.monetization_on, isNum: true),
              
              Row(
                children: [
                  Expanded(child: _buildDropdown("Gender", selectedGender, ['MALE', 'FEMALE'], (v) => setState(() => selectedGender = v!))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildDropdown("Type", selectedEmpType, ['FULL_TIME', 'PART_TIME', 'CONTRACT'], (v) => setState(() => selectedEmpType = v!))),
                ],
              ),
              const SizedBox(height: 15),

              // 🔹 Department Dropdown
              DropdownButtonFormField<int>(
                value: selectedDeptId,
                decoration: const InputDecoration(labelText: "Department", border: OutlineInputBorder()),
                items: departments.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                onChanged: (v) {
                  setState(() {
                    selectedDeptId = v;
                    selectedDesigId = null; // Reset Desig
                    filteredDesignations = allDesignations.where((d) => d.departmentId == v).toList();
                  });
                },
              ),
              const SizedBox(height: 15),

              // 🔹 Designation Dropdown (Filtered)
              DropdownButtonFormField<int>(
                value: selectedDesigId,
                decoration: const InputDecoration(labelText: "Designation", border: OutlineInputBorder()),
                items: filteredDesignations.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                onChanged: (v) => setState(() => selectedDesigId = v),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveEmployee,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900, foregroundColor: Colors.white),
                  child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("SAVE EMPLOYEE"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildDropdown(String label, String val, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: val,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}
