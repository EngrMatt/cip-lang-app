class RecordDraft {
  RecordDraft({
    required this.id,
    required this.title,
    required this.category,
    this.note = '',
    this.audioPath,
    this.imagePath,
    this.stepIndex = 0,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String category;
  final String note;
  final String? audioPath;
  final String? imagePath;
  final int stepIndex;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'note': note,
        'audioPath': audioPath,
        'imagePath': imagePath,
        'stepIndex': stepIndex,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory RecordDraft.fromJson(Map<dynamic, dynamic> json) {
    return RecordDraft(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '錄音',
      note: json['note'] as String? ?? '',
      audioPath: json['audioPath'] as String?,
      imagePath: json['imagePath'] as String?,
      stepIndex: json['stepIndex'] as int? ?? 0,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  RecordDraft copyWith({
    String? title,
    String? category,
    String? note,
    String? audioPath,
    bool clearAudio = false,
    String? imagePath,
    bool clearImage = false,
    int? stepIndex,
    DateTime? updatedAt,
  }) {
    return RecordDraft(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      note: note ?? this.note,
      audioPath: clearAudio ? null : (audioPath ?? this.audioPath),
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      stepIndex: stepIndex ?? this.stepIndex,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
