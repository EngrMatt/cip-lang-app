class SurveyorProfile {
  const SurveyorProfile({
    required this.name,
    this.region,
  });

  final String name;
  final String? region;

  String notePrefix() {
    final regionPart = region != null && region!.trim().isNotEmpty
        ? ' | ${region!.trim()}'
        : '';
    return '[調查員: ${name.trim()}$regionPart]';
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'region': region,
      };

  factory SurveyorProfile.fromJson(Map<String, dynamic> json) {
    return SurveyorProfile(
      name: json['name'] as String,
      region: json['region'] as String?,
    );
  }
}

String mergeNoteWithSurveyorPrefix({
  required SurveyorProfile profile,
  String? userNote,
}) {
  final prefix = profile.notePrefix();
  final trimmed = userNote?.trim() ?? '';
  if (trimmed.isEmpty) return prefix;
  return '$prefix $trimmed';
}
