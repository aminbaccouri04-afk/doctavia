class Specialty {
  final int id;
  final String name;
  final String? icon;

  Specialty({
    required this.id,
    required this.name,
    this.icon,
  });

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] as String,
      icon: json['icon'] as String?,
    );
  }
}
