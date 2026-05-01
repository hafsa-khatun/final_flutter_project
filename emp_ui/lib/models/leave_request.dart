class LeaveRequestModel {
  final int? id;
  final int? employeeId;
  final String employeeCode;
  final String employeeName;
  final String leaveType;
  final String startDate;
  final String endDate;
  final String reason;
  final String leaveProposal;
  final String status;

  LeaveRequestModel({
    this.id,
    this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.leaveProposal,
    required this.status,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id'],

      employeeId: json['employee'] != null ? json['employee']['id'] : null,
      employeeCode: json['employeeCode'] ?? '',
      employeeName: json['employeeName'] ?? 
                    (json['employee'] != null ? json['employee']['fullName'] : 'N/A'),
      leaveType: json['leaveType'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      reason: json['reason'] ?? '',
      leaveProposal: json['leaveProposal'] ?? '',
      status: json['status'] ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,

      "employee": employeeId != null ? {"id": employeeId} : null,
      "employeeCode": employeeCode,
      "employeeName": employeeName,
      "leaveType": leaveType,
      "startDate": startDate,
      "endDate": endDate,
      "reason": reason,
      "leaveProposal": leaveProposal,
      "status": status,
    };
  }
}
