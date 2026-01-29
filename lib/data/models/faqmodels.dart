// // models/help_support_model.dart

// class FAQModel {
//   final String id;
//   final String question;
//   final String answer;
//   final String category;

//   FAQModel({
//     required this.id,
//     required this.question,
//     required this.answer,
//     required this.category,
//   });

//   factory FAQModel.fromJson(Map<String, dynamic> json) {
//     return FAQModel(
//       id: json['id'] ?? '',
//       question: json['question'] ?? '',
//       answer: json['answer'] ?? '',
//       category: json['category'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'question': question,
//       'answer': answer,
//       'category': category,
//     };
//   }
// }

// class ChatMessage {
//   final String id;
//   final String message;
//   final bool isUser;
//   final DateTime timestamp;
//   final MessageStatus status;

//   ChatMessage({
//     required this.id,
//     required this.message,
//     required this.isUser,
//     required this.timestamp,
//     this.status = MessageStatus.sent,
//   });

//   factory ChatMessage.fromJson(Map<String, dynamic> json) {
//     return ChatMessage(
//       id: json['id'] ?? '',
//       message: json['message'] ?? '',
//       isUser: json['isUser'] ?? false,
//       timestamp: DateTime.parse(json['timestamp']),
//       status: MessageStatus.values.firstWhere(
//         (e) => e.toString() == 'MessageStatus.${json['status']}',
//         orElse: () => MessageStatus.sent,
//       ),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'message': message,
//       'isUser': isUser,
//       'timestamp': timestamp.toIso8601String(),
//       'status': status.toString().split('.').last,
//     };
//   }
// }

// enum MessageStatus {
//   sending,
//   sent,
//   delivered,
//   failed,
// }