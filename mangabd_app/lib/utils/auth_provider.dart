import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth/auth_service.dart';
import '../services/firestore/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  bool get isCreator => _user?.isCreator ?? false;

  AuthProvider() {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        _user = null;
        notifyListeners();
      } else {
        final doc =
            await _authService.getUserFromFirestore(firebaseUser.uid);
        _user = doc;
        notifyListeners();
        _firestoreService.getUserStream(firebaseUser.uid).listen((updatedUser) {
          _user = updatedUser;
          notifyListeners();
        });
      }
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
    bool isCreator = false,
  }) async {
    _setLoading(true);
    final user = await _authService.signUp(
      email: email,
      password: password,
      displayName: displayName,
      isCreator: isCreator,
    );
    _user = user;
    _setLoading(false);
    return user != null;
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    final user = await _authService.signIn(
      email: email,
      password: password,
    );
    _user = user;
    _setLoading(false);
    return user != null;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<bool> updateDisplayName(String newName) async {
    if (_user == null) return false;
    try {
      await _firestoreService.updateUserProfile(
          _user!.uid, {'displayName': newName});
      await FirebaseAuth.instance.currentUser
          ?.updateDisplayName(newName);
      _user = _user!.copyWith(displayName: newName);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePhotoUrl(String url) async {
    if (_user == null) return false;
    try {
      await _firestoreService
          .updateUserProfile(_user!.uid, {'photoUrl': url});
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(url);
      _user = _user!.copyWith(photoUrl: url);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> refreshUser() async {
    if (_user == null) return;
    final updated =
        await _firestoreService.getUserById(_user!.uid);
    if (updated != null) {
      _user = updated;
      notifyListeners();
    }
  }
}