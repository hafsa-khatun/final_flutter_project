class DocumentModel {
  final int id;
  final String fileName;
  final String documentType;

  DocumentModel({
    required this.id,
    required this.fileName,
    required this.documentType,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      fileName: json['fileName'],
      documentType: json['documentType'],
    );
  }
}
