import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/manga_model.dart';
import '../../models/chapter_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MangaModel>> getMangas() {
    return _firestore
        .collection('mangas')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MangaModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Stream<List<MangaModel>> getMangasByCreator(String creatorId) {
    return _firestore
        .collection('mangas')
        .where('creatorId', isEqualTo: creatorId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MangaModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> addManga(MangaModel manga) async {
    await _firestore.collection('mangas').doc(manga.id).set(manga.toMap());
  }

  Future<void> deleteManga(String mangaId) async {
    await _firestore.collection('mangas').doc(mangaId).delete();
  }

  Stream<List<ChapterModel>> getChapters(String mangaId) {
    return _firestore
        .collection('mangas')
        .doc(mangaId)
        .collection('chapters')
        .orderBy('chapterNumber')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChapterModel.fromMap(doc.data()))
              .toList(),
        );
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
    });
  }

  Future<void> deleteChapter(String mangaId, String chapterId) async {
    await _firestore
        .collection('mangas')
        .doc(mangaId)
        .collection('chapters')
        .doc(chapterId)
        .delete();

    await _firestore.collection('mangas').doc(mangaId).update({
      'totalChapters': FieldValue.increment(-1),
    });
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
    } else {
      await ref.set({
        'mangaId': manga.id,
        'title': manga.title,
        'coverUrl': manga.coverUrl,
        'totalChapters': manga.totalChapters,
        'addedAt': DateTime.now().toIso8601String(),
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
    final batch = _firestore.batch();

    if (doc.exists) {
      batch.delete(followingRef);
      batch.delete(followerRef);
    } else {
      batch.set(followingRef, {
        'creatorId': creatorId,
        'followedAt': DateTime.now().toIso8601String(),
      });
      batch.set(followerRef, {
        'userId': currentUserId,
        'followedAt': DateTime.now().toIso8601String(),
      });
    }
    await batch.commit();
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
        .collection('followers')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<void> updateManga(String mangaId, Map<String, dynamic> data) async {
    await _firestore.collection('mangas').doc(mangaId).update(data);
  }
}
