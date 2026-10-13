import 'package:flutter/material.dart';

class ZodiacSignModel {
  final String zodiac; // e.g. "ARIES"
  final String name; // e.g. "Aries"
  final String sanskrit; // e.g. "Mesha"
  final String symbol; // e.g. "♈"
  final String dateRange; // e.g. "Apr 14 – May 14"
  final String dateRangeNote;
  final String element; // e.g. "Fire"
  final String rulingPlanet; // e.g. "Mars"

  const ZodiacSignModel({
    required this.zodiac,
    required this.name,
    required this.sanskrit,
    required this.symbol,
    required this.dateRange,
    this.dateRangeNote = '',
    this.element = '',
    this.rulingPlanet = '',
  });

  String get slug => zodiac.toLowerCase().trim();

  Color get themeColor {
    switch (slug) {
      case 'aries':
        return Colors.redAccent;
      case 'taurus':
        return Colors.green;
      case 'gemini':
        return Colors.cyan;
      case 'cancer':
        return Colors.purpleAccent;
      case 'leo':
        return Colors.amber;
      case 'virgo':
        return Colors.orange;
      case 'libra':
        return Colors.pinkAccent;
      case 'scorpio':
        return Colors.deepPurple;
      case 'sagittarius':
        return Colors.blueAccent;
      case 'capricorn':
        return Colors.blueGrey;
      case 'aquarius':
        return Colors.indigoAccent;
      case 'pisces':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFFFEA703);
    }
  }

  factory ZodiacSignModel.fromJson(Map<String, dynamic> json) {
    return ZodiacSignModel(
      zodiac: (json['zodiac'] ?? json['key'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      sanskrit: (json['sanskrit'] ?? json['sanskrit_name'] ?? '').toString(),
      symbol: (json['symbol'] ?? '').toString(),
      dateRange: (json['date_range'] ?? '').toString(),
      dateRangeNote: (json['date_range_note'] ?? '').toString(),
      element: (json['element'] ?? '').toString(),
      rulingPlanet: (json['ruling_planet'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zodiac': zodiac,
      'name': name,
      'sanskrit': sanskrit,
      'symbol': symbol,
      'date_range': dateRange,
      'date_range_note': dateRangeNote,
      'element': element,
      'ruling_planet': rulingPlanet,
    };
  }

  /// Default 12 fallback signs to display instantly or offline
  static const List<ZodiacSignModel> defaultSigns = [
    ZodiacSignModel(
      zodiac: 'ARIES',
      name: 'Aries',
      sanskrit: 'Mesha',
      symbol: '♈',
      dateRange: 'Apr 14 – May 14',
      dateRangeNote: 'Approximate sidereal dates',
      element: 'Fire',
      rulingPlanet: 'Mars',
    ),
    ZodiacSignModel(
      zodiac: 'TAURUS',
      name: 'Taurus',
      sanskrit: 'Vrishabha',
      symbol: '♉',
      dateRange: 'May 15 – Jun 14',
      dateRangeNote: 'Approximate sidereal dates',
      element: 'Earth',
      rulingPlanet: 'Venus',
    ),
    ZodiacSignModel(
      zodiac: 'GEMINI',
      name: 'Gemini',
      sanskrit: 'Mithuna',
      symbol: '♊',
      dateRange: 'Jun 15 – Jul 15',
      dateRangeNote: 'Approximate sidereal dates',
      element: 'Air',
      rulingPlanet: 'Mercury',
    ),
    ZodiacSignModel(
      zodiac: 'CANCER',
      name: 'Cancer',
      sanskrit: 'Karka',
      symbol: '♋',
      dateRange: 'Jul 16 – Aug 16',
      dateRangeNote: 'Approximate sidereal dates',
      element: 'Water',
      rulingPlanet: 'Moon',
    ),
    ZodiacSignModel(
      zodiac: 'LEO',
      name: 'Leo',
      sanskrit: 'Simha',
      symbol: '♌',
      dateRange: 'Aug 17 – Sep 16',
      dateRangeNote: 'Approximate sidereal dates',
      element: 'Fire',
      rulingPlanet: 'Sun',
    ),
    ZodiacSignModel(
      zodiac: 'VIRGO',
      name: 'Virgo',
      sanskrit: 'Kanya',
      symbol: '♍',
      dateRange: 'Sep 17 – Oct 16',
      dateRangeNote: 'Approximate sidereal dates',
      element: 'Earth',
      rulingPlanet: 'Mercury',
    ),
    ZodiacSignModel(
      zodiac: 'LIBRA',
      name: 'Libra',
      sanskrit: 'Tula',
      symbol: '♎',
      dateRange: 'Oct 17 – Nov 15',
      dateRangeNote: 'Approximate sidereal dates',
      element: 'Air',
      rulingPlanet: 'Venus',
    ),
    ZodiacSignModel(
      zodiac: 'SCORPIO',
      name: 'Scorpio',
      sanskrit: 'Vrishchika',
      symbol: '♏',
      dateRange: 'Nov 16 – Dec 15',
      dateRangeNote: 'Approximate sidereal dates',
      element: 'Water',
      rulingPlanet: 'Mars',
    ),
    ZodiacSignModel(
      zodiac: 'SAGITTARIUS',
      name: 'Sagittarius',
      sanskrit: 'Dhanu',
      symbol: '♐',
      dateRange: 'Dec 16 – Jan 13',
      dateRangeNote: 'Approximate sidereal dates',
      element: 'Fire',
      rulingPlanet: 'Jupiter',
    ),
    ZodiacSignModel(
      zodiac: 'CAPRICORN',
      name: 'Capricorn',
      sanskrit: 'Makara',
      symbol: '♑',
      dateRange: 'Jan 14 – Feb 12',
      dateRangeNote: 'Approximate sidereal dates',
      element: 'Earth',
      rulingPlanet: 'Saturn',
    ),
    ZodiacSignModel(
      zodiac: 'AQUARIUS',
      name: 'Aquarius',
      sanskrit: 'Kumbha',
      symbol: '♒',
      dateRange: 'Feb 13 – Mar 13',
      dateRangeNote: 'Approximate sidereal dates',
      element: 'Air',
      rulingPlanet: 'Saturn',
    ),
    ZodiacSignModel(
      zodiac: 'PISCES',
      name: 'Pisces',
      sanskrit: 'Meena',
      symbol: '♓',
      dateRange: 'Mar 14 – Apr 13',
      dateRangeNote: 'Approximate sidereal dates',
      element: 'Water',
      rulingPlanet: 'Jupiter',
    ),
  ];
}

class HoroscopeSections {
  final String overview;
  final String career;
  final String love;
  final String health;

  const HoroscopeSections({
    this.overview = '',
    this.career = '',
    this.love = '',
    this.health = '',
  });

  factory HoroscopeSections.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HoroscopeSections();
    return HoroscopeSections(
      overview: (json['overview'] ?? '').toString(),
      career: (json['career'] ?? '').toString(),
      love: (json['love'] ?? '').toString(),
      health: (json['health'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overview': overview,
      'career': career,
      'love': love,
      'health': health,
    };
  }
}

class HoroscopeRatings {
  final int love;
  final int career;
  final int health;

  const HoroscopeRatings({
    this.love = 3,
    this.career = 3,
    this.health = 3,
  });

  factory HoroscopeRatings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HoroscopeRatings();
    int parseInt(dynamic val, int fallback) {
      if (val is int) return val.clamp(1, 5);
      if (val is num) return val.toInt().clamp(1, 5);
      if (val is String) return (int.tryParse(val) ?? fallback).clamp(1, 5);
      return fallback;
    }

    return HoroscopeRatings(
      love: parseInt(json['love'], 3),
      career: parseInt(json['career'], 3),
      health: parseInt(json['health'], 3),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'love': love,
      'career': career,
      'health': health,
    };
  }
}

class HoroscopeModel {
  final String zodiac;
  final String? zodiacSystem;
  final String name;
  final String sanskrit;
  final String symbol;
  final String dateRange;
  final String? dateRangeNote;
  final String? element;
  final String? rulingPlanet;
  final String period;
  final String periodType; // "daily", "monthly", "yearly"
  final String? timezone;
  final HoroscopeSections sections;
  final HoroscopeRatings stellarRatings;
  final String luckyColor;
  final int luckyNumber;

  const HoroscopeModel({
    required this.zodiac,
    this.zodiacSystem,
    required this.name,
    required this.sanskrit,
    required this.symbol,
    required this.dateRange,
    this.dateRangeNote,
    this.element,
    this.rulingPlanet,
    required this.period,
    required this.periodType,
    this.timezone,
    this.sections = const HoroscopeSections(),
    this.stellarRatings = const HoroscopeRatings(),
    this.luckyColor = 'Gold',
    this.luckyNumber = 1,
  });

  factory HoroscopeModel.fromJson(Map<String, dynamic> json) {
    int parseNumber(dynamic val, int fallback) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? fallback;
      return fallback;
    }

    final rawSections = json['sections'] is Map<String, dynamic>
        ? json['sections'] as Map<String, dynamic>
        : null;

    final rawRatings = json['stellar_ratings'] is Map<String, dynamic>
        ? json['stellar_ratings'] as Map<String, dynamic>
        : (json['ratings'] is Map<String, dynamic>
            ? json['ratings'] as Map<String, dynamic>
            : null);

    return HoroscopeModel(
      zodiac: (json['zodiac'] ?? '').toString(),
      zodiacSystem: json['zodiac_system']?.toString(),
      name: (json['name'] ?? '').toString(),
      sanskrit: (json['sanskrit'] ?? '').toString(),
      symbol: (json['symbol'] ?? '').toString(),
      dateRange: (json['date_range'] ?? '').toString(),
      dateRangeNote: json['date_range_note']?.toString(),
      element: json['element']?.toString(),
      rulingPlanet: json['ruling_planet']?.toString(),
      period: (json['period'] ?? '').toString(),
      periodType: (json['period_type'] ?? 'daily').toString(),
      timezone: json['timezone']?.toString(),
      sections: HoroscopeSections.fromJson(rawSections),
      stellarRatings: HoroscopeRatings.fromJson(rawRatings),
      luckyColor: (json['lucky_color'] ?? 'Gold').toString(),
      luckyNumber: parseNumber(json['lucky_number'], 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zodiac': zodiac,
      'zodiac_system': zodiacSystem,
      'name': name,
      'sanskrit': sanskrit,
      'symbol': symbol,
      'date_range': dateRange,
      'date_range_note': dateRangeNote,
      'element': element,
      'ruling_planet': rulingPlanet,
      'period': period,
      'period_type': periodType,
      'timezone': timezone,
      'sections': sections.toJson(),
      'stellar_ratings': stellarRatings.toJson(),
      'lucky_color': luckyColor,
      'lucky_number': luckyNumber,
    };
  }
}
