class ParsedRecordNote {
  const ParsedRecordNote({
    this.surveyorName,
    this.region,
    this.userNote,
    required this.rawNote,
  });

  final String? surveyorName;
  final String? region;
  final String? userNote;
  final String rawNote;

  bool get hasSurveyorInfo =>
      surveyorName != null && surveyorName!.trim().isNotEmpty;

  /// 解析 `[調查員: 姓名 | 地區] 使用者備註`；失敗則整段當使用者備註。
  factory ParsedRecordNote.parse(String note) {
    final trimmed = note.trim();
    if (trimmed.isEmpty) {
      return ParsedRecordNote(rawNote: note);
    }

    final match = RegExp(
      r'^\[調查員:\s*([^|\]]+)(?:\s*\|\s*([^\]]+))?\]\s*(.*)$',
      dotAll: true,
    ).firstMatch(trimmed);

    if (match == null) {
      return ParsedRecordNote(userNote: trimmed, rawNote: note);
    }

    final name = match.group(1)?.trim();
    final region = match.group(2)?.trim();
    final userNote = match.group(3)?.trim();

    return ParsedRecordNote(
      surveyorName: name?.isNotEmpty == true ? name : null,
      region: region?.isNotEmpty == true ? region : null,
      userNote: userNote?.isNotEmpty == true ? userNote : null,
      rawNote: note,
    );
  }
}
