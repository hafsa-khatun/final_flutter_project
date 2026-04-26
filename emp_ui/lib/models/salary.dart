class SalaryModel {
  final int? id;
  final int? employeeId;
  final String salaryCode;
  final String name;
  final String phone;
  final double basicSalary;
  final double houseRent;
  final double medical;
  final double transport;
  final double overTimeRate;
  final double overTimeHour;
  final double grossSalary;
  final String bankName;

  SalaryModel({
    this.id,
    this.employeeId,
    required this.salaryCode,
    required this.name,
    required this.phone,
    required this.basicSalary,
    required this.houseRent,
    required this.medical,
    required this.transport,
    required this.overTimeRate,
    required this.overTimeHour,
    required this.grossSalary,
    required this.bankName,
  });

  factory SalaryModel.fromJson(Map<String, dynamic> json) {
    return SalaryModel(
      id: json['id'],
      employeeId: json['employee'] != null ? json['employee']['id'] : (json['employeeId'] ?? json['employee_id']),
      salaryCode: json['salaryCode'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      basicSalary: (json['basicSalary'] as num?)?.toDouble() ?? 0.0,
      houseRent: (json['houseRent'] as num?)?.toDouble() ?? 0.0,
      medical: (json['medical'] as num?)?.toDouble() ?? 0.0,
      transport: (json['transport'] as num?)?.toDouble() ?? 0.0,
      overTimeRate: (json['overTimeRate'] as num?)?.toDouble() ?? 0.0,
      overTimeHour: (json['overTimeHour'] as num?)?.toDouble() ?? 0.0,
      grossSalary: (json['grossSalary'] as num?)?.toDouble() ?? 0.0,
      bankName: json['bankName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "salaryCode": salaryCode,
      "name": name,
      "phone": phone,
      "basicSalary": basicSalary,
      "houseRent": houseRent,
      "medical": medical,
      "transport": transport,
      "overTimeRate": overTimeRate,
      "overTimeHour": overTimeHour,
      "grossSalary": grossSalary,
      "bankName": bankName,
    
      "employeeId": employeeId,
      "employee_id": employeeId,
      "employee": {"id": employeeId},
    };

    if (id != null) {
      data["id"] = id;
    }

    return data;
  }
}