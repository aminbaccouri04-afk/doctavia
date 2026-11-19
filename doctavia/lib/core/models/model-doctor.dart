import 'model-availability-slot.dart';
import 'model-offering.dart';

class DoctorModel {
  final int id;
  final String fullName;
  final List<String> specialties;
  final double rating;
  final int reviewsCount;
  final String? bio;
  final String? avatarUrl;
  final List<AvailabilitySlot> openSlots;
  final List<Offering> offerings;
  final double? latitude;
  final double? longitude;

  DoctorModel({
    required this.id,
    required this.fullName,
    required this.specialties,
    required this.rating,
    required this.reviewsCount,
    this.bio,
    this.avatarUrl,
    this.openSlots = const [],
    this.offerings = const [],
    this.latitude,
    this.longitude,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    // Determine specialties from 'categories' (list of objects) or 'specialties' (list of objects)
    var rawSpec = json['categories'] ?? json['specialties'] ?? [];
    
    final List<dynamic> specList = rawSpec is List ? rawSpec : [];
    
    // Extract names from list of objects
    final List<String> specialtyNames = specList.map((x) {
      if (x is Map) return x['name']?.toString() ?? '';
      return x.toString();
    }).where((s) => s.isNotEmpty).toList();
    
    // Parse nested slots if returning from detail view
    final List<dynamic> rawSlots = json['schedule'] ?? [];

    // rating might be parsed as double or int 
    final ratingVal = json['avgRating'] ?? json['rating'];
    final double rating = ratingVal == null ? 0.0 : double.parse(ratingVal.toString());
    
    final int reviewsCount = int.tryParse(json['reviewCount']?.toString() ?? '0') ?? 0;
    
    // Parse nested fullName and avatarUrl from the User's primary profile
    // Note: Sequelize usually capitalizes the model name in joins (e.g. 'User')
    String? parsedName = json['fullName'] as String?;
    String? parsedAvatar = json['avatarUrl'] as String?;

    if (parsedName == null || parsedAvatar == null) {
      final userData = json['User'] ?? json['user'];
      if (userData != null) {
        final profiles = userData['profiles'];
        if (profiles != null && profiles is List && profiles.isNotEmpty) {
          parsedName ??= profiles[0]['fullName'] as String?;
          parsedAvatar ??= profiles[0]['avatarUrl'] as String?;
        }
        parsedName ??= userData['fullName'] as String?;
        parsedAvatar ??= userData['avatarUrl'] as String?;
      }
    }
    
    // Geolocation parsing (Check root first, then nested offices)
    double? lat = json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null;
    double? lng = json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null;

    if (lat == null || lng == null) {
      final List<dynamic> offices = json['offices'] ?? [];
      if (offices.isNotEmpty) {
        final firstOffice = offices[0];
        lat ??= double.tryParse(firstOffice['latitude']?.toString() ?? '');
        lng ??= double.tryParse(firstOffice['longitude']?.toString() ?? '');
      }
    }

    // Parse nested offerings
    final List<dynamic> rawOfferings = json['offerings'] ?? json['services'] ?? [];

    return DoctorModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      fullName: parsedName ?? 'Unknown Provider',
      specialties: specialtyNames,
      rating: rating,
      reviewsCount: reviewsCount,
      bio: json['bio'] as String?,
      avatarUrl: parsedAvatar,
      openSlots: rawSlots.map((s) => AvailabilitySlot.fromJson(s)).toList(),
      offerings: rawOfferings.map((s) => Offering.fromJson(s)).toList(),
      latitude: lat,
      longitude: lng,
    );
  }

  DoctorModel copyWith({
    int? id,
    String? fullName,
    List<String>? specialties,
    double? rating,
    int? reviewsCount,
    String? bio,
    String? avatarUrl,
    List<AvailabilitySlot>? openSlots,
    List<Offering>? offerings,
    double? latitude,
    double? longitude,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      specialties: specialties ?? this.specialties,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      openSlots: openSlots ?? this.openSlots,
      offerings: offerings ?? this.offerings,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
