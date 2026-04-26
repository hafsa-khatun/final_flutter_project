class ProjectModel {
  final int? id;
  final String projectName;
  final String projectCode;
  final String description;
  final String startDate;
  final String endDate;
  final double budget;
  final String status;
  final String clientName;
  final String priority; 

  ProjectModel({
    this.id,
    required this.projectName,
    required this.projectCode,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.status,
    required this.clientName,
    required this.priority,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['projectId'],
      projectName: json['projectName'],
      projectCode: json['projectCode'],
      description: json['description'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      budget: (json['budget'] as num).toDouble(),
      status: json['status'],
      clientName: json['clientName'],
      priority: json['priority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "projectId": id,
      "projectName": projectName,
      "projectCode": projectCode,
      "description": description,
      "startDate": startDate,
      "endDate": endDate,
      "budget": budget,
      "status": status,
      "clientName": clientName,
      "priority": priority,
    };
  }
}
