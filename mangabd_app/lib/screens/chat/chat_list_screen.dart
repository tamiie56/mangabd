import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/auth_provider.dart';
import '../../models/chat_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore/firestore_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _firestoreService = FirestoreService();
  bool _showUserList = false;
  List<UserModel> _allUsers = [];
  bool _loadingUsers = false;

  Future<void> _loadUsers(String currentUserId) async {
    setState(() => _loadingUsers = true);
    final users = await _firestoreService.getAllUsers(currentUserId);
    if (mounted) {
      setState(() {
        _allUsers = users;
        _loadingUsers = false;
        _showUserList = true;
      });
    }
  }

  Future<void> _openChat(UserModel otherUser, String currentUserId, String currentUserName, String currentUserPhoto) async {
    final conversation = await _firestoreService.getOrCreateConversation(
      currentUserId: currentUserId,
      currentUserName: currentUserName,
      currentUserPhoto: currentUserPhoto,
      otherUserId: otherUser.uid,
      otherUserName: otherUser.displayName,
      otherUserPhoto: otherUser.photoUrl,
    );
    if (mounted) {
      setState(() => _showUserList = false);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversation: conversation,
            currentUserId: currentUserId,
            otherUserName: otherUser.displayName,
            otherUserPhoto: otherUser.photoUrl,
          ),
        ),
      );
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF0FFF4),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                if (_showUserList) {
                  setState(() => _showUserList = false);
                } else {
                  _loadUsers(user.uid);
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A3320) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _showUserList ? Icons.close_rounded : Icons.edit_rounded,
                  color: const Color(0xFF00C853),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _showUserList
          ? _buildUserList(user, isDark)
          : _buildConversationList(user, isDark),
    );
  }

  Widget _buildUserList(dynamic user, bool isDark) {
    if (_loadingUsers) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00C853)),
      );
    }
    if (_allUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.people_outline_rounded, size: 40, color: Color(0xFF00C853)),
            ),
            const SizedBox(height: 16),
            const Text('No users found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Start a new chat',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF00C853),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _allUsers.length,
            itemBuilder: (context, index) {
              final u = _allUsers[index];
              return GestureDetector(
                onTap: () => _openChat(
                  u,
                  user.uid,
                  user.displayName,
                  user.photoUrl,
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
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
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF00C853),
                        backgroundImage: u.photoUrl.isNotEmpty
                            ? NetworkImage(u.photoUrl)
                            : null,
                        child: u.photoUrl.isEmpty
                            ? Text(
                                u.displayName.isNotEmpty
                                    ? u.displayName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              u.displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: isDark ? Colors.white : const Color(0xFF0D1F12),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              u.isCreator ? '✦ Creator' : 'Reader',
                              style: const TextStyle(
                                  color: Color(0xFF4A7A55), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: Color(0xFF00C853),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConversationList(dynamic user, bool isDark) {
    return StreamBuilder<List<ConversationModel>>(
      stream: _firestoreService.getConversations(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00C853)),
          );
        }
        final conversations = snapshot.data ?? [];
        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 40,
                    color: Color(0xFF00C853),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('No messages yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text(
                  'Tap the edit icon to start a chat',
                  style: TextStyle(color: Color(0xFF4A7A55), fontSize: 13),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conv = conversations[index];
            final otherUserId = conv.participantIds.firstWhere(
              (id) => id != user.uid,
              orElse: () => '',
            );
            final otherUserName = conv.participantNames[otherUserId] ?? 'Unknown';
            final otherUserPhoto = conv.participantPhotos[otherUserId] ?? '';
            final unread = conv.unreadCount[user.uid] ?? 0;
            final isLastMine = conv.lastSenderId == user.uid;

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    conversation: conv,
                    currentUserId: user.uid,
                    otherUserName: otherUserName,
                    otherUserPhoto: otherUserPhoto,
                  ),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
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
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(0xFF00C853),
                          backgroundImage: otherUserPhoto.isNotEmpty
                              ? NetworkImage(otherUserPhoto)
                              : null,
                          child: otherUserPhoto.isEmpty
                              ? Text(
                                  otherUserName.isNotEmpty
                                      ? otherUserName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                )
                              : null,
                        ),
                        if (unread > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00C853),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            otherUserName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: isDark ? Colors.white : const Color(0xFF0D1F12),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            conv.lastMessage.isEmpty
                                ? 'No messages yet'
                                : isLastMine
                                    ? 'You: ${conv.lastMessage}'
                                    : conv.lastMessage,
                            style: TextStyle(
                              color: unread > 0
                                  ? const Color(0xFF00C853)
                                  : const Color(0xFF4A7A55),
                              fontSize: 13,
                              fontWeight: unread > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(conv.lastMessageAt),
                          style: const TextStyle(
                              color: Color(0xFF4A7A55), fontSize: 11),
                        ),
                        if (unread > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C853),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$unread',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}