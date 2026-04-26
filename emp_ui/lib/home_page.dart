import 'package:emp_ui/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // 🔹 চার্ট লাইব্রেরি
import 'service/employee.dart';
import 'service/department.dart';
import 'service/training.dart';
import 'service/applicant.dart';
import 'service/project.dart';
import 'service/parformance.dart';
import 'models/employee.dart';
import 'models/department.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final EmployeeService empService = EmployeeService();
  final DepartmentService deptService = DepartmentService();
  final TrainingService trainingService = TrainingService();
  final ApplicantService applicantService = ApplicantService();
  final ProjectService projectService = ProjectService();
  final PerformanceService performanceService = PerformanceService();

  int totalEmp = 0;
  int activeEmp = 0;
  int totalApplicants = 0;
  int totalTrainings = 0;
  int totalProjects = 0;
  int performanceRecords = 0;
  List<DepartmentModel> departments = [];
  List<EmployeeModel> allEmployees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final emps = await empService.getEmployees();
      final depts = await deptService.getDepartments();
      final trainings = await trainingService.getAll();
      final applicants = await applicantService.getAll();
      final projects = await projectService.getProjects();
      final performance = await performanceService.getAll();

      if (mounted) {
        setState(() {
          allEmployees = emps;
          totalEmp = emps.length;
          activeEmp = emps.where((e) => e.status == 'ACTIVE').length;
          departments = depts;
          totalApplicants = applicants.length;
          totalTrainings = trainings.length;
          totalProjects = projects.length;
          performanceRecords = performance.length;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  int _getEmployeeCountForDept(int deptId) {
    return allEmployees.where((e) => e.departmentId == deptId).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('EMS Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade900,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white), onPressed: _loadDashboardData),
        ],
      ),
      drawer: const AppSidebar(),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Company Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 15),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildStatCard("Total Employees", totalEmp.toString(), Icons.people, Colors.blue),
                  _buildStatCard("Active Staff", activeEmp.toString(), Icons.check_circle, Colors.green),
                  _buildStatCard("Applicants", totalApplicants.toString(), Icons.person_search, Colors.orange),
                  _buildStatCard("Training", totalTrainings.toString(), Icons.school, Colors.purple),
                  _buildStatCard("Projects", totalProjects.toString(), Icons.rocket_launch, Colors.teal),
                  _buildStatCard("Performance", performanceRecords.toString(), Icons.speed, Colors.redAccent),
                ],
              ),

              const SizedBox(height: 30),
              const Text("Department Distribution", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 15),
              
              // 🔹 Pie Chart Card
              _buildChartCard(),

              const SizedBox(height: 30),
              const Text("Department Staffing", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 15),
              
              isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: departments.length,
                    itemBuilder: (context, index) {
                      final dept = departments[index];
                      final count = _getEmployeeCountForDept(dept.id!);
                      return _buildDeptCard(dept.name, count);
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    if (isLoading || allEmployees.isEmpty) {
      return const SizedBox(height: 100, child: Center(child: Text("No Data for Chart")));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Staff Split by Department", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: _getChartSections(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getChartSections() {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.teal, Colors.pink];
    List<PieChartSectionData> sections = [];

    for (int i = 0; i < departments.length; i++) {
      final count = _getEmployeeCountForDept(departments[i].id!);
      if (count > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[i % colors.length],
            value: count.toDouble(),
            title: '${departments[i].name}\n$count',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      }
    }
    return sections;
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      hoverColor: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, spreadRadius: 2)],
          border: Border(left: BorderSide(color: color, width: 5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildDeptCard(String name, int count) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: Icon(Icons.business, color: Colors.blue.shade900, size: 20)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.blue.shade900, borderRadius: BorderRadius.circular(12)),
          child: Text(count.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }
}
