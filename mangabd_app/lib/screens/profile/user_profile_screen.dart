import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/firestore/firestore_service.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _firestoreService = FirestoreService();
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _firestoreService.getUserById(widget.userId);
    if (mounted) {
      setState(() {
        _user = user;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1117)
          : const Color(0xFFF0FFF4),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A3320) : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF00C853),
              size: 18,
            ),
          ),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF0D1F12),
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00C853)),
            )
          : _user == null
          ? const Center(child: Text('User not found'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: const Color(0xFF00C853),
                    backgroundImage: _user!.photoUrl.isNotEmpty
                        ? NetworkImage(_user!.photoUrl)
                        : null,
                    child: _user!.photoUrl.isEmpty
                        ? Text(
                            _user!.displayName.isNotEmpty
                                ? _user!.displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user!.displayName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0D1F12),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user!.isCreator ? '✦ Creator' : 'Reader',
                    style: const TextStyle(
                      color: Color(0xFF4A7A55),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStat(
                        label: 'Followers',
                        value: '${_user!.followersCount}',
                        isDark: isDark,
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: const Color(0xFF4A7A55),
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      _buildStat(
                        label: 'Following',
                        value: '${_user!.followingCount}',
                        isDark: isDark,
                      ),
                      if (_user!.isCreator) ...[
                        Container(
                          width: 1,
                          height: 36,
                          color: const Color(0xFF4A7A55),
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        _buildStat(
                          label: 'Works',
                          value: '${_user!.totalWorks}',
                          isDark: isDark,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildStat({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0D1F12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF4A7A55), fontSize: 13),
        ),
      ],
    );
  }
}
