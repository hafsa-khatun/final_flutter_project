import 'package:emp_ui/screens/applicant.dart';
import 'package:emp_ui/screens/attandance.dart';
import 'package:emp_ui/screens/designation.dart';
import 'package:emp_ui/screens/document.dart';
import 'package:emp_ui/screens/employee.dart';
import 'package:emp_ui/screens/leave.dart';
import 'package:emp_ui/screens/leave_request.dart';
import 'package:emp_ui/screens/payroll_process.dart';
import 'package:emp_ui/screens/performance.dart';
import 'package:emp_ui/screens/project.dart';
import 'package:emp_ui/screens/registration.dart';
import 'package:emp_ui/screens/salary.dart';
import 'package:emp_ui/screens/training.dart';
import 'package:emp_ui/service/auth_service.dart';
import 'package:flutter/material.dart';

import 'screens/department.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.loggedUser;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blue.shade600],
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 45, color: Colors.blue),
            ),
            accountName: Text(
              user?.fullName ?? "User",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text("Role: ${user?.role ?? 'N/A'}"),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                if (AuthService.isAdmin() || AuthService.isHR())
                  _buildGroup(context, 'HR Management', Icons.badge, [
                    _item(context, 'Department', Icons.business, const DepartmentPage()),
                    _item(context, 'Designation', Icons.work, const DesignationPage()),
                    _item(context, 'Employee', Icons.people, const EmployeePage()),
                    _item(context, 'Project', Icons.assignment_turned_in, const ProjectPage()),
                    if (AuthService.isAdmin()) _item(context, 'Salary', Icons.payments, const SalaryPage()),
                    _item(context, 'Registration', Icons.person_add, const RegistrationPage()),
                    _item(context, 'Leave', Icons.event_available, const LeavePage()),
                  ]),

                _buildGroup(context, 'Operations', Icons.settings_suggest, [
                  _item(context, 'Leave Request', Icons.request_page, const LeaveRequestPage()),
                  _item(context, 'Attendance', Icons.fact_check, const AttendancePage()),
                  if (AuthService.isAdmin() || AuthService.isHR())
                    _item(context, 'Payroll Process', Icons.account_balance_wallet, const PayrollPage()),
                  if (AuthService.isAdmin() || AuthService.isHR())
                    _item(context, 'Applicant', Icons.person_search, const ApplicantPage()),
                  _item(context, 'Document', Icons.folder_shared, const DocumentPage()),
                ]),

                _buildGroup(context, 'Development', Icons.trending_up, [
                  _item(context, 'Training', Icons.model_training, const TrainingPage()),
                  _item(context, 'Performance', Icons.speed, const PerformancePage()),
                ]),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              AuthService.loggedUser = null;
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildGroup(BuildContext context, String title, IconData icon, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: children,
    );
  }

  Widget _item(BuildContext context, String title, IconData icon, Widget page) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.blue.shade400),
      title: Text(title),
      dense: true,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}
