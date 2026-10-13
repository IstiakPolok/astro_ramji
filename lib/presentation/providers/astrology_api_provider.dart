import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../data/models/location_model.dart';
import '../../data/models/birth_profile_model.dart';
import '../../data/models/match_model.dart';
import '../../data/models/today_panchang_model.dart';
import '../../data/models/horoscope_model.dart';
import '../../data/services/astrology_api_service.dart';

class AstrologyApiProvider extends ChangeNotifier {
  final AstrologyApiService _apiService;

  AstrologyApiProvider({AstrologyApiService? apiService})
      : _apiService = apiService ?? AstrologyApiService();

  String get baseUrl => _apiService.client.baseUrl;

  Future<void> setBaseUrl(String url) async {
    await _apiService.client.setBaseUrl(url);
    notifyListeners();
  }

  // --- Location Autocomplete State ---
  List<LocationSearchResult> _locationResults = [];
  bool _isSearchingLocations = false;
  Timer? _debounceTimer;

  List<LocationSearchResult> get locationResults => _locationResults;
  bool get isSearchingLocations => _isSearchingLocations;

  void searchLocations(String query) {
    _debounceTimer?.cancel();
    if (query.trim().length < 2) {
      _locationResults = [];
      _isSearchingLocations = false;
      notifyListeners();
      return;
    }

    _isSearchingLocations = true;
    notifyListeners();

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      final results = await _apiService.searchLocations(query);
      _locationResults = results;
      _isSearchingLocations = false;
      notifyListeners();
    });
  }

  Future<List<LocationSearchResult>> searchLocationsDirect(String query) async {
    return await _apiService.searchLocations(query);
  }

  void clearLocationSearch() {
    _debounceTimer?.cancel();
    _locationResults = [];
    _isSearchingLocations = false;
    notifyListeners();
  }

  Future<LocationModel?> getLocationDetails(String placeId) async {
    return await _apiService.getLocationDetails(placeId);
  }

  // --- Birth Profile & Kundali Calculation State ---
  bool _isGeneratingKundali = false;
  String? _kundaliError;
  BirthProfileModel? _activeProfile;
  Map<String, dynamic>? _activeKundaliData;

  bool get isGeneratingKundali => _isGeneratingKundali;
  String? get kundaliError => _kundaliError;
  BirthProfileModel? get activeProfile => _activeProfile;
  Map<String, dynamic>? get activeKundaliData => _activeKundaliData;

  Future<bool> generateKundali({
    required String name,
    required String dateOfBirth, // YYYY-MM-DD
    required String timeOfBirth, // HH:MM:SS
    required String placeId,
    required String gender,
    String? ayanamsa,
    String? notes,
  }) async {
    _isGeneratingKundali = true;
    _kundaliError = null;
    notifyListeners();

    try {
      final profile = BirthProfileModel(
        name: name,
        dateOfBirth: dateOfBirth,
        timeOfBirth: timeOfBirth,
        placeId: placeId,
        gender: gender,
        ayanamsaOverride: ayanamsa,
        notes: notes,
      );

      final createdProfile = await _apiService.createBirthProfile(profile);
      _activeProfile = createdProfile;

      if (createdProfile.id != null) {
        final kundaliData = await _apiService.getKundali(createdProfile.id!);
        _activeKundaliData = kundaliData;
      }

      _isGeneratingKundali = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error generating kundali via API: $e');
      _kundaliError = e.toString();
      _isGeneratingKundali = false;
      notifyListeners();
      return false;
    }
  }

  String getKundaliPdfUrl(String profileId) {
    return _apiService.getKundaliPdfUrl(profileId);
  }

  /// Download Kundali PDF binary bytes directly from API
  Future<Uint8List?> downloadKundaliPdf(String profileId) async {
    try {
      return await _apiService.downloadKundaliPdf(profileId);
    } catch (e) {
      debugPrint('Error downloading Kundali PDF in provider: $e');
      rethrow;
    }
  }

  // --- Kundali Match Making State ---
  bool _isMatching = false;
  String? _matchError;
  MatchResultModel? _matchResult;

  bool get isMatching => _isMatching;
  String? get matchError => _matchError;
  MatchResultModel? get matchResult => _matchResult;

  Future<bool> matchProfiles({
    required RawBirthData boyData,
    required RawBirthData girlData,
  }) async {
    _isMatching = true;
    _matchError = null;
    notifyListeners();

    try {
      final request = MatchMakingRequest(
        profile1Data: boyData,
        profile2Data: girlData,
      );

      final result = await _apiService.matchKundali(request);
      _matchResult = result;
      _isMatching = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error matching kundalis via API: $e');
      _matchError = e.toString();
      _isMatching = false;
      notifyListeners();
      return false;
    }
  }

  // --- Today's Panchang / Forecast State ---
  TodayPanchangModel? _todayPanchang;
  bool _isLoadingToday = false;

  TodayPanchangModel? get todayPanchang => _todayPanchang;
  bool get isLoadingToday => _isLoadingToday;

  Future<void> fetchTodayPanchang({
    double? latitude,
    double? longitude,
    String? timezone,
  }) async {
    _isLoadingToday = true;
    notifyListeners();

    try {
      final data = await _apiService.getTodayAstrology(
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      _todayPanchang = data;
    } catch (_) {
      _todayPanchang = TodayPanchangModel.fromJson({});
    } finally {
      _isLoadingToday = false;
      notifyListeners();
    }
  }

  // --- Horoscope State ---
  List<ZodiacSignModel> _zodiacSigns = ZodiacSignModel.defaultSigns;
  bool _isLoadingSigns = false;
  final Map<String, HoroscopeModel> _horoscopeCache = {};
  bool _isLoadingHoroscope = false;
  String? _horoscopeError;
  HoroscopeModel? _currentHoroscope;

  List<ZodiacSignModel> get zodiacSigns => _zodiacSigns;
  bool get isLoadingSigns => _isLoadingSigns;
  bool get isLoadingHoroscope => _isLoadingHoroscope;
  String? get horoscopeError => _horoscopeError;
  HoroscopeModel? get currentHoroscope => _currentHoroscope;

  Future<void> fetchHoroscopeSigns() async {
    _isLoadingSigns = true;
    notifyListeners();
    try {
      final signs = await _apiService.getHoroscopeSigns();
      if (signs.isNotEmpty) {
        _zodiacSigns = signs;
      }
    } catch (e) {
      debugPrint('Error fetching zodiac signs: $e');
    } finally {
      _isLoadingSigns = false;
      notifyListeners();
    }
  }

  Future<HoroscopeModel?> fetchHoroscope({
    required String zodiac,
    required String periodType,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${zodiac.toLowerCase()}_${periodType.toLowerCase()}';
    if (!forceRefresh && _horoscopeCache.containsKey(cacheKey)) {
      _currentHoroscope = _horoscopeCache[cacheKey];
      _horoscopeError = null;
      notifyListeners();
      return _currentHoroscope;
    }

    _isLoadingHoroscope = true;
    _horoscopeError = null;
    notifyListeners();

    try {
      final horoscope = await _apiService.getHoroscope(
        zodiac: zodiac,
        periodType: periodType,
      );
      _horoscopeCache[cacheKey] = horoscope;
      _currentHoroscope = horoscope;
      _isLoadingHoroscope = false;
      notifyListeners();
      return horoscope;
    } catch (e) {
      debugPrint('Error fetching horoscope: $e');
      _horoscopeError = e.toString();
      _isLoadingHoroscope = false;
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
