class EmployeeModel {
  final int? id;
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String employeeType;
  final double salary;
  final String status;
  final int departmentId;
  final String? departmentName;
  final int designationId;
  final String? designationName;
  final String? dateOfJoining;

  EmployeeModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.employeeType,
    required this.salary,
    this.status = 'ACTIVE',
    required this.departmentId,
    this.departmentName,
    required this.designationId,
    this.designationName,
    this.dateOfJoining,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      employeeType: json['employeeType'],
      salary: (json['salary'] as num).toDouble(),
      status: json['status'] ?? 'ACTIVE',
      departmentId: json['department'] != null ? json['department']['id'] : 0,
      departmentName: json['department'] != null ? json['department']['name'] : null,
      designationId: json['designation'] != null ? json['designation']['id'] : 0,
      designationName: json['designation'] != null ? json['designation']['name'] : null,
      dateOfJoining: json['dateOfJoining'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullName": fullName,
      "email": email,
      "phone": phone,
      "gender": gender,
      "employeeType": employeeType,
      "salary": salary,
      "status": status,
      "department": {"id": departmentId},
      "designation": {"id": designationId},
    };
  }
}
