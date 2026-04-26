class TrainingModel {
  final int? id;
  final String trainingTitle;
  final String trainerName;
  final String description;
  final String startDate;
  final String endDate;
  final String location;
  final String certificateNumber;
  final String issueDate;
  final String grade;

  TrainingModel({
    this.id,
    required this.trainingTitle,
    required this.trainerName,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.certificateNumber,
    required this.issueDate,
    required this.grade,
  });

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id'],
      trainingTitle: json['trainingTitle'] ?? '',
      trainerName: json['trainerName'] ?? '',
      description: json['description'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      location: json['location'] ?? '',
      certificateNumber: json['certificateNumber'] ?? '',
      issueDate: json['issueDate'] ?? '',
      grade: json['grade'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "trainingTitle": trainingTitle,
      "trainerName": trainerName,
      "description": description,
      "startDate": startDate,
      "endDate": endDate,
      "location": location,
      "certificateNumber": certificateNumber,
      "issueDate": issueDate,
      "grade": grade,
    };
  }
}
