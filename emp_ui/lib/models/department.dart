class DepartmentModel {
  final int? id;
  final String name;
  final String? createdDate;

  DepartmentModel({
    this.id,
    required this.name,
    this.createdDate,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'],
      name: json['name'],
      createdDate: json['createdDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
    };
  }
}
