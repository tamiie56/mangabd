import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy',
            style: TextStyle(fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    child: const Icon(Icons.privacy_tip_outlined,
                        color: Color(0xFF00C853), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last updated',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF4A7A55),
                          ),
                        ),
                        Text(
                          'January 2025',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF00C853),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _PolicySection(
              isDark: isDark,
              title: '1. Information We Collect',
              content:
                  'We collect information you provide directly to us when you create an account, including your display name, email address, and profile photo. We also collect information about how you use MangaBD, such as manga you read, bookmark, and creators you follow.',
            ),
            _PolicySection(
              isDark: isDark,
              title: '2. How We Use Your Information',
              content:
                  'We use the information we collect to provide, maintain, and improve our services. This includes personalizing your reading experience, showing you content from creators you follow, and managing your bookmarks and reading history.',
            ),
            _PolicySection(
              isDark: isDark,
              title: '3. Data Storage',
              content:
                  'Your account data is stored securely using Google Firebase and Cloud Firestore. Profile photos and manga cover images are stored on Cloudinary. We take reasonable measures to protect your personal information from unauthorized access.',
            ),
            _PolicySection(
              isDark: isDark,
              title: '4. Information Sharing',
              content:
                  'We do not sell, trade, or otherwise transfer your personal information to third parties. Your display name and profile photo may be visible to other users of MangaBD. Your email address is never shared publicly.',
            ),
            _PolicySection(
              isDark: isDark,
              title: '5. Creator Content',
              content:
                  'If you register as a Creator, the manga and chapters you upload will be publicly visible to all MangaBD users. You are responsible for ensuring you have the rights to any content you upload.',
            ),
            _PolicySection(
              isDark: isDark,
              title: '6. Account Deletion',
              content:
                  'You may request deletion of your account at any time. Upon deletion, your personal information will be removed from our systems. Content you have uploaded as a Creator may remain on the platform.',
            ),
            _PolicySection(
              isDark: isDark,
              title: '7. Changes to This Policy',
              content:
                  'We may update this Privacy Policy from time to time. We will notify you of any changes by updating the date at the top of this policy. Continued use of MangaBD after changes constitutes acceptance of the updated policy.',
            ),
            _PolicySection(
              isDark: isDark,
              title: '8. Contact Us',
              content:
                  'If you have any questions about this Privacy Policy, please contact us through our GitHub repository at github.com/tamiie56/mangabd.',
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                '© 2025 MangaBD. All rights reserved.',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF4A7A55)
                      : const Color(0xFF9CA3AF),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final bool isDark;
  final String title;
  final String content;

  const _PolicySection({
    required this.isDark,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132718) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0D1F12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? const Color(0xFF4A7A55)
                  : const Color(0xFF6B7280),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}