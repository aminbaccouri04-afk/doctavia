class Appointment {
  final int id;
  final int slotId;
  final String status;
  final DateTime startTimeSnapshot;
  final DateTime endTimeSnapshot;
  final int patientProfileId;
  final String? patientName; // Potentially joined from backend
  final int? doctorId;
  final String? doctorName;
  final String? doctorAvatarUrl;
  final String? patientAvatarUrl;

  final int? queuePosition;

  final int? offeringId;
  final String? offeringName;

  Appointment({
    required this.id,
    required this.slotId,
    required this.status,
    required this.startTimeSnapshot,
    required this.endTimeSnapshot,
    required this.patientProfileId,
    this.patientName,
    this.doctorId,
    this.doctorName,
    this.doctorAvatarUrl,
    this.patientAvatarUrl,
    this.queuePosition,
    this.offeringId,
    this.offeringName,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      slotId: json['slotId'] is int ? json['slotId'] : int.parse(json['slotId'].toString()),
      status: json['status'] as String,
      startTimeSnapshot: DateTime.parse(json['startTimeSnapshot'] as String).toLocal(),
      endTimeSnapshot: DateTime.parse(json['endTimeSnapshot'] as String).toLocal(),
      patientProfileId: json['patientProfileId'] is int ? json['patientProfileId'] : int.parse(json['patientProfileId'].toString()),
      patientName: json['patient']?['fullName'] as String?,
      doctorId: json['doctorId'] is int? ? json['doctorId'] : (json['doctorId'] != null ? int.parse(json['doctorId'].toString()) : null),
      doctorName: json['doctor']?['fullName'] as String?,
      doctorAvatarUrl: json['doctor']?['avatarUrl'] as String?,
      patientAvatarUrl: json['patient']?['avatarUrl'] as String?,
      queuePosition: json['queuePosition'] as int?,
      offeringId: json['offeringId'] is int? ? json['offeringId'] : (json['offeringId'] != null ? int.parse(json['offeringId'].toString()) : null),
      offeringName: json['offering']?['name'] as String?,
    );
  }

  Appointment copyWith({
    int? id,
    int? slotId,
    String? status,
    DateTime? startTimeSnapshot,
    DateTime? endTimeSnapshot,
    int? patientProfileId,
    String? patientName,
    int? doctorId,
    String? doctorName,
    String? doctorAvatarUrl,
    String? patientAvatarUrl,
    int? queuePosition,
    int? offeringId,
    String? offeringName,
  }) {
    return Appointment(
      id: id ?? this.id,
      slotId: slotId ?? this.slotId,
      status: status ?? this.status,
      startTimeSnapshot: startTimeSnapshot ?? this.startTimeSnapshot,
      endTimeSnapshot: endTimeSnapshot ?? this.endTimeSnapshot,
      patientProfileId: patientProfileId ?? this.patientProfileId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorAvatarUrl: doctorAvatarUrl ?? this.doctorAvatarUrl,
      patientAvatarUrl: patientAvatarUrl ?? this.patientAvatarUrl,
      queuePosition: queuePosition ?? this.queuePosition,
      offeringId: offeringId ?? this.offeringId,
      offeringName: offeringName ?? this.offeringName,
    );
  }
}
