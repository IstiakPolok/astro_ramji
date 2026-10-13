class LocationModel {
  final String id;
  final String? placeId;
  final String name;
  final double latitude;
  final double longitude;
  final String timezoneId;
  final String? country;
  final String? adminArea;

  const LocationModel({
    required this.id,
    this.placeId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timezoneId,
    this.country,
    this.adminArea,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    double parseCoordinate(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return LocationModel(
      id: data['id']?.toString() ?? data['place_id']?.toString() ?? '',
      placeId: data['place_id']?.toString(),
      name: data['name']?.toString() ?? '',
      latitude: parseCoordinate(data['latitude'] ?? data['lat']),
      longitude: parseCoordinate(data['longitude'] ?? data['lon'] ?? data['lng']),
      timezoneId: data['timezone_id']?.toString() ?? data['timezone']?.toString() ?? 'Asia/Kolkata',
      country: data['country']?.toString(),
      adminArea: data['admin_area']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (placeId != null) 'place_id': placeId,
      'name': name,
      'latitude': latitude.toStringAsFixed(6),
      'longitude': longitude.toStringAsFixed(6),
      'timezone_id': timezoneId,
      if (country != null) 'country': country,
      if (adminArea != null) 'admin_area': adminArea,
    };
  }
}

class LocationSearchResult {
  final String placeId;
  final String description;
  final String? mainText;
  final String? secondaryText;

  const LocationSearchResult({
    required this.placeId,
    required this.description,
    this.mainText,
    this.secondaryText,
  });

  factory LocationSearchResult.fromJson(Map<String, dynamic> json) {
    // Supports both direct place items and Google Places autocomplete payload formats
    final structured = json['structured_formatting'] as Map<String, dynamic>?;
    return LocationSearchResult(
      placeId: json['place_id']?.toString() ?? json['id']?.toString() ?? '',
      description: json['description']?.toString() ?? json['name']?.toString() ?? '',
      mainText: structured?['main_text']?.toString() ?? json['name']?.toString(),
      secondaryText: structured?['secondary_text']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'description': description,
      if (mainText != null) 'main_text': mainText,
      if (secondaryText != null) 'secondary_text': secondaryText,
    };
  }
}
