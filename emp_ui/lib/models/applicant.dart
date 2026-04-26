class ApplicantModel {
  final int? id;
  final String fullName;
  final String email;
  final String phone;
  final String status; // APPLIED, INTERVIEW_SCHEDULED, SELECTED, REJECTED

  ApplicantModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.status,
  });

  factory ApplicantModel.fromJson(Map<String, dynamic> json) {
    return ApplicantModel(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullName": fullName,
      "email": email,
      "phone": phone,
      "status": status,
    };
  }
}
