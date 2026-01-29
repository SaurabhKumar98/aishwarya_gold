// class ChatSession {
//   final String id;
//   final String userId;
//   final String userName;
//   final String? adminId;
//   final String initialTopic;
//   final String status;

//   ChatSession({
//     required this.id,
//     required this.userId,
//     required this.userName,
//     this.adminId,
//     required this.initialTopic,
//     required this.status,
//   });

//   factory ChatSession.fromJson(Map<String, dynamic> json) {
//     return ChatSession(
//       id: json['_id'] ?? '',
//       userId: json['userId'] ?? '',
//       userName: json['userName'] ?? '',
//       adminId: json['adminId'],
//       initialTopic: json['initialTopic'] ?? '',
//       status: json['status'] ?? '',
//     );
//   }
// }
