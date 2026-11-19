import 'package:intl/intl.dart';

class HealthMetric {
  final int id;
  final int profileId;
  final String type; // e.g., 'Blood Glucose', 'Blood Pressure (Sys)', 'Weight'
  final double value;
  final String unit;
  final DateTime updatedAt;

  HealthMetric({
    required this.id,
    required this.profileId,
    required this.type,
    required this.value,
    required this.unit,
    required this.updatedAt,
  });

  factory HealthMetric.fromJson(Map<String, dynamic> json) {
    return HealthMetric(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      profileId: json['profile_id'] is int ? json['profile_id'] : int.parse(json['profile_id'].toString()),
      type: json['type'],
      value: (json['value'] as num).toDouble(),
      unit: json['unit'],
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  String get formattedValue => '$value $unit';
  String get formattedDate => DateFormat.yMMMd().format(updatedAt);
}
