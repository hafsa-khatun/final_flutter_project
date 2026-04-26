class PayrollModel {
  final int? id;
  final String employeeCode;
  final String employeeName;
  final double basicSalary;
  final double grossSalary;
  final String month;
  final int absentDays;
  final int approvedLeaveDays;
  final double deduction;
  final double netSalary;

  PayrollModel({
    this.id,
    required this.employeeCode,
    required this.employeeName,
    required this.basicSalary,
    required this.grossSalary,
    required this.month,
    required this.absentDays,
    required this.approvedLeaveDays,
    required this.deduction,
    required this.netSalary,
  });

  factory PayrollModel.fromJson(Map<String, dynamic> json) {
    return PayrollModel(
      id: json['id'],
      employeeCode: json['employeeCode'],
      employeeName: json['employeeName'],
      basicSalary: (json['basicSalary'] ?? 0).toDouble(),
      grossSalary: (json['grossSalary'] ?? 0).toDouble(),
      month: json['month'],
      absentDays: json['absentDays'],
      approvedLeaveDays: json['approvedLeaveDays'],
      deduction: (json['deduction'] ?? 0).toDouble(),
      netSalary: (json['netSalary'] ?? 0).toDouble(),
    );
  }
}
