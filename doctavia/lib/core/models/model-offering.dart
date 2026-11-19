class Offering {
  final int id;
  final int doctorId;
  final String name;
  final String? description;
  final double price;
  final int durationMinutes;

  Offering({
    required this.id,
    required this.doctorId,
    required this.name,
    this.description,
    required this.price,
    required this.durationMinutes,
  });

  factory Offering.fromJson(Map<String, dynamic> json) {
    return Offering(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      doctorId: json['doctorId'] is int ? json['doctorId'] : int.parse(json['doctorId'].toString()),
      name: json['name'] as String,
      description: json['description'] as String?,
      price: double.parse(json['price'].toString()),
      durationMinutes: json['durationMinutes'] as int? ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'name': name,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
    };
  }
}
