class RegistrationModel {
  final int? id;
  final String name;
  final String phone;
  final String reason;

  RegistrationModel({
    this.id,
    required this.name,
    required this.phone,
    required this.reason,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "phone": phone,
      "reason": reason,
    };
  }
}
