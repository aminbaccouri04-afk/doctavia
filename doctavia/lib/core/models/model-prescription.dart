class PrescriptionModel {
  final int id;
  final int appointmentId;
  final int doctorId;
  final int patientProfileId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String duration;
  final String? instructions;
  final String status;
  final DateTime createdAt;

  PrescriptionModel({
    required this.id,
    required this.appointmentId,
    required this.doctorId,
    required this.patientProfileId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
    required this.status,
    required this.createdAt,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      appointmentId: json['appointmentId'] is int ? json['appointmentId'] : int.parse(json['appointmentId'].toString()),
      doctorId: json['doctorId'] is int ? json['doctorId'] : int.parse(json['doctorId'].toString()),
      patientProfileId: json['patientProfileId'] is int ? json['patientProfileId'] : int.parse(json['patientProfileId'].toString()),
      medicationName: json['medicationName'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
      instructions: json['instructions'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  bool get isActive => status == 'active';
}
