import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/manga_model.dart';
import '../../models/chapter_model.dart';
import '../../models/user_model.dart';
import '../../models/chat_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MangaModel>> getMangas() {
    return _firestore
        .collection('mangas')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MangaModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<MangaModel>> getMangasByCreator(String creatorId) {
    return _firestore
        .collection('mangas')
        .where('creatorId', isEqualTo: creatorId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MangaModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> addManga(MangaModel manga) async {
    await _firestore.collection('mangas').doc(manga.id).set(manga.toMap());
    await _firestore.collection('users').doc(manga.creatorId).update({
      'totalWorks': FieldValue.increment(1),
    });
  }

  Future<void> deleteManga(String mangaId, String creatorId) async {
    final chaptersSnap = await _firestore
        .collection('mangas')
        .doc(mangaId)
        .collection('chapters')
        .get();

    final batch = _firestore.batch();
    for (final doc in chaptersSnap.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_firestore.collection('mangas').doc(mangaId));
    await batch.commit();

    await _firestore.collection('users').doc(creatorId).update({
      'totalWorks': FieldValue.increment(-1),
      'totalChaptersUploaded': FieldValue.increment(-chaptersSnap.docs.length),
    });

    final usersSnap = await _firestore.collection('users').get();
    for (final userDoc in usersSnap.docs) {
      final bookmarkRef = _firestore
          .collection('users')
          .doc(userDoc.id)
          .collection('bookmarks')
          .doc(mangaId);
      final bookmarkDoc = await bookmarkRef.get();
      if (bookmarkDoc.exists) {
        await bookmarkRef.delete();
        await _firestore.collection('users').doc(userDoc.id).update({
          'bookmarksCount': FieldValue.increment(-1),
        });
      }
    }
  }

  Stream<List<ChapterModel>> getChapters(String mangaId) {
    return _firestore
        .collection('mangas')
        .doc(mangaId)
        .collection('chapters')
        .orderBy('chapterNumber')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChapterModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> addChapter(ChapterModel chapter) async {
    await _firestore
        .collection('mangas')
        .doc(chapter.mangaId)
        .collection('chapters')
        .doc(chapter.id)
        .set(chapter.toMap());

    await _firestore.collection('mangas').doc(chapter.mangaId).update({
      'totalChapters': FieldValue.increment(1),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    final mangaDoc =
        await _firestore.collection('mangas').doc(chapter.mangaId).get();
    if (mangaDoc.exists) {
      final creatorId = mangaDoc.data()?['creatorId'] as String?;
      if (creatorId != null) {
        await _firestore.collection('users').doc(creatorId).update({
          'totalChaptersUploaded': FieldValue.increment(1),
        });
      }
    }
  }

  Future<void> deleteChapter(String mangaId, String chapterId) async {
    final mangaDoc =
        await _firestore.collection('mangas').doc(mangaId).get();
    final creatorId = mangaDoc.data()?['creatorId'] as String?;

    await _firestore
        .collection('mangas')
        .doc(mangaId)
        .collection('chapters')
        .doc(chapterId)
        .delete();

    await _firestore.collection('mangas').doc(mangaId).update({
      'totalChapters': FieldValue.increment(-1),
    });

    if (creatorId != null) {
      await _firestore.collection('users').doc(creatorId).update({
        'totalChaptersUploaded': FieldValue.increment(-1),
      });
    }
  }

  Future<List<MangaModel>> searchManga(String query) async {
    if (query.trim().isEmpty) return [];
    final lower = query.toLowerCase().trim();
    final snapshot = await _firestore.collection('mangas').get();
    return snapshot.docs
        .map((doc) => MangaModel.fromMap(doc.data()))
        .where((manga) => manga.title.toLowerCase().contains(lower))
        .toList();
  }

  Stream<List<MangaModel>> getFollowingMangas(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .snapshots()
        .asyncMap((followSnap) async {
      if (followSnap.docs.isEmpty) return [];
      final creatorIds = followSnap.docs.map((d) => d.id).toList();
      final mangaSnap = await _firestore
          .collection('mangas')
          .where('creatorId', whereIn: creatorIds)
          .get();
      return mangaSnap.docs
          .map((doc) => MangaModel.fromMap(doc.data()))
          .toList();
    });
  }

  Future<void> toggleBookmark(String userId, MangaModel manga) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(manga.id);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
      await _firestore.collection('users').doc(userId).update({
        'bookmarksCount': FieldValue.increment(-1),
      });
    } else {
      await ref.set({
        'mangaId': manga.id,
        'title': manga.title,
        'coverUrl': manga.coverUrl,
        'totalChapters': manga.totalChapters,
        'addedAt': DateTime.now().toIso8601String(),
      });
      await _firestore.collection('users').doc(userId).update({
        'bookmarksCount': FieldValue.increment(1),
      });
    }
  }

  Future<bool> isBookmarked(String userId, String mangaId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(mangaId)
        .get();
    return doc.exists;
  }

  Stream<List<Map<String, dynamic>>> getBookmarks(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Future<void> toggleFollow(String currentUserId, String creatorId) async {
    final followingRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(creatorId);
    final followerRef = _firestore
        .collection('users')
        .doc(creatorId)
        .collection('followers')
        .doc(currentUserId);

    final doc = await followingRef.get();

    if (doc.exists) {
      await followingRef.delete();
      await followerRef.delete();
      await _firestore.collection('users').doc(currentUserId).update({
        'followingCount': FieldValue.increment(-1),
      });
      await _firestore.collection('users').doc(creatorId).update({
        'followersCount': FieldValue.increment(-1),
      });
    } else {
      await followingRef.set({
        'creatorId': creatorId,
        'followedAt': DateTime.now().toIso8601String(),
      });
      await followerRef.set({
        'userId': currentUserId,
        'followedAt': DateTime.now().toIso8601String(),
      });
      await _firestore.collection('users').doc(currentUserId).update({
        'followingCount': FieldValue.increment(1),
      });
      await _firestore.collection('users').doc(creatorId).update({
        'followersCount': FieldValue.increment(1),
      });
    }
  }

  Future<bool> isFollowing(String currentUserId, String creatorId) async {
    final doc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(creatorId)
        .get();
    return doc.exists;
  }

  Stream<int> getFollowerCount(String creatorId) {
    return _firestore
        .collection('users')
        .doc(creatorId)
        .snapshots()
        .map((doc) => doc.data()?['followersCount'] ?? 0);
  }

  Future<void> updateManga(String mangaId, Map<String, dynamic> data) async {
    await _firestore.collection('mangas').doc(mangaId).update(data);
  }

  Future<void> incrementChaptersRead(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'chaptersRead': FieldValue.increment(1),
    });
  }

  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) return UserModel.fromMap(doc.data()!);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Stream<UserModel> getUserStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .where((doc) => doc.exists)
        .map((doc) => UserModel.fromMap(doc.data()!));
  }

  Future<List<UserModel>> getAllUsers(String currentUserId) async {
    final snap = await _firestore.collection('users').get();
    return snap.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .where((user) => user.uid != currentUserId)
        .toList();
  }

  String _conversationId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<ConversationModel> getOrCreateConversation({
    required String currentUserId,
    required String currentUserName,
    required String currentUserPhoto,
    required String otherUserId,
    required String otherUserName,
    required String otherUserPhoto,
  }) async {
    final convId = _conversationId(currentUserId, otherUserId);
    final ref = _firestore.collection('conversations').doc(convId);
    final doc = await ref.get();

    if (doc.exists) {
      return ConversationModel.fromMap(doc.data()!);
    }

    final conversation = ConversationModel(
      id: convId,
      participantIds: [currentUserId, otherUserId],
      participantNames: {
        currentUserId: currentUserName,
        otherUserId: otherUserName,
      },
      participantPhotos: {
        currentUserId: currentUserPhoto,
        otherUserId: otherUserPhoto,
      },
      nicknames: {},
      lastMessage: '',
      lastSenderId: '',
      lastMessageAt: DateTime.now(),
      unreadCount: {
        currentUserId: 0,
        otherUserId: 0,
      },
    );

    await ref.set(conversation.toMap());
    return conversation;
  }

  Stream<List<ConversationModel>> getConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ConversationModel.fromMap(doc.data()))
            .toList());
  }

  Stream<ConversationModel> getConversationStream(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .snapshots()
        .where((doc) => doc.exists)
        .map((doc) => ConversationModel.fromMap(doc.data()!));
  }

  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => MessageModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
    required String otherUserId,
    MessageType type = MessageType.text,
    String? mediaUrl,
    String? replyToId,
    String? replyToText,
    String? replyToSenderName,
  }) async {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final message = MessageModel(
      id: messageId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      createdAt: DateTime.now(),
      type: type,
      mediaUrl: mediaUrl,
      replyToId: replyToId,
      replyToText: replyToText,
      replyToSenderName: replyToSenderName,
    );

    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    final displayText = type == MessageType.image
        ? '📷 Photo'
        : type == MessageType.video
            ? '🎥 Video'
            : text;

    await _firestore.collection('conversations').doc(conversationId).update({
      'lastMessage': displayText,
      'lastSenderId': senderId,
      'lastMessageAt': DateTime.now().toIso8601String(),
      'unreadCount.$otherUserId': FieldValue.increment(1),
    });
  }

  Future<void> editMessage({
    required String conversationId,
    required String messageId,
    required String newText,
  }) async {
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .update({
      'text': newText,
      'isEdited': true,
    });
  }

  Future<void> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .update({
      'isDeleted': true,
      'text': 'This message was deleted',
      'mediaUrl': null,
    });
  }

  Future<void> toggleReaction({
    required String conversationId,
    required String messageId,
    required String emoji,
    required String userId,
  }) async {
    final ref = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId);

    final doc = await ref.get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final rawReactions = Map<String, dynamic>.from(data['reactions'] ?? {});
    final users = List<String>.from(rawReactions[emoji] ?? []);

    if (users.contains(userId)) {
      users.remove(userId);
    } else {
      users.add(userId);
    }

    if (users.isEmpty) {
      rawReactions.remove(emoji);
    } else {
      rawReactions[emoji] = users;
    }

    await ref.update({'reactions': rawReactions});
  }

  Future<void> updateNickname({
    required String conversationId,
    required String userId,
    required String nickname,
  }) async {
    await _firestore.collection('conversations').doc(conversationId).update({
      'nicknames.$userId': nickname,
    });
  }

  Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    await _firestore.collection('conversations').doc(conversationId).update({
      'unreadCount.$userId': 0,
    });
  }

  Stream<int> getTotalUnreadCount(String userId) {
    return _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((snap) {
      int total = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final unread = data['unreadCount'] as Map<String, dynamic>? ?? {};
        total += (unread[userId] as num? ?? 0).toInt();
      }
      return total;
    });
  }
}