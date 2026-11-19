import 'dart:convert';
import 'package:flutter/material.dart';

/// Represents a single medicine reminder with scheduled dose times.
class MedicineReminder {
  final int id;
  final String medicationName;
  final String dosage;
  final String frequency;
  final List<TimeOfDay> times;
  final bool isActive;
  final DateTime createdAt;

  MedicineReminder({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.times,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  MedicineReminder copyWith({
    int? id,
    String? medicationName,
    String? dosage,
    String? frequency,
    List<TimeOfDay>? times,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return MedicineReminder(
      id: id ?? this.id,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'times': times.map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}').toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicineReminder.fromJson(Map<String, dynamic> json) {
    return MedicineReminder(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      medicationName: json['medicationName'] as String,
      dosage: json['dosage'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      times: (json['times'] as List<dynamic>).map((t) {
        if (t is Map<String, dynamic>) {
           return TimeOfDay(hour: t['hour'] as int, minute: t['minute'] as int);
        }
        final parts = (t as String).split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }).toList(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] as String),
    );
  }

  /// Encode the full list to a JSON string for SharedPreferences storage.
  static String encodeList(List<MedicineReminder> reminders) {
    return jsonEncode(reminders.map((r) => r.toJson()).toList());
  }

  /// Decode a JSON string back into a list of reminders.
  static List<MedicineReminder> decodeList(String jsonString) {
    final List<dynamic> data = jsonDecode(jsonString);
    return data.map((j) => MedicineReminder.fromJson(j as Map<String, dynamic>)).toList();
  }
}
