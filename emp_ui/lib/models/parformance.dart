class PerformanceModel {
  final int? id;
  final int employeeId;
  final double performanceRatting;
  final double kpiScore;
  final String annualReview;
  final bool promotion;

  PerformanceModel({
    this.id,
    required this.employeeId,
    required this.performanceRatting,
    required this.kpiScore,
    required this.annualReview,
    required this.promotion,
  });

  factory PerformanceModel.fromJson(Map<String, dynamic> json) {
    return PerformanceModel(
      id: json['id'],
      employeeId: json['employeeId'],
      performanceRatting: (json['performanceRatting'] ?? 0).toDouble(),
      kpiScore: (json['kpiScore'] ?? 0).toDouble(),
      annualReview: json['annualReview'] ?? '',
      promotion: json['promotion'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "employeeId": employeeId,
      "performanceRatting": performanceRatting,
      "kpiScore": kpiScore,
      "annualReview": annualReview,
      "promotion": promotion,
    };
  }
}
