class AvailabilitySlot {
  final int id;
  final int doctorId;
  final DateTime startTime;
  final DateTime endTime;
  final bool isBooked;

  AvailabilitySlot({
    required this.id,
    required this.doctorId,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      doctorId: json['doctorId'] is int ? json['doctorId'] : int.parse(json['doctorId'].toString()),
      startTime: DateTime.parse(json['startTime'] as String).toLocal(),
      endTime: DateTime.parse(json['endTime'] as String).toLocal(),
      isBooked: json['isBooked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
      'isBooked': isBooked,
    };
  }
}
