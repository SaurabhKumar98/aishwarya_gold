// models/chat_models.dart

class ChatSession {
  final String id;
  final String userId;
  final String userName;
  final String initialTopic;
  final String status; // 'open', 'resolved'
  final String? adminId;
  final String? feedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatSession({
    required this.id,
    required this.userId,
    required this.userName,
    required this.initialTopic,
    required this.status,
    this.adminId,
    this.feedback,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      initialTopic: json['initialTopic'] ?? '',
      status: json['status'] ?? 'open',
      adminId: json['adminId'],
      feedback: json['feedback'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'userName': userName,
      'initialTopic': initialTopic,
      'status': status,
      'adminId': adminId,
      'feedback': feedback,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ChatMessage {
  final String id;
  final String chatSessionId;
  final String sender;
  final String senderModel; // 'User' or 'Admin'
  final String message;
  final bool isAuto;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.chatSessionId,
    required this.sender,
    required this.senderModel,
    required this.message,
    this.isAuto = false,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? '',
      chatSessionId: json['chatSessionId'] ?? '',
      sender: json['sender'] ?? '',
      senderModel: json['senderModel'] ?? 'User',
      message: json['message'] ?? '',
      isAuto: json['isAuto'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chatSessionId': chatSessionId,
      'sender': sender,
      'senderModel': senderModel,
      'message': message,
      'isAuto': isAuto,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isFromUser => senderModel == 'User';
  bool get isFromAdmin => senderModel == 'Admin';
}