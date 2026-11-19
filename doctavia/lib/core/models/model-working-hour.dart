class WorkingHour {
  final int? id;
  final int doctorId;
  final int dayOfWeek; // 0-6
  final String? startTime; // "HH:mm"
  final String? endTime; // "HH:mm"
  final bool isClosed;

  WorkingHour({
    this.id,
    required this.doctorId,
    required this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.isClosed = false,
  });

  factory WorkingHour.fromJson(Map<String, dynamic> json) {
    return WorkingHour(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.parse(json['id'].toString()) : null),
      doctorId: json['doctorId'] is int ? json['doctorId'] : int.parse((json['doctorId'] ?? json['doctor_id']).toString()),
      dayOfWeek: json['dayOfWeek'] ?? json['day_of_week'],
      startTime: json['startTime'] ?? json['start_time'],
      endTime: json['endTime'] ?? json['end_time'],
      isClosed: json['isClosed'] ?? json['is_closed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'isClosed': isClosed,
    };
  }

  WorkingHour copyWith({
    int? id,
    int? doctorId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isClosed,
  }) {
    return WorkingHour(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isClosed: isClosed ?? this.isClosed,
    );
  }
}
