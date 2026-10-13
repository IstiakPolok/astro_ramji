import 'birth_profile_model.dart';

class MatchMakingRequest {
  final String? profile1Id;
  final String? profile2Id;
  final RawBirthData? profile1Data;
  final RawBirthData? profile2Data;

  const MatchMakingRequest({
    this.profile1Id,
    this.profile2Id,
    this.profile1Data,
    this.profile2Data,
  });

  Map<String, dynamic> toJson() {
    return {
      if (profile1Id != null) 'profile1_id': profile1Id,
      if (profile2Id != null) 'profile2_id': profile2Id,
      if (profile1Data != null) 'profile1_data': profile1Data!.toJson(),
      if (profile2Data != null) 'profile2_data': profile2Data!.toJson(),
    };
  }
}

class GunaItem {
  final String name;
  final double score;
  final double maxScore;
  final String? description;

  const GunaItem({
    required this.name,
    required this.score,
    required this.maxScore,
    this.description,
  });

  factory GunaItem.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return GunaItem(
      name: json['name']?.toString() ?? json['guna']?.toString() ?? '',
      score: parseNum(json['score'] ?? json['obtained_points'] ?? json['points']),
      maxScore: parseNum(json['max_score'] ?? json['maximum_points'] ?? json['total_points'] ?? 1.0),
      description: json['description']?.toString() ?? json['verdict']?.toString(),
    );
  }
}

class CompatibilityAnalysis {
  final String? overallVerdict;
  final String? strengths;
  final String? challenges;

  const CompatibilityAnalysis({
    this.overallVerdict,
    this.strengths,
    this.challenges,
  });

  factory CompatibilityAnalysis.fromJson(Map<String, dynamic> json) {
    return CompatibilityAnalysis(
      overallVerdict: json['overall_verdict']?.toString(),
      strengths: json['strengths']?.toString(),
      challenges: json['challenges']?.toString(),
    );
  }
}

class MatchResultModel {
  final double totalScore;
  final double maxScore;
  final double percentage;
  final String verdict;
  final bool isMangalCompatible;
  final String? mangalDoshaDescription;
  final String? profile1Name;
  final String? profile1MoonSign;
  final String? profile2Name;
  final String? profile2MoonSign;
  final CompatibilityAnalysis? compatibilityAnalysis;
  final List<GunaItem> gunas;
  final Map<String, dynamic> rawResponse;

  const MatchResultModel({
    required this.totalScore,
    this.maxScore = 36.0,
    this.percentage = 0.0,
    required this.verdict,
    required this.isMangalCompatible,
    this.mangalDoshaDescription,
    this.profile1Name,
    this.profile1MoonSign,
    this.profile2Name,
    this.profile2MoonSign,
    this.compatibilityAnalysis,
    required this.gunas,
    required this.rawResponse,
  });

  factory MatchResultModel.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic val, [double defaultVal = 0.0]) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? defaultVal;
      return defaultVal;
    }

    final data = json['data'] as Map<String, dynamic>? ?? json;
    final matchReport = data['match_report'] as Map<String, dynamic>? ?? data;

    final totalScore = parseNum(
      matchReport['total_score'] ?? matchReport['score'] ?? matchReport['total_points'] ?? data['total_score'] ?? json['total_score'],
      28.0,
    );
    final maxScore = parseNum(
      matchReport['max_score'] ?? matchReport['maximum_score'] ?? data['max_score'] ?? json['max_score'],
      36.0,
    );
    final percentage = parseNum(
      matchReport['percentage'] ?? data['percentage'] ?? json['percentage'],
      maxScore > 0 ? (totalScore / maxScore) * 100 : 0.0,
    );

    final profile1 = data['profile1'] as Map<String, dynamic>?;
    final profile2 = data['profile2'] as Map<String, dynamic>?;
    final compJson = data['compatibility_analysis'] as Map<String, dynamic>? ??
        json['compatibility_analysis'] as Map<String, dynamic>?;

    final profile1Name = profile1?['name']?.toString();
    final profile1MoonSign = profile1?['moon_sign']?.toString();
    final profile2Name = profile2?['name']?.toString();
    final profile2MoonSign = profile2?['moon_sign']?.toString();
    final compAnalysis = compJson != null ? CompatibilityAnalysis.fromJson(compJson) : null;

    final breakdown = matchReport['breakdown'] as Map<String, dynamic>? ??
        data['ashtakoota'] as Map<String, dynamic>? ??
        data['gunas'] as Map<String, dynamic>? ??
        json['ashtakoota'] as Map<String, dynamic>? ??
        {};

    final gunaDescriptions = data['guna_descriptions'] as Map<String, dynamic>? ?? {};

    String formatGunaName(dynamic name, String fallbackKey) {
      final str = (name ?? fallbackKey).toString();
      if (str.isEmpty) return '';
      return str[0].toUpperCase() + str.substring(1);
    }

    final List<GunaItem> gunasList = [];
    if (breakdown.isNotEmpty) {
      breakdown.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final desc = gunaDescriptions[key]?.toString() ?? value['description']?.toString();
          gunasList.add(GunaItem(
            name: formatGunaName(value['name'], key),
            score: parseNum(value['score'] ?? value['points']),
            maxScore: parseNum(value['max'] ?? value['max_score'] ?? value['total_points'] ?? 1.0),
            description: desc,
          ));
        } else if (value is num) {
          gunasList.add(GunaItem(
            name: formatGunaName(null, key),
            score: value.toDouble(),
            maxScore: 5.0,
            description: gunaDescriptions[key]?.toString(),
          ));
        }
      });
    }

    // Mangal dosha detection
    final mangalData = data['mangal_dosha'] as Map<String, dynamic>? ?? json['mangal_dosha'] as Map<String, dynamic>?;
    final isCompatible = mangalData?['is_compatible'] as bool? ??
        data['mangal_dosha_compatible'] as bool? ??
        json['mangal_dosha_compatible'] as bool? ??
        true;

    final mangalDesc = mangalData?['message']?.toString() ??
        mangalData?['description']?.toString() ??
        data['mangal_compatible_desc']?.toString();

    final verdict = data['verdict']?.toString() ??
        json['verdict']?.toString() ??
        (totalScore >= 18.0 ? 'EXCELLENT MATCH' : 'AVERAGE MATCH');

    return MatchResultModel(
      totalScore: totalScore,
      maxScore: maxScore,
      percentage: percentage,
      verdict: verdict,
      isMangalCompatible: isCompatible,
      mangalDoshaDescription: mangalDesc,
      profile1Name: profile1Name,
      profile1MoonSign: profile1MoonSign,
      profile2Name: profile2Name,
      profile2MoonSign: profile2MoonSign,
      compatibilityAnalysis: compAnalysis,
      gunas: gunasList,
      rawResponse: json,
    );
  }
}
