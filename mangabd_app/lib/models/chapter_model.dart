class ChapterModel {
  final String id;
  final String mangaId;
  final String title;
  final int chapterNumber;
  final List<String> pageUrls;
  final DateTime createdAt;

  ChapterModel({
    required this.id,
    required this.mangaId,
    required this.title,
    required this.chapterNumber,
    this.pageUrls = const [],
    required this.createdAt,
  });

  factory ChapterModel.fromMap(Map<String, dynamic> map) {
    return ChapterModel(
      id: map['id'] ?? '',
      mangaId: map['mangaId'] ?? '',
      title: map['title'] ?? '',
      chapterNumber: map['chapterNumber'] ?? 0,
      pageUrls: List<String>.from(map['pageUrls'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mangaId': mangaId,
      'title': title,
      'chapterNumber': chapterNumber,
      'pageUrls': pageUrls,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}