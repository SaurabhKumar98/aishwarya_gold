// data/models/settingmodels/chatmessage_models.dart

class SupportChat {
  final String message;
  final DateTime timestamp;
  final bool isUser;
  final bool? isSystemMessage;

  SupportChat({
    required this.message,
    required this.timestamp,
    required this.isUser,
    this.isSystemMessage,
  });

  factory SupportChat.fromJson(Map<String, dynamic> json) {
    return SupportChat(
      message: json['message'] ?? '',
      timestamp: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isUser: json['senderModel'] == 'User',
      isSystemMessage: json['isAuto'] ?? json['senderModel'] == 'System',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isUser': isUser,
      'isSystemMessage': isSystemMessage,
    };
  }
}