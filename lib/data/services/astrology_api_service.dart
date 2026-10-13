import 'dart:typed_data';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/location_model.dart';
import '../models/birth_profile_model.dart';
import '../models/match_model.dart';
import '../models/today_panchang_model.dart';
import '../models/horoscope_model.dart';

class AstrologyApiService {
  final ApiClient _client;

  AstrologyApiService({ApiClient? client}) : _client = client ?? ApiClient();

  ApiClient get client => _client;

  /// Search locations for autocomplete
  Future<List<LocationSearchResult>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await _client.get(
        ApiEndpoints.locationsSearch,
        queryParameters: {'q': query.trim()},
      );

      if (response is List) {
        return response
            .map((item) => LocationSearchResult.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic>) {
        // Can be wrapped in results or predictions
        final list = response['results'] ?? response['predictions'] ?? response['data'];
        if (list is List) {
          return list
              .map((item) => LocationSearchResult.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      // Return empty list on network or parse failure for smooth autocomplete UX
      return [];
    }
  }

  /// Get detailed coordinates & timezone for a selected Google Place ID
  Future<LocationModel?> getLocationDetails(String placeId) async {
    try {
      final response = await _client.get(
        ApiEndpoints.locationsDetails,
        queryParameters: {'place_id': placeId},
      );

      if (response is Map<String, dynamic>) {
        final data = response['result'] ?? response['data'] ?? response;
        if (data is Map<String, dynamic>) {
          return LocationModel.fromJson(data);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// List paginated birth profiles
  Future<PaginatedBirthProfileList> getBirthProfiles({
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _client.get(
      ApiEndpoints.birthProfiles,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );

    if (response is Map<String, dynamic>) {
      return PaginatedBirthProfileList.fromJson(response);
    }
    return const PaginatedBirthProfileList(count: 0, results: []);
  }

  /// Create a new birth profile
  Future<BirthProfileModel> createBirthProfile(BirthProfileModel profile) async {
    final response = await _client.post(
      ApiEndpoints.birthProfiles,
      body: profile.toJson(forCreation: true),
    );

    if (response is Map<String, dynamic>) {
      return BirthProfileModel.fromJson(response);
    }
    throw ApiException(statusCode: 500, message: 'Invalid server response');
  }

  /// Retrieve a specific birth profile by ID
  Future<BirthProfileModel> getBirthProfile(String id) async {
    final response = await _client.get(ApiEndpoints.birthProfile(id));
    if (response is Map<String, dynamic>) {
      return BirthProfileModel.fromJson(response);
    }
    throw ApiException(statusCode: 404, message: 'Birth profile not found');
  }

  /// Update a birth profile
  Future<BirthProfileModel> updateBirthProfile(
    String id,
    BirthProfileModel profile,
  ) async {
    final response = await _client.put(
      ApiEndpoints.birthProfile(id),
      body: profile.toJson(forCreation: false),
    );
    if (response is Map<String, dynamic>) {
      return BirthProfileModel.fromJson(response);
    }
    throw ApiException(statusCode: 500, message: 'Failed to update profile');
  }

  /// Delete a birth profile
  Future<bool> deleteBirthProfile(String id) async {
    await _client.delete(ApiEndpoints.birthProfile(id));
    return true;
  }

  /// Retrieve Kundali chart and astrological data for a birth profile
  Future<Map<String, dynamic>> getKundali(String profileId) async {
    final response = await _client.get(ApiEndpoints.birthProfileKundali(profileId));
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
      return response;
    }
    return {};
  }

  /// Get direct PDF download link for a birth profile report
  String getKundaliPdfUrl(String profileId) {
    return '${_client.baseUrl}${ApiEndpoints.birthProfilePdf(profileId)}';
  }

  /// Download Kundali report PDF bytes for a birth profile
  Future<Uint8List> downloadKundaliPdf(String profileId) async {
    return await _client.getBytes(ApiEndpoints.birthProfilePdf(profileId));
  }

  /// Match two kundalis (using profile IDs or raw birth data)
  Future<MatchResultModel> matchKundali(MatchMakingRequest request) async {
    final response = await _client.post(
      ApiEndpoints.match,
      body: request.toJson(),
    );

    if (response is Map<String, dynamic>) {
      return MatchResultModel.fromJson(response);
    }
    throw ApiException(statusCode: 500, message: 'Invalid matching response format');
  }

  /// Get Today's astrological & panchang forecast
  Future<TodayPanchangModel> getTodayAstrology({
    double? latitude,
    double? longitude,
    String? timezone,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (latitude != null) queryParams['lat'] = latitude;
      if (longitude != null) queryParams['lon'] = longitude;
      if (timezone != null && timezone.isNotEmpty) queryParams['tz'] = timezone;

      final response = await _client.get(
        ApiEndpoints.today,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response is Map<String, dynamic>) {
        return TodayPanchangModel.fromJson(response);
      }
    } catch (_) {
      // Graceful offline fallback when backend is unreachable or network is unavailable
      return TodayPanchangModel.fromJson({});
    }
    // Fallback default
    return TodayPanchangModel.fromJson({});
  }

  /// Retrieve all 12 Zodiac signs from the API
  Future<List<ZodiacSignModel>> getHoroscopeSigns() async {
    try {
      final response = await _client.get(ApiEndpoints.horoscopeSigns);
      if (response is List) {
        return response
            .map((item) => ZodiacSignModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response is Map<String, dynamic>) {
        final list = response['data'] ?? response['results'];
        if (list is List) {
          return list
              .map((item) => ZodiacSignModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return ZodiacSignModel.defaultSigns;
    } catch (_) {
      // Graceful offline fallback to predefined astrological signs
      return ZodiacSignModel.defaultSigns;
    }
  }

  /// Retrieve horoscope predictions for a specific zodiac sign and timeframe
  /// [periodType] must be 'daily', 'monthly', or 'yearly'
  Future<HoroscopeModel> getHoroscope({
    required String zodiac,
    required String periodType,
  }) async {
    final cleanZodiac = zodiac.toLowerCase().trim();
    final cleanPeriod = periodType.toLowerCase().trim();

    final endpoint = cleanPeriod == 'monthly'
        ? ApiEndpoints.horoscopeMonthly(cleanZodiac)
        : (cleanPeriod == 'yearly'
            ? ApiEndpoints.horoscopeYearly(cleanZodiac)
            : ApiEndpoints.horoscopeDaily(cleanZodiac));

    final response = await _client.get(endpoint);
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      if (data is Map<String, dynamic>) {
        return HoroscopeModel.fromJson(data);
      }
    }
    throw ApiException(statusCode: 500, message: 'Invalid horoscope response format');
  }
}

