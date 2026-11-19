import 'model-patient-profile.dart';

/// Data model for the authenticated user.
class UserModel {
  final int id;
  final String email;
  final String role;
  final List<PatientProfile> profiles;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.profiles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      email: json['email'] as String,
      role: json['role'] as String,
      profiles: (json['profiles'] as List<dynamic>?)
          ?.map((e) => PatientProfile.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  bool get isPatient   => role == 'patient';
  bool get isDoctor    => role == 'doctor';
  bool get isSecretary => role == 'secretary';
}
