class ConsultationNoteModel {
  final int id;
  final int appointmentId;
  final String? patientSummary;
  final String? internalNotes;
  final DateTime createdAt;

  ConsultationNoteModel({
    required this.id,
    required this.appointmentId,
    this.patientSummary,
    this.internalNotes,
    required this.createdAt,
  });

  factory ConsultationNoteModel.fromJson(Map<String, dynamic> json) {
    return ConsultationNoteModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      appointmentId: json['appointmentId'] is int ? json['appointmentId'] : int.parse(json['appointmentId'].toString()),
      patientSummary: json['patientSummary'] as String?,
      internalNotes: json['internalNotes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
