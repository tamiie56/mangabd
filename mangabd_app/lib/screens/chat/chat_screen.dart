import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../../models/chat_model.dart';
import '../../services/firestore/firestore_service.dart';
import '../../services/storage/storage_service.dart';
import 'chat_info_screen.dart';

class ChatScreen extends StatefulWidget {
  final ConversationModel conversation;
  final String currentUserId;
  final String otherUserName;
  final String otherUserPhoto;

  const ChatScreen({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.otherUserName,
    required this.otherUserPhoto,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();
  final _imagePicker = ImagePicker();

  bool _showEmojiPicker = false;
  bool _isUploading = false;
  MessageModel? _replyingTo;
  MessageModel? _editingMessage;
  late ConversationModel _conversation;

  @override
  void initState() {
    super.initState();
    _conversation = widget.conversation;
    _firestoreService.markMessagesAsRead(
      conversationId: widget.conversation.id,
      userId: widget.currentUserId,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  String _getDisplayName(String userId) {
    final nickname = _conversation.nicknames[userId];
    if (nickname != null && nickname.isNotEmpty) return nickname;
    return _conversation.participantNames[userId] ?? '';
  }

  String get _otherUserId => widget.conversation.participantIds.firstWhere(
    (id) => id != widget.currentUserId,
    orElse: () => '',
  );

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    if (_editingMessage != null) {
      await _firestoreService.editMessage(
        conversationId: widget.conversation.id,
        messageId: _editingMessage!.id,
        newText: text,
      );
      setState(() => _editingMessage = null);
      return;
    }

    await _firestoreService.sendMessage(
      conversationId: widget.conversation.id,
      senderId: widget.currentUserId,
      senderName: _getDisplayName(widget.currentUserId),
      text: text,
      otherUserId: _otherUserId,
      type: _isUrl(text) ? MessageType.link : MessageType.text,
      replyToId: _replyingTo?.id,
      replyToText: _replyingTo?.text,
      replyToSenderName: _replyingTo?.senderName,
    );

    setState(() => _replyingTo = null);
    _scrollToBottom();
  }

  bool _isUrl(String text) {
    return text.startsWith('http://') ||
        text.startsWith('https://') ||
        text.startsWith('www.');
  }

  Future<void> _pickAndSendImage() async {
    final picked = await _imagePicker.pickMultiImage();
    if (picked.isEmpty) return;
    setState(() => _isUploading = true);
    try {
      for (final image in picked) {
        final bytes = await image.readAsBytes();
        final ext = image.name.split('.').last.toLowerCase();
        final url = await _storageService.uploadChatMediaBytes(
          bytes,
          ext,
          false,
        );
        if (url != null) {
          await _firestoreService.sendMessage(
            conversationId: widget.conversation.id,
            senderId: widget.currentUserId,
            senderName: _getDisplayName(widget.currentUserId),
            text: '📷 Photo',
            otherUserId: _otherUserId,
            type: MessageType.image,
            mediaUrl: url,
            replyToId: _replyingTo?.id,
            replyToText: _replyingTo?.text,
            replyToSenderName: _replyingTo?.senderName,
          );
        }
      }
      setState(() => _replyingTo = null);
      _scrollToBottom();
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _pickAndSendVideo() async {
    final picked = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _isUploading = true);
    try {
      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last.toLowerCase();
      final url = await _storageService.uploadChatMediaBytes(bytes, ext, true);
      if (url != null) {
        await _firestoreService.sendMessage(
          conversationId: widget.conversation.id,
          senderId: widget.currentUserId,
          senderName: _getDisplayName(widget.currentUserId),
          text: '🎥 Video',
          otherUserId: _otherUserId,
          type: MessageType.video,
          mediaUrl: url,
          replyToId: _replyingTo?.id,
          replyToText: _replyingTo?.text,
          replyToSenderName: _replyingTo?.senderName,
        );
        setState(() => _replyingTo = null);
        _scrollToBottom();
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showMessageOptions(MessageModel message, bool isDark) {
    final isMe = message.senderId == widget.currentUserId;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1D2E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildReactionRow(message, isDark),
            const Divider(height: 24),
            _buildOption(
              icon: Icons.reply_rounded,
              label: 'Reply',
              onTap: () {
                setState(() => _replyingTo = message);
                Navigator.pop(context);
              },
              isDark: isDark,
            ),
            if (isMe && !message.isDeleted) ...[
              _buildOption(
                icon: Icons.edit_rounded,
                label: 'Edit',
                onTap: () {
                  setState(() {
                    _editingMessage = message;
                    _messageController.text = message.text;
                  });
                  Navigator.pop(context);
                },
                isDark: isDark,
              ),
              _buildOption(
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                color: Colors.red,
                onTap: () async {
                  Navigator.pop(context);
                  await _firestoreService.deleteMessage(
                    conversationId: widget.conversation.id,
                    messageId: message.id,
                  );
                },
                isDark: isDark,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReactionRow(MessageModel message, bool isDark) {
    final emojis = ['👍', '❤️', '😂', '😮', '😢', '🔥'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: emojis.map((emoji) {
          final users = message.reactions[emoji] ?? [];
          final reacted = users.contains(widget.currentUserId);
          return GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              await _firestoreService.toggleReaction(
                conversationId: widget.conversation.id,
                messageId: message.id,
                emoji: emoji,
                userId: widget.currentUserId,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: reacted
                    ? const Color(0xFF00C853).withValues(alpha: 0.2)
                    : isDark
                    ? const Color(0xFF132718)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF00C853)),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? (isDark ? Colors.white : const Color(0xFF0D1F12)),
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDateLabel(DateTime dt) {
    final now = DateTime.now();
    if (_isSameDay(dt, now)) return 'Today';
    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(dt, yesterday)) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<ConversationModel>(
      stream: _firestoreService.getConversationStream(widget.conversation.id),
      builder: (context, convSnap) {
        if (convSnap.hasData) _conversation = convSnap.data!;
        final otherDisplayName =
            _conversation.nicknames[_otherUserId]?.isNotEmpty == true
            ? _conversation.nicknames[_otherUserId]!
            : widget.otherUserName;

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
                  color: isDark
                      ? const Color(0xFF1A3320)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF00C853),
                  size: 18,
                ),
              ),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
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
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    otherDisplayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF0D1F12),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF00C853),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatInfoScreen(
                      conversation: _conversation,
                      currentUserId: widget.currentUserId,
                      otherUserId: _otherUserId,
                      otherUserName: widget.otherUserName,
                      otherUserPhoto: widget.otherUserPhoto,
                    ),
                  ),
                ),
                tooltip: 'Chat Info',
              ),
            ],
          ),
          body: Column(
            children: [
              if (_isUploading)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: const Color(0xFF00C853).withValues(alpha: 0.1),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF00C853),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Uploading...',
                        style: TextStyle(
                          color: Color(0xFF00C853),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: StreamBuilder<List<MessageModel>>(
                  stream: _firestoreService.getMessages(widget.conversation.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00C853),
                        ),
                      );
                    }
                    final messages = snapshot.data ?? [];
                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF00C853,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 34,
                                color: Color(0xFF00C853),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Say hi to $otherDisplayName!',
                              style: const TextStyle(
                                color: Color(0xFF4A7A55),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final reversedIndex = messages.length - 1 - index;
                        final message = messages[reversedIndex];
                        final isMe = message.senderId == widget.currentUserId;
                        final showDateLabel =
                            reversedIndex == 0 ||
                            !_isSameDay(
                              messages[reversedIndex - 1].createdAt,
                              message.createdAt,
                            );
                        return Column(
                          children: [
                            if (showDateLabel)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1A3320)
                                        : const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _formatDateLabel(message.createdAt),
                                    style: const TextStyle(
                                      color: Color(0xFF4A7A55),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            _buildMessageBubble(message, isMe, isDark),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              if (_replyingTo != null) _buildReplyPreview(isDark),
              if (_editingMessage != null) _buildEditPreview(isDark),
              _buildInputBar(isDark),
              if (_showEmojiPicker)
                SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      _messageController.text += emoji.emoji;
                      _messageController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _messageController.text.length),
                      );
                    },
                    config: Config(
                      emojiViewConfig: EmojiViewConfig(
                        backgroundColor: isDark
                            ? const Color(0xFF1A1D2E)
                            : Colors.white,
                      ),
                      categoryViewConfig: CategoryViewConfig(
                        backgroundColor: isDark
                            ? const Color(0xFF1A1D2E)
                            : Colors.white,
                        iconColor: const Color(0xFF4A7A55),
                        iconColorSelected: const Color(0xFF00C853),
                        indicatorColor: const Color(0xFF00C853),
                      ),
                      searchViewConfig: SearchViewConfig(
                        backgroundColor: isDark
                            ? const Color(0xFF1A1D2E)
                            : Colors.white,
                      ),
                      bottomActionBarConfig: BottomActionBarConfig(
                        backgroundColor: isDark
                            ? const Color(0xFF1A1D2E)
                            : Colors.white,
                        buttonColor: const Color(0xFF00C853),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe, bool isDark) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(message, isDark),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72,
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: message.isDeleted
                      ? Colors.grey.withValues(alpha: 0.3)
                      : isMe
                      ? const Color(0xFF00C853)
                      : isDark
                      ? const Color(0xFF132718)
                      : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.06,
                      ),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.replyToId != null)
                      _buildReplyQuote(message, isMe, isDark),
                    if (message.isDeleted)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Text(
                          'This message was deleted',
                          style: TextStyle(
                            color: isMe ? Colors.white70 : Colors.grey,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else if (message.type == MessageType.image &&
                        message.mediaUrl != null)
                      _buildImageMessage(message)
                    else if (message.type == MessageType.video &&
                        message.mediaUrl != null)
                      _buildVideoMessage(message, isMe, isDark)
                    else if (message.type == MessageType.link)
                      _buildLinkMessage(message, isMe, isDark)
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: isMe
                                ? Colors.white
                                : isDark
                                ? Colors.white
                                : const Color(0xFF0D1F12),
                            fontSize: 15,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.createdAt),
                    style: const TextStyle(
                      color: Color(0xFF4A7A55),
                      fontSize: 10,
                    ),
                  ),
                  if (message.isEdited) ...[
                    const SizedBox(width: 4),
                    const Text(
                      'edited',
                      style: TextStyle(
                        color: Color(0xFF4A7A55),
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
              if (message.reactions.isNotEmpty)
                _buildReactions(message, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplyQuote(MessageModel message, bool isMe, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withValues(alpha: 0.2)
            : const Color(0xFF00C853).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: isMe ? Colors.white : const Color(0xFF00C853),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.replyToSenderName ?? '',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: isMe ? Colors.white : const Color(0xFF00C853),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message.replyToText ?? '',
            style: TextStyle(
              fontSize: 12,
              color: isMe ? Colors.white70 : const Color(0xFF4A7A55),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildImageMessage(MessageModel message) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: CachedNetworkImage(
        imageUrl: message.mediaUrl!,
        width: 220,
        height: 220,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 220,
          height: 220,
          color: const Color(0xFF00C853).withValues(alpha: 0.1),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF00C853)),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 220,
          height: 100,
          color: Colors.grey.withValues(alpha: 0.2),
          child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildVideoMessage(MessageModel message, bool isMe, bool isDark) {
    return GestureDetector(
      onTap: () => _openVideoPlayer(message.mediaUrl!),
      child: Container(
        width: 220,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.play_circle_fill_rounded,
              color: Colors.white,
              size: 52,
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '🎥 Video',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openVideoPlayer(String url) {
    if (kIsWeb) {
      launchUrl(Uri.parse(url));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _VideoPlayerScreen(url: url)),
    );
  }

  Widget _buildLinkMessage(MessageModel message, bool isMe, bool isDark) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(
          message.text.startsWith('www.')
              ? 'https://${message.text}'
              : message.text,
        );
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.link_rounded, color: Color(0xFF00C853), size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                message.text,
                style: TextStyle(
                  color: isMe ? Colors.white : const Color(0xFF00C853),
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactions(MessageModel message, bool isDark) {
    return Wrap(
      spacing: 4,
      children: message.reactions.entries
          .where((e) => e.value.isNotEmpty)
          .map(
            (e) => GestureDetector(
              onTap: () => _firestoreService.toggleReaction(
                conversationId: widget.conversation.id,
                messageId: message.id,
                emoji: e.key,
                userId: widget.currentUserId,
              ),
              child: Container(
                margin: const EdgeInsets.only(top: 3),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: e.value.contains(widget.currentUserId)
                      ? const Color(0xFF00C853).withValues(alpha: 0.2)
                      : isDark
                      ? const Color(0xFF1A3320)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: e.value.contains(widget.currentUserId)
                        ? const Color(0xFF00C853)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  '${e.key} ${e.value.length}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildReplyPreview(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
      child: Row(
        children: [
          Container(width: 3, height: 36, color: const Color(0xFF00C853)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _replyingTo!.senderName,
                  style: const TextStyle(
                    color: Color(0xFF00C853),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _replyingTo!.text,
                  style: const TextStyle(
                    color: Color(0xFF4A7A55),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: Color(0xFF4A7A55),
            ),
            onPressed: () => setState(() => _replyingTo = null),
          ),
        ],
      ),
    );
  }

  Widget _buildEditPreview(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
      child: Row(
        children: [
          const Icon(Icons.edit_rounded, color: Color(0xFF00C853), size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Editing message',
              style: TextStyle(
                color: Color(0xFF00C853),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: Color(0xFF4A7A55),
            ),
            onPressed: () => setState(() {
              _editingMessage = null;
              _messageController.clear();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showEmojiPicker = !_showEmojiPicker),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF132718)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _showEmojiPicker
                    ? Icons.keyboard_rounded
                    : Icons.emoji_emotions_outlined,
                color: const Color(0xFF00C853),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: _pickAndSendImage,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF132718)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.image_outlined,
                color: Color(0xFF00C853),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: _pickAndSendVideo,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF132718)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.videocam_outlined,
                color: Color(0xFF00C853),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF132718)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0D1F12),
                  fontSize: 14,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onTap: () {
                  if (_showEmojiPicker) {
                    setState(() => _showEmojiPicker = false);
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Color(0xFF4A7A55)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF00C853),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPlayerScreen extends StatefulWidget {
  final String url;
  const _VideoPlayerScreen({required this.url});

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() => _initialized = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _initialized
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            : const CircularProgressIndicator(color: Color(0xFF00C853)),
      ),
    );
  }
}
