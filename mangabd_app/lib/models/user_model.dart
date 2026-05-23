class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final bool isCreator;
  final DateTime createdAt;
  final int followersCount;
  final int followingCount;
  final int bookmarksCount;
  final int chaptersRead;
  final int totalWorks;
  final int totalChaptersUploaded;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    this.isCreator = false,
    required this.createdAt,
    this.followersCount = 0,
    this.followingCount = 0,
    this.bookmarksCount = 0,
    this.chaptersRead = 0,
    this.totalWorks = 0,
    this.totalChaptersUploaded = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      isCreator: map['isCreator'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      followersCount: (map['followersCount'] ?? 0).toInt(),
      followingCount: (map['followingCount'] ?? 0).toInt(),
      bookmarksCount: (map['bookmarksCount'] ?? 0).toInt(),
      chaptersRead: (map['chaptersRead'] ?? 0).toInt(),
      totalWorks: (map['totalWorks'] ?? 0).toInt(),
      totalChaptersUploaded: (map['totalChaptersUploaded'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isCreator': isCreator,
      'createdAt': createdAt.toIso8601String(),
      'followersCount': followersCount,
      'followingCount': followingCount,
      'bookmarksCount': bookmarksCount,
      'chaptersRead': chaptersRead,
      'totalWorks': totalWorks,
      'totalChaptersUploaded': totalChaptersUploaded,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    int? followersCount,
    int? followingCount,
    int? bookmarksCount,
    int? chaptersRead,
    int? totalWorks,
    int? totalChaptersUploaded,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isCreator: isCreator,
      createdAt: createdAt,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      bookmarksCount: bookmarksCount ?? this.bookmarksCount,
      chaptersRead: chaptersRead ?? this.chaptersRead,
      totalWorks: totalWorks ?? this.totalWorks,
      totalChaptersUploaded:
          totalChaptersUploaded ?? this.totalChaptersUploaded,
    );
  }
}