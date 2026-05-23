import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About', style: TextStyle(fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF00A844)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C853).withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.menu_book_rounded,
                  size: 52, color: Colors.white),
            ),
            const SizedBox(height: 16),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00E676)],
              ).createShader(bounds),
              child: const Text(
                'MangaBD',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Version 1.2.0',
                style: TextStyle(
                  color: Color(0xFF00C853),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Read · Create · Explore',
              style: TextStyle(
                color: isDark ? const Color(0xFF4A7A55) : const Color(0xFF9CA3AF),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            _InfoCard(
              isDark: isDark,
              children: [
                _InfoRow(
                  icon: Icons.info_outline_rounded,
                  label: 'App Name',
                  value: 'MangaBD',
                  isDark: isDark,
                ),
                _Divider(),
                _InfoRow(
                  icon: Icons.tag_rounded,
                  label: 'Version',
                  value: '1.2.0',
                  isDark: isDark,
                ),
                _Divider(),
                _InfoRow(
                  icon: Icons.phone_android_rounded,
                  label: 'Platform',
                  value: 'Android & Web',
                  isDark: isDark,
                ),
                _Divider(),
                _InfoRow(
                  icon: Icons.code_rounded,
                  label: 'Built with',
                  value: 'Flutter + Firebase',
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              isDark: isDark,
              children: [
                _InfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Developer',
                  value: 'tamiie56',
                  isDark: isDark,
                ),
                _Divider(),
                _InfoRow(
                  icon: Icons.flag_outlined,
                  label: 'Country',
                  value: 'Bangladesh 🇧🇩',
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              isDark: isDark,
              children: [
                _InfoRow(
                  icon: Icons.storage_outlined,
                  label: 'Database',
                  value: 'Cloud Firestore',
                  isDark: isDark,
                ),
                _Divider(),
                _InfoRow(
                  icon: Icons.cloud_outlined,
                  label: 'Storage',
                  value: 'Cloudinary',
                  isDark: isDark,
                ),
                _Divider(),
                _InfoRow(
                  icon: Icons.lock_outline_rounded,
                  label: 'Auth',
                  value: 'Firebase Auth',
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              '© 2025 MangaBD. All rights reserved.',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF4A7A55)
                    : const Color(0xFF9CA3AF),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _InfoCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132718) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF00C853)),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFF4A7A55) : const Color(0xFF9CA3AF),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0D1F12),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: const Color(0xFF00C853).withValues(alpha: 0.1),
    );
  }
}