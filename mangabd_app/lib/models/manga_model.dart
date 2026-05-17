class MangaModel {
  final String id;
  final String title;
  final String description;
  final String coverUrl;
  final String creatorId;
  final String creatorName;
  final List<String> genres;
  final int totalChapters;
  final DateTime createdAt;
  final DateTime updatedAt;

  MangaModel({
    required this.id,
    required this.title,
    required this.description,
    this.coverUrl = '',
    required this.creatorId,
    required this.creatorName,
    this.genres = const [],
    this.totalChapters = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MangaModel.fromMap(Map<String, dynamic> map) {
    return MangaModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      coverUrl: map['coverUrl'] ?? '',
      creatorId: map['creatorId'] ?? '',
      creatorName: map['creatorName'] ?? '',
      genres: List<String>.from(map['genres'] ?? []),
      totalChapters: map['totalChapters'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverUrl': coverUrl,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'genres': genres,
      'totalChapters': totalChapters,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}