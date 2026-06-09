import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/chat_model.dart';
import '../../services/firestore/firestore_service.dart';
import '../profile/user_profile_screen.dart';

class ChatInfoScreen extends StatefulWidget {
  final ConversationModel conversation;
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserPhoto;

  const ChatInfoScreen({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserPhoto,
  });

  @override
  State<ChatInfoScreen> createState() => _ChatInfoScreenState();
}

class _ChatInfoScreenState extends State<ChatInfoScreen> {
  final _firestoreService = FirestoreService();
  bool _isMuted = false;
  bool _isBlocked = false;
  List<MessageModel> _mediaMessages = [];
  bool _loadingMedia = false;
  late ConversationModel _conversation;

  @override
  void initState() {
    super.initState();
    _conversation = widget.conversation;
    _loadMedia();
    _loadBlockStatus();
  }

  Future<void> _loadMedia() async {
    setState(() => _loadingMedia = true);
    final messages = await _firestoreService.getMediaMessages(
      widget.conversation.id,
    );
    if (mounted) {
      setState(() {
        _mediaMessages = messages;
        _loadingMedia = false;
      });
    }
  }

  Future<void> _loadBlockStatus() async {
    try {
      final blocked = await _firestoreService.isBlocked(
        widget.currentUserId,
        widget.otherUserId,
      );
      if (mounted) setState(() => _isBlocked = blocked);
    } catch (e) {
      if (mounted) setState(() => _isBlocked = false);
    }
  }

  String _getDisplayName(String userId) {
    final nickname = _conversation.nicknames[userId];
    if (nickname != null && nickname.isNotEmpty) return nickname;
    return _conversation.participantNames[userId] ?? '';
  }

  void _showNicknameDialog(bool isDark) {
    final myNickController = TextEditingController(
      text: _conversation.nicknames[widget.currentUserId] ?? '',
    );
    final otherNickController = TextEditingController(
      text: _conversation.nicknames[widget.otherUserId] ?? '',
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        title: const Text(
          'Edit Nicknames',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: myNickController,
              decoration: InputDecoration(
                labelText: 'Your nickname',
                labelStyle: const TextStyle(color: Color(0xFF4A7A55)),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00C853)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: otherNickController,
              decoration: InputDecoration(
                labelText: '${widget.otherUserName}\'s nickname',
                labelStyle: const TextStyle(color: Color(0xFF4A7A55)),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00C853)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF4A7A55)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (myNickController.text.trim().isNotEmpty) {
                await _firestoreService.updateNickname(
                  conversationId: widget.conversation.id,
                  userId: widget.currentUserId,
                  nickname: myNickController.text.trim(),
                );
              }
              if (otherNickController.text.trim().isNotEmpty) {
                await _firestoreService.updateNickname(
                  conversationId: widget.conversation.id,
                  userId: widget.otherUserId,
                  nickname: otherNickController.text.trim(),
                );
              }
              final updated = await _firestoreService.getConversationOnce(
                widget.conversation.id,
              );
              if (updated != null && mounted) {
                setState(() => _conversation = updated);
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF00C853),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        title: const Text(
          'Clear Chat',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Are you sure you want to delete all messages in this chat?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF4A7A55)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _firestoreService.clearChat(widget.conversation.id);
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Chat cleared')));
              }
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        title: Text(
          _isBlocked ? 'Unblock User' : 'Block User',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          _isBlocked
              ? 'Unblock ${widget.otherUserName}?'
              : 'Block ${widget.otherUserName}? They won\'t be able to send you messages.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF4A7A55)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _firestoreService.toggleBlock(
                widget.currentUserId,
                widget.otherUserId,
              );
              final blocked = await _firestoreService.isBlocked(
                widget.currentUserId,
                widget.otherUserId,
              );
              if (mounted) setState(() => _isBlocked = blocked);
            },
            child: Text(
              _isBlocked ? 'Unblock' : 'Block',
              style: TextStyle(
                color: _isBlocked ? const Color(0xFF00C853) : Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final myDisplayName = _getDisplayName(widget.currentUserId);
    final otherDisplayName = _getDisplayName(widget.otherUserId);

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
          'Chat Info',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF0D1F12),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFF00C853),
              backgroundImage: widget.otherUserPhoto.isNotEmpty
                  ? NetworkImage(widget.otherUserPhoto)
                  : null,
              child: widget.otherUserPhoto.isEmpty
                  ? Text(
                      otherDisplayName.isNotEmpty
                          ? otherDisplayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 14),
            Text(
              otherDisplayName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0D1F12),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.otherUserName,
              style: const TextStyle(color: Color(0xFF4A7A55), fontSize: 14),
            ),
            const SizedBox(height: 28),
            _buildSection(
              title: 'Chat Info',
              isDark: isDark,
              children: [
                _buildTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  isDark: isDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          UserProfileScreen(userId: widget.otherUserId),
                    ),
                  ),
                ),
              ],
            ),
            _buildSection(
              title: 'Customize Chat',
              isDark: isDark,
              children: [
                _buildTile(
                  icon: Icons.edit_rounded,
                  label: 'Edit Nicknames',
                  isDark: isDark,
                  onTap: () => _showNicknameDialog(isDark),
                  subtitle: 'You: $myDisplayName  •  Them: $otherDisplayName',
                ),
                _buildSwitchTile(
                  icon: Icons.notifications_outlined,
                  label: 'Mute Notifications',
                  isDark: isDark,
                  value: _isMuted,
                  onChanged: (val) => setState(() => _isMuted = val),
                ),
              ],
            ),
            _buildSection(
              title: 'Media & Files',
              isDark: isDark,
              children: [_buildMediaGrid(isDark)],
            ),
            _buildSection(
              title: 'Privacy & Support',
              isDark: isDark,
              children: [
                _buildTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'Clear Chat',
                  isDark: isDark,
                  color: Colors.orange,
                  onTap: () => _showClearChatDialog(isDark),
                ),
                _buildTile(
                  icon: _isBlocked ? Icons.block_rounded : Icons.block_rounded,
                  label: _isBlocked ? 'Unblock User' : 'Block User',
                  isDark: isDark,
                  color: Colors.red,
                  onTap: () => _showBlockDialog(isDark),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF00C853),
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF132718) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    String? subtitle,
    Color? color,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (color ?? const Color(0xFF00C853)).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? const Color(0xFF00C853), size: 18),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: color ?? (isDark ? Colors.white : const Color(0xFF0D1F12)),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF4A7A55), fontSize: 11),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF4A7A55),
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String label,
    required bool isDark,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF00C853).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF00C853), size: 18),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: isDark ? Colors.white : const Color(0xFF0D1F12),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF00C853),
      ),
    );
  }

  Widget _buildMediaGrid(bool isDark) {
    if (_loadingMedia) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF00C853)),
        ),
      );
    }
    if (_mediaMessages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No media shared yet',
            style: TextStyle(color: const Color(0xFF4A7A55), fontSize: 13),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: _mediaMessages.length > 9 ? 9 : _mediaMessages.length,
        itemBuilder: (context, index) {
          final msg = _mediaMessages[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: msg.type == MessageType.image
                ? CachedNetworkImage(
                    imageUrl: msg.mediaUrl!,
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) => Container(
                      color: const Color(0xFF00C853).withValues(alpha: 0.1),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00C853),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
