class DesignationModel {
  final int? id;
  final String name;
  final int departmentId;

  DesignationModel({
    this.id,
    required this.name,
    required this.departmentId,
  });

  factory DesignationModel.fromJson(Map<String, dynamic> json) {
    return DesignationModel(
      id: json['id'],
      name: json['name'],
      departmentId: json['department'] != null
          ? json['department']['id']
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "department": {
        "id": departmentId
      }
    };
  }
}
