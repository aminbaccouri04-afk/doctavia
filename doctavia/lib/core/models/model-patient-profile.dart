class PatientProfile {
  final int id;
  final int accountId;
  final String fullName;
  final String relationship;
  final String dateOfBirth;
  final String? avatarUrl;

  PatientProfile({
    required this.id,
    required this.accountId,
    required this.fullName,
    required this.relationship,
    required this.dateOfBirth,
    this.avatarUrl,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    // The date format comes back usually as an ISO string
    // Pull just the YYYY-MM-DD
    final fullDate = json['dateOfBirth'] as String? ?? '';
    final formattedDob = fullDate.length >= 10 ? fullDate.substring(0, 10) : fullDate;

    return PatientProfile(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      accountId: json['accountId'] is int ? json['accountId'] : int.parse(json['accountId'].toString()),
      fullName: json['fullName'] as String,
      relationship: json['relationship'] as String,
      dateOfBirth: formattedDob,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  PatientProfile copyWith({
    int? id,
    int? accountId,
    String? fullName,
    String? relationship,
    String? dateOfBirth,
    String? avatarUrl,
  }) {
    return PatientProfile(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      fullName: fullName ?? this.fullName,
      relationship: relationship ?? this.relationship,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
