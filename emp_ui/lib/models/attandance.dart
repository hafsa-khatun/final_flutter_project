class AttendanceModel {
  final int? id;
  final String employeeCode;
  final String employeeName;
  final String date;
  final String inTime;
  final String outTime;
  final String status; // PRESENT, ABSENT, LATE

  AttendanceModel({
    this.id,
    required this.employeeCode,
    required this.employeeName,
    required this.date,
    required this.inTime,
    required this.outTime,
    required this.status,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      employeeCode: json['employeeCode'],
      employeeName: json['employeeName'],
      date: json['date'],
      inTime: json['inTime'],
      outTime: json['outTime'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "employeeCode": employeeCode,
      "employeeName": employeeName,
      "date": date,
      "inTime": inTime,
      "outTime": outTime,
      "status": status,
    };
  }
}
