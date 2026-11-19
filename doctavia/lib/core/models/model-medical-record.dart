class MedicalRecord {
  final int id;
  final int patientProfileId;
  final String fileName;
  final String fileType;
  final int fileSize;
  final String fileUrl;
  final DateTime uploadedAt;

  MedicalRecord({
    required this.id,
    required this.patientProfileId,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.fileUrl,
    required this.uploadedAt,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      patientProfileId: json['patientProfileId'] is int ? json['patientProfileId'] : int.parse(json['patientProfileId'].toString()),
      fileName: json['fileName'] as String,
      fileType: json['fileType'] as String,
      fileSize: json['fileSize'] as int,
      fileUrl: json['fileUrl'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientProfileId': patientProfileId,
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'fileUrl': fileUrl,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  MedicalRecord copyWith({
    int? id,
    int? patientProfileId,
    String? fileName,
    String? fileType,
    int? fileSize,
    String? fileUrl,
    DateTime? uploadedAt,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      patientProfileId: patientProfileId ?? this.patientProfileId,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      fileUrl: fileUrl ?? this.fileUrl,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}
