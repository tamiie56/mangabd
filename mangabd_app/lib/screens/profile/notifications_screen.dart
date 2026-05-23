import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _newChapterAlerts = true;
  bool _newFollowerAlerts = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _newChapterAlerts = prefs.getBool('notif_new_chapter') ?? true;
        _newFollowerAlerts = prefs.getBool('notif_new_follower') ?? true;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChapterAlert(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_new_chapter', value);
    setState(() => _newChapterAlerts = value);
  }

  Future<void> _saveFollowerAlert(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_new_follower', value);
    setState(() => _newFollowerAlerts = value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00C853)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF00C853).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: Color(0xFF00C853), size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Manage which notifications you want to receive.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4A7A55),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined,
                          size: 16, color: Color(0xFF00C853)),
                      const SizedBox(width: 6),
                      const Text(
                        'Alert Settings',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00C853),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF132718) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.2 : 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _NotifTile(
                          isDark: isDark,
                          icon: Icons.auto_stories_outlined,
                          title: 'New Chapter Alerts',
                          subtitle:
                              'Get notified when a creator you follow uploads a new chapter',
                          value: _newChapterAlerts,
                          onChanged: _saveChapterAlert,
                        ),
                        Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: const Color(0xFF00C853).withValues(alpha: 0.1),
                        ),
                        _NotifTile(
                          isDark: isDark,
                          icon: Icons.person_add_outlined,
                          title: 'New Follower Alerts',
                          subtitle:
                              'Get notified when someone follows you',
                          value: _newFollowerAlerts,
                          onChanged: _saveFollowerAlert,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifTile({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value
                  ? const Color(0xFF00C853).withValues(alpha: 0.12)
                  : const Color(0xFF4A7A55).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: value
                  ? const Color(0xFF00C853)
                  : const Color(0xFF4A7A55),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0D1F12),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4A7A55),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF00C853),
            activeTrackColor: const Color(0xFF00C853).withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}