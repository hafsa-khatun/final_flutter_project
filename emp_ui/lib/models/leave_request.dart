class LeaveRequestModel {
  final int? id;
  final int? employeeId; // 🔹 নতুন ফিল্ড
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
      // 🔹 ব্যাকএন্ডের এমপ্লয়ী অবজেক্ট থেকে আইডি ও নাম নেওয়া
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
      // 🔹 ম্যানুয়াল নামের বদলে ব্যাকএন্ডে এমপ্লয়ী আইডি পাঠানো
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
