import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
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
        if (_user == null) {
          final doc = await _authService.getUserFromFirestore(firebaseUser.uid);
          _user = doc;
          notifyListeners();
        }
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
}