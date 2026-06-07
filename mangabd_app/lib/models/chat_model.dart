class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;
  final bool isRead;
  final MessageType type;
  final String? mediaUrl;
  final String? replyToId;
  final String? replyToText;
  final String? replyToSenderName;
  final bool isEdited;
  final bool isDeleted;
  final Map<String, List<String>> reactions;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    this.isRead = false,
    this.type = MessageType.text,
    this.mediaUrl,
    this.replyToId,
    this.replyToText,
    this.replyToSenderName,
    this.isEdited = false,
    this.isDeleted = false,
    this.reactions = const {},
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    final rawReactions = map['reactions'] as Map<String, dynamic>? ?? {};
    final reactions = rawReactions.map(
      (emoji, users) => MapEntry(emoji, List<String>.from(users)),
    );
    return MessageModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      text: map['text'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      isRead: map['isRead'] ?? false,
      type: MessageType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      mediaUrl: map['mediaUrl'],
      replyToId: map['replyToId'],
      replyToText: map['replyToText'],
      replyToSenderName: map['replyToSenderName'],
      isEdited: map['isEdited'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      reactions: reactions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'type': type.name,
      'mediaUrl': mediaUrl,
      'replyToId': replyToId,
      'replyToText': replyToText,
      'replyToSenderName': replyToSenderName,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'reactions': reactions,
    };
  }
}

enum MessageType { text, image, video, link }

class ConversationModel {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String> participantPhotos;
  final Map<String, String> nicknames;
  final String lastMessage;
  final String lastSenderId;
  final DateTime lastMessageAt;
  final Map<String, int> unreadCount;

  ConversationModel({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantPhotos,
    this.nicknames = const {},
    required this.lastMessage,
    required this.lastSenderId,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'] ?? '',
      participantIds: List<String>.from(map['participantIds'] ?? []),
      participantNames: Map<String, String>.from(map['participantNames'] ?? {}),
      participantPhotos: Map<String, String>.from(map['participantPhotos'] ?? {}),
      nicknames: Map<String, String>.from(map['nicknames'] ?? {}),
      lastMessage: map['lastMessage'] ?? '',
      lastSenderId: map['lastSenderId'] ?? '',
      lastMessageAt: DateTime.parse(map['lastMessageAt']),
      unreadCount: Map<String, int>.from(
        (map['unreadCount'] ?? {}).map((k, v) => MapEntry(k, (v as num).toInt())),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantPhotos': participantPhotos,
      'nicknames': nicknames,
      'lastMessage': lastMessage,
      'lastSenderId': lastSenderId,
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }
}