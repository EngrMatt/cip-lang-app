class Record {
  const Record({
    required this.id,
    required this.title,
    required this.category,
    this.note,
    this.audioUrl,
    this.imageUrl,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String category;
  final String? note;
  final String? audioUrl;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  bool get hasLocation => latitude != null && longitude != null;

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      note: json['note'] as String?,
      audioUrl: json['audio_url'] as String?,
      imageUrl: json['image_url'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'title': title,
        'category': category,
        if (note != null) 'note': note,
      };
}

class RecordListResponse {
  const RecordListResponse({
    required this.items,
    required this.total,
    this.page,
    this.pageSize,
  });

  final List<Record> items;
  final int total;
  final int? page;
  final int? pageSize;

  factory RecordListResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map((e) => Record.fromJson(e as Map<String, dynamic>))
        .toList();
    return RecordListResponse(
      items: items,
      total: json['total'] as int,
      page: json['page'] as int?,
      pageSize: json['page_size'] as int?,
    );
  }
}
