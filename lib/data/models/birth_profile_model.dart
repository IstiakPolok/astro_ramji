import 'location_model.dart';

class BirthProfileModel {
  final String? id;
  final String name;
  final String dateOfBirth; // YYYY-MM-DD
  final String timeOfBirth; // HH:MM:SS
  final String? placeId;
  final LocationModel? locationDetails;
  final String? gender;
  final String? relationshipToUser;
  final String? notes;
  final String? ayanamsaOverride;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BirthProfileModel({
    this.id,
    required this.name,
    required this.dateOfBirth,
    required this.timeOfBirth,
    this.placeId,
    this.locationDetails,
    this.gender,
    this.relationshipToUser,
    this.notes,
    this.ayanamsaOverride,
    this.createdAt,
    this.updatedAt,
  });

  factory BirthProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return BirthProfileModel(
      id: data['id']?.toString(),
      name: data['name']?.toString() ?? '',
      dateOfBirth: data['date_of_birth']?.toString() ?? '',
      timeOfBirth: data['time_of_birth']?.toString() ?? '',
      placeId: data['place_id']?.toString(),
      locationDetails: data['location_details'] != null
          ? LocationModel.fromJson(data['location_details'] as Map<String, dynamic>)
          : null,
      gender: data['gender']?.toString(),
      relationshipToUser: data['relationship_to_user']?.toString(),
      notes: data['notes']?.toString(),
      ayanamsaOverride: data['ayanamsa_override']?.toString(),
      createdAt: data['created_at'] != null ? DateTime.tryParse(data['created_at'].toString()) : null,
      updatedAt: data['updated_at'] != null ? DateTime.tryParse(data['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson({bool forCreation = false}) {
    final map = <String, dynamic>{
      'name': name,
      'date_of_birth': dateOfBirth,
      'time_of_birth': timeOfBirth,
      if (placeId != null) 'place_id': placeId,
      if (gender != null) 'gender': gender,
      if (relationshipToUser != null) 'relationship_to_user': relationshipToUser,
      if (notes != null) 'notes': notes,
      if (ayanamsaOverride != null) 'ayanamsa_override': ayanamsaOverride,
    };

    if (!forCreation) {
      if (id != null) map['id'] = id;
      if (locationDetails != null) map['location_details'] = locationDetails!.toJson();
      if (createdAt != null) map['created_at'] = createdAt!.toIso8601String();
      if (updatedAt != null) map['updated_at'] = updatedAt!.toIso8601String();
    }

    return map;
  }
}

class PaginatedBirthProfileList {
  final int count;
  final String? next;
  final String? previous;
  final List<BirthProfileModel> results;

  const PaginatedBirthProfileList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedBirthProfileList.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final list = data['results'] as List<dynamic>? ??
        (json['data'] is List ? json['data'] as List : []);
    return PaginatedBirthProfileList(
      count: data['count'] is int
          ? data['count'] as int
          : (int.tryParse(data['count']?.toString() ?? '0') ?? list.length),
      next: data['next']?.toString(),
      previous: data['previous']?.toString(),
      results: list
          .map((item) => BirthProfileModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RawBirthData {
  final String name;
  final String dateOfBirth; // YYYY-MM-DD
  final String timeOfBirth; // HH:MM:SS
  final double latitude;
  final double longitude;
  final String timezone;
  final String? gender;

  const RawBirthData({
    this.name = 'Unknown',
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    this.gender,
  });

  factory RawBirthData.fromJson(Map<String, dynamic> json) {
    double parseCoordinate(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return RawBirthData(
      name: json['name']?.toString() ?? 'Unknown',
      dateOfBirth: json['date_of_birth']?.toString() ?? '',
      timeOfBirth: json['time_of_birth']?.toString() ?? '',
      latitude: parseCoordinate(json['latitude']),
      longitude: parseCoordinate(json['longitude']),
      timezone: json['timezone']?.toString() ?? 'Asia/Kolkata',
      gender: json['gender']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date_of_birth': dateOfBirth,
      'time_of_birth': timeOfBirth,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      if (gender != null) 'gender': gender,
    };
  }
}
