class ConsultationNotes {
  final int id;
  final int appointmentId;
  final String patientSummary;
  final String internalNotes;
  final DateTime createdAt;

  ConsultationNotes({
    required this.id,
    required this.appointmentId,
    required this.patientSummary,
    required this.internalNotes,
    required this.createdAt,
  });

  factory ConsultationNotes.fromJson(Map<String, dynamic> json) {
    return ConsultationNotes(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      appointmentId: json['appointmentId'] is int ? json['appointmentId'] : int.parse(json['appointmentId'].toString()),
      patientSummary: json['patientSummary'] as String,
      internalNotes: json['internalNotes'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'patientSummary': patientSummary,
      'internalNotes': internalNotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
