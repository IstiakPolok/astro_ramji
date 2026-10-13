class ApiEndpoints {
  static const String birthProfiles = '/api/v1/birth-profiles/';
  static String birthProfile(String id) => '/api/v1/birth-profiles/$id/';
  static String birthProfileKundali(String id) => '/api/v1/birth-profiles/$id/kundali/';
  static String birthProfilePdf(String id) => '/api/v1/birth-profiles/$id/pdf/';
  static const String locationsSearch = '/api/v1/locations/search/';
  static const String locationsDetails = '/api/v1/locations/details/';
  static const String match = '/api/v1/match/';
  static const String today = '/api/v1/today/';
  static const String horoscopeSigns = '/api/v1/horoscope/signs/';
  static String horoscopeDaily(String zodiac) => '/api/v1/horoscope/daily/$zodiac/';
  static String horoscopeMonthly(String zodiac) => '/api/v1/horoscope/monthly/$zodiac/';
  static String horoscopeYearly(String zodiac) => '/api/v1/horoscope/yearly/$zodiac/';
}
