class LeaveModel {
  final int? id;
  final String leaveType;
  final String startDate;
  final String endDate;
  final String status;
  final int registrationId;

  LeaveModel({
    this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.registrationId,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'],
      leaveType: json['leaveType'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      status: json['status'],
      registrationId: json['registration']['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "leaveType": leaveType,
      "startDate": startDate,
      "endDate": endDate,
      "status": status,
      "registration": {
        "id": registrationId
      }
    };
  }
}
