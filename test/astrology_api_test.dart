import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:astro_ramji/core/network/api_client.dart';
import 'package:astro_ramji/core/network/api_endpoints.dart';
import 'package:astro_ramji/data/models/location_model.dart';
import 'package:astro_ramji/data/models/birth_profile_model.dart';
import 'package:astro_ramji/data/models/match_model.dart';
import 'package:astro_ramji/data/models/today_panchang_model.dart';
import 'package:astro_ramji/data/models/horoscope_model.dart';
import 'package:astro_ramji/data/services/astrology_api_service.dart';
import 'package:astro_ramji/presentation/providers/astrology_api_provider.dart';

void main() {
  group('OpenAPI Endpoints', () {
    test('ApiEndpoints match OpenAPI 3.0.3 specifications', () {
      expect(ApiEndpoints.birthProfiles, '/api/v1/birth-profiles/');
      expect(ApiEndpoints.birthProfile('123-uuid'), '/api/v1/birth-profiles/123-uuid/');
      expect(ApiEndpoints.birthProfileKundali('123-uuid'), '/api/v1/birth-profiles/123-uuid/kundali/');
      expect(ApiEndpoints.birthProfilePdf('123-uuid'), '/api/v1/birth-profiles/123-uuid/pdf/');
      expect(ApiEndpoints.locationsSearch, '/api/v1/locations/search/');
      expect(ApiEndpoints.locationsDetails, '/api/v1/locations/details/');
      expect(ApiEndpoints.match, '/api/v1/match/');
      expect(ApiEndpoints.today, '/api/v1/today/');
      expect(ApiEndpoints.horoscopeSigns, '/api/v1/horoscope/signs/');
      expect(ApiEndpoints.horoscopeDaily('aries'), '/api/v1/horoscope/daily/aries/');
      expect(ApiEndpoints.horoscopeMonthly('aries'), '/api/v1/horoscope/monthly/aries/');
      expect(ApiEndpoints.horoscopeYearly('aries'), '/api/v1/horoscope/yearly/aries/');
    });
  });

  group('Data Models Parsing', () {
    test('LocationModel parses coordinates and timezone from JSON', () {
      final json = {
        'id': 'loc-uuid-1',
        'place_id': 'place_delhi_1',
        'name': 'New Delhi, India',
        'latitude': '28.6139',
        'longitude': '77.2090',
        'timezone_id': 'Asia/Kolkata',
        'country': 'India',
        'admin_area': 'Delhi',
      };

      final location = LocationModel.fromJson(json);
      expect(location.id, 'loc-uuid-1');
      expect(location.placeId, 'place_delhi_1');
      expect(location.name, 'New Delhi, India');
      expect(location.latitude, closeTo(28.6139, 0.0001));
      expect(location.longitude, closeTo(77.2090, 0.0001));
      expect(location.timezoneId, 'Asia/Kolkata');
    });

    test('LocationSearchResult parses predictions and description', () {
      final json = {
        'place_id': 'ChIJL_P_CXMEDTkRw0ZiJIefm9E',
        'description': 'New Delhi, Delhi, India',
        'structured_formatting': {
          'main_text': 'New Delhi',
          'secondary_text': 'Delhi, India',
        },
      };

      final result = LocationSearchResult.fromJson(json);
      expect(result.placeId, 'ChIJL_P_CXMEDTkRw0ZiJIefm9E');
      expect(result.description, 'New Delhi, Delhi, India');
      expect(result.mainText, 'New Delhi');
      expect(result.secondaryText, 'Delhi, India');
    });

    test('BirthProfileModel serializes for creation with place_id and deserializes with location_details', () {
      final profile = BirthProfileModel(
        name: 'Aarav Sharma',
        dateOfBirth: '1995-10-01',
        timeOfBirth: '04:57:00',
        placeId: 'ChIJL_P_CXMEDTkRw0ZiJIefm9E',
        gender: 'MALE',
        ayanamsaOverride: 'LAHIRI',
      );

      final creationJson = profile.toJson(forCreation: true);
      expect(creationJson['name'], 'Aarav Sharma');
      expect(creationJson['place_id'], 'ChIJL_P_CXMEDTkRw0ZiJIefm9E');
      expect(creationJson.containsKey('location_details'), false);

      final serverResponse = {
        'id': 'b1-uuid',
        'name': 'Aarav Sharma',
        'date_of_birth': '1995-10-01',
        'time_of_birth': '04:57:00',
        'location_details': {
          'id': 'loc-1',
          'place_id': 'ChIJL_P_CXMEDTkRw0ZiJIefm9E',
          'name': 'New Delhi',
          'latitude': '28.6139',
          'longitude': '77.2090',
          'timezone_id': 'Asia/Kolkata',
        },
        'gender': 'MALE',
        'created_at': '2026-10-04T10:00:00Z',
        'updated_at': '2026-10-04T10:00:00Z',
      };

      final parsed = BirthProfileModel.fromJson(serverResponse);
      expect(parsed.id, 'b1-uuid');
      expect(parsed.locationDetails?.name, 'New Delhi');
      expect(parsed.locationDetails?.latitude, closeTo(28.6139, 0.0001));
    });

    test('RawBirthData and MatchMakingRequest serialize properly for OpenAPI /match/', () {
      final boy = RawBirthData(
        name: 'Aarav Sharma',
        dateOfBirth: '1995-10-01',
        timeOfBirth: '04:57:00',
        latitude: 19.0760,
        longitude: 72.8777,
        timezone: 'Asia/Kolkata',
        gender: 'MALE',
      );

      final girl = RawBirthData(
        name: 'Priya Patel',
        dateOfBirth: '1996-05-15',
        timeOfBirth: '14:30:00',
        latitude: 28.7041,
        longitude: 77.1025,
        timezone: 'Asia/Kolkata',
        gender: 'FEMALE',
      );

      final request = MatchMakingRequest(
        profile1Data: boy,
        profile2Data: girl,
      );

      final json = request.toJson();
      expect(json.containsKey('profile1_data'), true);
      expect(json.containsKey('profile2_data'), true);
      expect(json['profile1_data']['latitude'], 19.0760);
      expect(json['profile2_data']['longitude'], 77.1025);
    });

    test('MatchResultModel parses 36 Gunas and Mangal Dosha compatibility', () {
      final json = {
        'total_score': 31,
        'max_score': 36,
        'verdict': 'EXCELLENT MATCH',
        'mangal_dosha': {
          'is_compatible': true,
          'description': 'No Mangal Dosha affliction found between charts.',
        },
        'ashtakoota': {
          'varna': {'name': 'Varna', 'score': 1, 'max_score': 1, 'description': 'Spiritual compatibility'},
          'vasya': {'name': 'Vasya', 'score': 2, 'max_score': 2, 'description': 'Power & dominance'},
          'nadi': {'name': 'Nadi', 'score': 8, 'max_score': 8, 'description': 'Health & genetics'},
        },
      };

      final result = MatchResultModel.fromJson(json);
      expect(result.totalScore, 31.0);
      expect(result.maxScore, 36.0);
      expect(result.verdict, 'EXCELLENT MATCH');
      expect(result.isMangalCompatible, true);
      expect(result.mangalDoshaDescription, contains('No Mangal Dosha'));
      expect(result.gunas.length, 3);
      expect(result.gunas.first.name, 'Varna');
      expect(result.gunas.first.score, 1.0);
    });

    test('TodayPanchangModel parses astronomical forecast', () {
      final json = {
        'date': '2026-10-04',
        'panchang': {
          'tithi': 'Shukla Ashtami',
          'nakshatra': 'Rohini',
          'yoga': 'Indra',
          'karana': 'Bava',
          'sunrise': '06:12 AM',
          'sunset': '06:45 PM',
          'rahu_kaal': '04:30 PM - 06:00 PM',
        },
      };

      final panchang = TodayPanchangModel.fromJson(json);
      expect(panchang.tithi, 'Shukla Ashtami');
      expect(panchang.nakshatra, 'Rohini');
      expect(panchang.yoga, 'Indra');
      expect(panchang.karana, 'Bava');
      expect(panchang.sunrise, '06:12 AM');
      expect(panchang.sunset, '06:45 PM');
      expect(panchang.rahuKaal, '04:30 PM - 06:00 PM');
    });

    test('TodayPanchangModel parses live ngrok backend format with status and data envelope', () {
      final json = {
        'status': 'success',
        'data': {
          'date': '2026-10-04',
          'sunrise': '06:00am',
          'sunset': '06:00pm',
          'rahu_kaal': '04:30pm - 06:00pm',
          'tithi': 'Krishna Navami',
          'nakshatra': 'PUNARVASU',
          'yoga': 'Parigha',
          'karana': 'Taitila',
        },
        'message': null,
        'errors': null,
      };

      final panchang = TodayPanchangModel.fromJson(json);
      expect(panchang.tithi, 'Krishna Navami');
      expect(panchang.nakshatra, 'PUNARVASU');
      expect(panchang.yoga, 'Parigha');
      expect(panchang.karana, 'Taitila');
      expect(panchang.sunrise, '06:00am');
      expect(panchang.sunset, '06:00pm');
      expect(panchang.rahuKaal, '04:30pm - 06:00pm');
    });

    test('MatchResultModel parses live ngrok backend breakdown and match_report format', () {
      final json = {
        'status': 'success',
        'data': {
          'profile1': {'name': 'Aarav Sharma', 'moon_sign': 'SAGITTARIUS'},
          'profile2': {'name': 'Priya Patel', 'moon_sign': 'ARIES'},
          'match_report': {
            'total_score': 9.0,
            'max_score': 36.0,
            'percentage': 25.0,
            'breakdown': {
              'varna': {'score': 1.0, 'max': 1.0},
              'graha_maitri': {'score': 5.0, 'max': 5.0},
            },
          },
          'verdict': 'Poor Match',
          'guna_descriptions': {
            'varna': 'Spiritual compatibility',
            'graha_maitri': 'Planet friendship',
          },
          'mangal_dosha': {
            'is_compatible': true,
            'message': 'Neither has Mangal Dosha.',
          },
          'compatibility_analysis': {
            'overall_verdict': 'Challenges present in emotional harmony.',
            'strengths': 'Mutual respect and intellect.',
            'challenges': 'Difference in temperaments.',
          },
        },
      };

      final result = MatchResultModel.fromJson(json);
      expect(result.totalScore, 9.0);
      expect(result.maxScore, 36.0);
      expect(result.percentage, 25.0);
      expect(result.profile1Name, 'Aarav Sharma');
      expect(result.profile1MoonSign, 'SAGITTARIUS');
      expect(result.profile2Name, 'Priya Patel');
      expect(result.profile2MoonSign, 'ARIES');
      expect(result.compatibilityAnalysis?.overallVerdict, contains('Challenges'));
      expect(result.compatibilityAnalysis?.strengths, contains('Mutual respect'));
      expect(result.compatibilityAnalysis?.challenges, contains('Difference'));
      expect(result.verdict, 'Poor Match');
      expect(result.isMangalCompatible, true);
      expect(result.mangalDoshaDescription, 'Neither has Mangal Dosha.');
      expect(result.gunas.length, 2);
      expect(result.gunas.first.name, 'Varna');
      expect(result.gunas.first.score, 1.0);
      expect(result.gunas.first.description, 'Spiritual compatibility');
    });

    test('ZodiacSignModel and HoroscopeModel parse OpenAPI 3.0.3 response correctly', () {
      final signJson = {
        'zodiac': 'LEO',
        'name': 'Leo',
        'sanskrit': 'Simha',
        'symbol': '♌',
        'date_range': 'Aug 17 – Sep 16',
        'date_range_note': 'Approximate sidereal dates',
        'element': 'Fire',
        'ruling_planet': 'Sun',
      };

      final sign = ZodiacSignModel.fromJson(signJson);
      expect(sign.zodiac, 'LEO');
      expect(sign.slug, 'leo');
      expect(sign.sanskrit, 'Simha');
      expect(sign.symbol, '♌');
      expect(sign.element, 'Fire');
      expect(sign.rulingPlanet, 'Sun');

      final horoscopeJson = {
        'zodiac': 'LEO',
        'zodiac_system': 'sidereal_rashi_lahiri',
        'name': 'Leo',
        'sanskrit': 'Simha',
        'symbol': '♌',
        'date_range': 'Aug 17 – Sep 16',
        'period': 'October 2026',
        'period_type': 'monthly',
        'sections': {
          'overview': 'A month of strong creativity.',
          'career': 'Leadership prospects expand.',
          'love': 'Generosity deepens trust.',
          'health': 'Cardio health is vibrant.'
        },
        'stellar_ratings': {
          'love': 5,
          'career': 4,
          'health': 5
        },
        'lucky_color': 'Gold',
        'lucky_number': 1
      };

      final horoscope = HoroscopeModel.fromJson(horoscopeJson);
      expect(horoscope.zodiac, 'LEO');
      expect(horoscope.period, 'October 2026');
      expect(horoscope.periodType, 'monthly');
      expect(horoscope.stellarRatings.love, 5);
      expect(horoscope.luckyColor, 'Gold');
      expect(horoscope.sections.overview, 'A month of strong creativity.');
    });
  });

  group('AstrologyApiService & ApiClient Integration', () {
    test('searchLocations returns parsed predictions from mock HTTP client', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/locations/search/');
        expect(request.url.queryParameters['q'], 'Mumbai');

        return http.Response(
          jsonEncode([
            {
              'place_id': 'mumbai_1',
              'description': 'Mumbai, Maharashtra, India',
            }
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(httpClient: mockClient);
      final service = AstrologyApiService(client: apiClient);

      final results = await service.searchLocations('Mumbai');
      expect(results.length, 1);
      expect(results.first.placeId, 'mumbai_1');
      expect(results.first.description, 'Mumbai, Maharashtra, India');
    });

    test('createBirthProfile and getKundali call correct endpoints', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/api/v1/birth-profiles/') {
          return http.Response(
            jsonEncode({
              'id': 'profile-uuid-42',
              'name': 'Test User',
              'date_of_birth': '1998-01-24',
              'time_of_birth': '14:30:00',
              'place_id': 'place_123',
              'location_details': {
                'id': 'loc-123',
                'name': 'Mumbai',
                'latitude': '19.0760',
                'longitude': '72.8777',
                'timezone_id': 'Asia/Kolkata',
              },
              'created_at': '2026-10-04T10:00:00Z',
              'updated_at': '2026-10-04T10:00:00Z',
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.method == 'GET' &&
            request.url.path == '/api/v1/birth-profiles/profile-uuid-42/kundali/') {
          return http.Response(
            jsonEncode({
              'ascendant': 'Leo',
              'moon_sign': 'Scorpio',
              'sun_sign': 'Sagittarius',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(httpClient: mockClient);
      final service = AstrologyApiService(client: apiClient);

      final profile = await service.createBirthProfile(
        BirthProfileModel(
          name: 'Test User',
          dateOfBirth: '1998-01-24',
          timeOfBirth: '14:30:00',
          placeId: 'place_123',
        ),
      );

      expect(profile.id, 'profile-uuid-42');

      final kundali = await service.getKundali(profile.id!);
      expect(kundali['ascendant'], 'Leo');
      expect(kundali['moon_sign'], 'Scorpio');
    });

    test('getKundaliPdfUrl returns valid download URL', () {
      final apiClient = ApiClient();
      final service = AstrologyApiService(client: apiClient);
      final url = service.getKundaliPdfUrl('test-uuid');
      expect(url, contains('/api/v1/birth-profiles/test-uuid/pdf/'));
    });

    test('downloadKundaliPdf fetches binary PDF bytes', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'GET' &&
            request.url.path == '/api/v1/birth-profiles/test-uuid/pdf/') {
          return http.Response.bytes(
            [0x25, 0x50, 0x44, 0x46, 0x2D], // %PDF-
            200,
            headers: {'content-type': 'application/pdf'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(httpClient: mockClient);
      final service = AstrologyApiService(client: apiClient);
      final bytes = await service.downloadKundaliPdf('test-uuid');
      expect(bytes, isNotEmpty);
      expect(bytes.length, 5);
      expect(bytes[0], 0x25);
    });
  });

  group('AstrologyApiProvider State Management', () {
    test('Provider handles kundali generation flow with state updates', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'POST') {
          return http.Response(
            jsonEncode({
              'id': 'test-profile-id',
              'name': 'Aarav',
              'date_of_birth': '1995-10-01',
              'time_of_birth': '04:57:00',
              'location_details': {
                'id': 'loc-1',
                'name': 'Delhi',
                'latitude': '28.6139',
                'longitude': '77.2090',
                'timezone_id': 'Asia/Kolkata',
              },
              'created_at': '2026-10-04T10:00:00Z',
              'updated_at': '2026-10-04T10:00:00Z',
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          jsonEncode({'chart': 'Rasi'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = AstrologyApiService(client: ApiClient(httpClient: mockClient));
      final provider = AstrologyApiProvider(apiService: service);

      expect(provider.isGeneratingKundali, false);
      expect(provider.activeProfile, isNull);

      final success = await provider.generateKundali(
        name: 'Aarav',
        dateOfBirth: '1995-10-01',
        timeOfBirth: '04:57:00',
        placeId: 'delhi-place-id',
        gender: 'MALE',
      );

      expect(success, true);
      expect(provider.isGeneratingKundali, false);
      expect(provider.activeProfile?.id, 'test-profile-id');
      expect(provider.activeKundaliData?['chart'], 'Rasi');
    });

    test('Provider fetches and caches horoscope predictions', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/horoscope/signs/')) {
          return http.Response(
            jsonEncode({
              'status': 'success',
              'data': [
                {
                  'zodiac': 'ARIES',
                  'name': 'Aries',
                  'sanskrit': 'Mesha',
                  'symbol': '♈',
                  'date_range': 'Apr 14 – May 14',
                  'element': 'Fire',
                  'ruling_planet': 'Mars',
                }
              ]
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (request.url.path.contains('/horoscope/daily/aries/')) {
          return http.Response(
            jsonEncode({
              'status': 'success',
              'data': {
                'zodiac': 'ARIES',
                'name': 'Aries',
                'sanskrit': 'Mesha',
                'symbol': '♈',
                'date_range': 'Apr 14 – May 14',
                'period': '2026-10-13',
                'period_type': 'daily',
                'element': 'Fire',
                'ruling_planet': 'Mars',
                'sections': {
                  'overview': 'Mars brings strong motivation today.',
                  'career': 'Focus on high-leverage projects.',
                  'love': 'Honest communication creates harmony.',
                  'health': 'Stay active and hydrate well.'
                },
                'stellar_ratings': {
                  'love': 4,
                  'career': 5,
                  'health': 4
                },
                'lucky_color': 'Crimson Red',
                'lucky_number': 9
              }
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response('{"error": "not found"}', 404);
      });

      final service = AstrologyApiService(client: ApiClient(httpClient: mockClient));
      final provider = AstrologyApiProvider(apiService: service);

      // 1. Fetch signs
      await provider.fetchHoroscopeSigns();
      expect(provider.zodiacSigns.length, 1);
      expect(provider.zodiacSigns.first.zodiac, 'ARIES');
      expect(provider.zodiacSigns.first.slug, 'aries');

      // 2. Fetch horoscope
      final horoscope = await provider.fetchHoroscope(zodiac: 'aries', periodType: 'daily');
      expect(horoscope, isNotNull);
      expect(horoscope?.name, 'Aries');
      expect(horoscope?.sanskrit, 'Mesha');
      expect(horoscope?.period, '2026-10-13');
      expect(horoscope?.stellarRatings.career, 5);
      expect(horoscope?.luckyColor, 'Crimson Red');
      expect(horoscope?.luckyNumber, 9);
      expect(horoscope?.sections.overview, contains('Mars brings strong motivation'));

      // 3. Cache verification
      expect(provider.currentHoroscope, isNotNull);
      final cached = await provider.fetchHoroscope(zodiac: 'aries', periodType: 'daily');
      expect(cached?.period, '2026-10-13');
    });
  });
}

