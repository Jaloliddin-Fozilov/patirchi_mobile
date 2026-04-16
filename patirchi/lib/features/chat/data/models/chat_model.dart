class ChatConversation {
  final String id;
  final String participantName;
  final String participantRole;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String? avatarUrl;

  const ChatConversation({
    required this.id,
    required this.participantName,
    required this.participantRole,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.avatarUrl,
  });

  ChatConversation copyWith({
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return ChatConversation(
      id: id,
      participantName: participantName,
      participantRole: participantRole,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      avatarUrl: avatarUrl,
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  ChatMessage copyWith({bool? isRead}) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      text: text,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
