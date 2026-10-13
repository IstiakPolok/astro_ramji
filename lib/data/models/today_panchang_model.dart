class TodayPanchangModel {
  final String date;
  final String tithi;
  final String nakshatra;
  final String yoga;
  final String karana;
  final String? paksha;
  final String? sunrise;
  final String? sunset;
  final String? moonrise;
  final String? rahuKaal;
  final String? yamaGandam;
  final String? abhijitMuhurta;
  final String? mahadasha;
  final String? mahadashaPeriod;
  final Map<String, dynamic> rawData;

  const TodayPanchangModel({
    required this.date,
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    this.paksha,
    this.sunrise,
    this.sunset,
    this.moonrise,
    this.rahuKaal,
    this.yamaGandam,
    this.abhijitMuhurta,
    this.mahadasha,
    this.mahadashaPeriod,
    required this.rawData,
  });

  factory TodayPanchangModel.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>? ?? json;
    final panchang = dataMap['panchang'] as Map<String, dynamic>? ?? dataMap;

    String extractName(dynamic field, String fallback) {
      if (field == null) return fallback;
      if (field is String) return field;
      if (field is Map) return field['name']?.toString() ?? field['title']?.toString() ?? fallback;
      return field.toString();
    }

    return TodayPanchangModel(
      date: dataMap['date']?.toString() ?? json['date']?.toString() ?? DateTime.now().toIso8601String().split('T').first,
      tithi: extractName(panchang['tithi'], 'Shukla Navami (ends 06:42 PM)'),
      nakshatra: extractName(panchang['nakshatra'], 'Rohini (ends 03:15 PM)'),
      yoga: extractName(panchang['yoga'], 'Shukla (ends 11:30 AM)'),
      karana: extractName(panchang['karana'], 'Kaulava (ends 07:10 AM)'),
      paksha: panchang['paksha']?.toString(),
      sunrise: panchang['sunrise']?.toString() ?? '05:48 AM',
      sunset: panchang['sunset']?.toString() ?? '06:42 PM',
      moonrise: panchang['moonrise']?.toString(),
      rahuKaal: panchang['rahu_kaal']?.toString() ?? panchang['rahukaal']?.toString() ?? '07:30 AM - 09:00 AM',
      yamaGandam: panchang['yama_gandam']?.toString() ?? '10:30 AM - 12:00 PM',
      abhijitMuhurta: panchang['abhijit_muhurta']?.toString() ?? '11:50 AM - 12:40 PM',
      mahadasha: dataMap['mahadasha']?.toString() ?? json['mahadasha']?.toString() ?? 'JUPITER MAHADASHA',
      mahadashaPeriod: dataMap['mahadasha_period']?.toString() ?? json['mahadasha_period']?.toString() ?? '2023–2039 · Currently active',
      rawData: json,
    );
  }
}
