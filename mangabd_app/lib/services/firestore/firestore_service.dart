import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/manga_model.dart';
import '../../models/chapter_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Manga ──

  // Get all mangas
  Stream<List<MangaModel>> getMangas() {
    return _firestore
        .collection('mangas')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MangaModel.fromMap(doc.data()))
            .toList());
  }

  // Get mangas by creator
  Stream<List<MangaModel>> getMangasByCreator(String creatorId) {
    return _firestore
        .collection('mangas')
        .where('creatorId', isEqualTo: creatorId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MangaModel.fromMap(doc.data()))
            .toList());
  }

  // Add manga
  Future<void> addManga(MangaModel manga) async {
    await _firestore
        .collection('mangas')
        .doc(manga.id)
        .set(manga.toMap());
  }

  // Delete manga
  Future<void> deleteManga(String mangaId) async {
    await _firestore.collection('mangas').doc(mangaId).delete();
  }

  // ── Chapter ──

  // Get chapters by manga
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

  // Add chapter
  Future<void> addChapter(ChapterModel chapter) async {
    await _firestore
        .collection('mangas')
        .doc(chapter.mangaId)
        .collection('chapters')
        .doc(chapter.id)
        .set(chapter.toMap());

    // Update total chapters count
    await _firestore
        .collection('mangas')
        .doc(chapter.mangaId)
        .update({'totalChapters': FieldValue.increment(1)});
  }

  // Delete chapter
  Future<void> deleteChapter(String mangaId, String chapterId) async {
    await _firestore
        .collection('mangas')
        .doc(mangaId)
        .collection('chapters')
        .doc(chapterId)
        .delete();

    await _firestore
        .collection('mangas')
        .doc(mangaId)
        .update({'totalChapters': FieldValue.increment(-1)});
  }
}