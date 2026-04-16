import 'package:flutter/foundation.dart';
import '../../data/models/chat_model.dart';

const String _myId = 'bakery_owner';

class ChatProvider extends ChangeNotifier {
  final List<ChatConversation> _conversations = [
    ChatConversation(
      id: 'c1',
      participantName: 'Alisher Karimov',
      participantRole: 'Xaridor',
      lastMessage: 'Buyurtmam qachon tayyor bo\'ladi?',
      lastMessageTime: DateTime(2026, 4, 16, 12, 30),
      unreadCount: 2,
    ),
    ChatConversation(
      id: 'c2',
      participantName: 'Malika Yusupova',
      participantRole: 'Xaridor',
      lastMessage: "Rahmat, juda mazali edi!",
      lastMessageTime: DateTime(2026, 4, 16, 10, 15),
      unreadCount: 0,
    ),
    ChatConversation(
      id: 'c3',
      participantName: 'Toshkent Tegirmon',
      participantRole: "Ta'minotchi",
      lastMessage: 'Un yetkazib beramiz, ertaga soat 9da',
      lastMessageTime: DateTime(2026, 4, 15, 17, 45),
      unreadCount: 1,
    ),
    ChatConversation(
      id: 'c4',
      participantName: 'Sardor (Kuryer)',
      participantRole: 'Yetkazuvchi',
      lastMessage: "Buyurtmani olib ketdim, yo'lda",
      lastMessageTime: DateTime(2026, 4, 16, 11, 0),
      unreadCount: 0,
    ),
  ];

  final Map<String, List<ChatMessage>> _messages = {
    'c1': [
      ChatMessage(
        id: 'm1',
        senderId: 'c1',
        text: "Assalomu alaykum, qoqon patir buyurtma qildim",
        timestamp: DateTime(2026, 4, 16, 9, 20),
        isRead: true,
      ),
      ChatMessage(
        id: 'm2',
        senderId: _myId,
        text: "Vaalaykum assalom! Buyurtmangizni qabul qildik",
        timestamp: DateTime(2026, 4, 16, 9, 25),
        isRead: true,
      ),
      ChatMessage(
        id: 'm3',
        senderId: 'c1',
        text: 'Qachon tayyor bo\'ladi?',
        timestamp: DateTime(2026, 4, 16, 12, 20),
        isRead: false,
      ),
      ChatMessage(
        id: 'm4',
        senderId: 'c1',
        text: "Buyurtmam qachon tayyor bo'ladi?",
        timestamp: DateTime(2026, 4, 16, 12, 30),
        isRead: false,
      ),
    ],
    'c2': [
      ChatMessage(
        id: 'm5',
        senderId: 'c2',
        text: "Buyurtma uchun rahmat",
        timestamp: DateTime(2026, 4, 16, 9, 0),
        isRead: true,
      ),
      ChatMessage(
        id: 'm6',
        senderId: _myId,
        text: "Marhamat! Yana buyurtma bering",
        timestamp: DateTime(2026, 4, 16, 9, 5),
        isRead: true,
      ),
      ChatMessage(
        id: 'm7',
        senderId: 'c2',
        text: "Rahmat, juda mazali edi!",
        timestamp: DateTime(2026, 4, 16, 10, 15),
        isRead: true,
      ),
    ],
    'c3': [
      ChatMessage(
        id: 'm8',
        senderId: _myId,
        text: '50 kg un kerak, bor ekanmi?',
        timestamp: DateTime(2026, 4, 15, 15, 0),
        isRead: true,
      ),
      ChatMessage(
        id: 'm9',
        senderId: 'c3',
        text: "Ha, bor. Narxi 8,500 so'm kg",
        timestamp: DateTime(2026, 4, 15, 15, 30),
        isRead: true,
      ),
      ChatMessage(
        id: 'm10',
        senderId: _myId,
        text: 'Kelishildi, 50 kg olamiz',
        timestamp: DateTime(2026, 4, 15, 16, 0),
        isRead: true,
      ),
      ChatMessage(
        id: 'm11',
        senderId: 'c3',
        text: 'Un yetkazib beramiz, ertaga soat 9da',
        timestamp: DateTime(2026, 4, 15, 17, 45),
        isRead: false,
      ),
    ],
    'c4': [
      ChatMessage(
        id: 'm12',
        senderId: _myId,
        text: "#1004 buyurtmani olib keting",
        timestamp: DateTime(2026, 4, 16, 10, 30),
        isRead: true,
      ),
      ChatMessage(
        id: 'm13',
        senderId: 'c4',
        text: 'Xop, 20 daqiqada kelaman',
        timestamp: DateTime(2026, 4, 16, 10, 35),
        isRead: true,
      ),
      ChatMessage(
        id: 'm14',
        senderId: 'c4',
        text: "Buyurtmani olib ketdim, yo'lda",
        timestamp: DateTime(2026, 4, 16, 11, 0),
        isRead: true,
      ),
    ],
  };

  List<ChatConversation> get conversations =>
      List.unmodifiable(_conversations)
        ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

  List<ChatMessage> getMessages(String conversationId) =>
      List.unmodifiable(_messages[conversationId] ?? []);

  int get totalUnreadCount =>
      _conversations.fold(0, (sum, c) => sum + c.unreadCount);

  void sendMessage(String conversationId, String text) {
    if (text.trim().isEmpty) return;
    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _myId,
      text: text.trim(),
      timestamp: DateTime.now(),
      isRead: true,
    );
    _messages[conversationId] = [...(_messages[conversationId] ?? []), msg];

    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      _conversations[idx] = _conversations[idx].copyWith(
        lastMessage: text.trim(),
        lastMessageTime: DateTime.now(),
      );
    }
    notifyListeners();
  }

  void markRead(String conversationId) {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;
    if (_conversations[idx].unreadCount == 0) return;
    _conversations[idx] = _conversations[idx].copyWith(unreadCount: 0);

    final msgs = _messages[conversationId];
    if (msgs != null) {
      _messages[conversationId] = msgs
          .map((m) => m.isRead ? m : m.copyWith(isRead: true))
          .toList();
    }
    notifyListeners();
  }
}
