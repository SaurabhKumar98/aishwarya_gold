// // services/socket_service.dart
// import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
// import 'package:aishwarya_gold/data/models/settingmodels/message%20models.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;


// class SocketService {
//   static final SocketService _instance = SocketService._internal();
//   factory SocketService() => _instance;
//   SocketService._internal();

//   IO.Socket? _socket;
//   bool _isConnected = false;

//   // Callbacks
//   Function(Map<String, dynamic>)? onInitiate;
//   Function(ChatSession, ChatMessage)? onAutoResponse;
//   Function(ChatMessage)? onReceiveMessage;
//   Function(String)? onAdminJoined;
//   Function(String)? onSessionResolved;
//   Function(Map<String, dynamic>)? onRequestFeedback;
//   Function(String, String, String)? onConcluded;
//   Function(ChatSession, List<ChatMessage>)? onSyncData;
//   Function(String)? onError;
//   Function(ChatSession)? onSessionReopened;

//   bool get isConnected => _isConnected;

//   // Connect to socket server
//   Future<void> connect(String serverUrl, String accessToken) async {
//     if (_isConnected) {
//       print('Socket already connected');
//       return;
//     }

//     _socket = IO.io(
//       serverUrl,
//       IO.OptionBuilder()
//           .setTransports(['websocket'])
//           .enableAutoConnect()
//           .setAuth({'token': accessToken})
//           .build(),
//     );

//     _socket!.onConnect((_) {
//       _isConnected = true;
//       print('✅ Socket connected: ${_socket!.id}');
//     });

//     _socket!.onDisconnect((_) {
//       _isConnected = false;
//       print('❌ Socket disconnected');
//     });

//     _socket!.onConnectError((error) {
//       print('Connection error: $error');
//       onError?.call(error.toString());
//     });

//     _socket!.onError((error) {
//       print('Socket error: $error');
//       onError?.call(error.toString());
//     });

//     _setupListeners();
//   }

//   void _setupListeners() {
//     // Initial options when user connects
//     _socket!.on('chat:initiate', (data) {
//       print('📩 Received initiate: $data');
//       onInitiate?.call(data);
//     });

//     // Auto-response after topic selection
//     _socket!.on('chat:auto_response', (data) {
//       print('📩 Received auto_response: $data');
//       final session = ChatSession.fromJson(data['session'] ?? {});
//       final message = ChatMessage.fromJson(data['message']);
//       onAutoResponse?.call(session, message);
//     });

//     // Incoming message
//     _socket!.on('chat:receive_message', (data) {
//       print('📩 Received message: $data');
//       final message = ChatMessage.fromJson(data);
//       onReceiveMessage?.call(message);
//     });

//     // Admin joined
//     _socket!.on('chat:admin_joined', (data) {
//       print('📩 Admin joined: $data');
//       onAdminJoined?.call(data['message'] ?? 'Admin joined');
//     });

//     // Session resolved
//     _socket!.on('chat:session_resolved', (data) {
//       print('📩 Session resolved: $data');
//       onSessionResolved?.call(data['message'] ?? 'Chat resolved');
//     });

//     // Request feedback
//     _socket!.on('chat:request_feedback', (data) {
//       print('📩 Request feedback: $data');
//       onRequestFeedback?.call(data);
//     });

//     // Chat concluded
//     _socket!.on('chat:concluded', (data) {
//       print('📩 Chat concluded: $data');
//       onConcluded?.call(
//         data['sessionId'],
//         data['feedback'],
//         data['status'],
//       );
//     });

//     // Sync data
//     _socket!.on('chat:sync_data', (data) {
//       print('📩 Sync data received');
//       final session = ChatSession.fromJson(data['session']);
//       final messages = (data['messages'] as List)
//           .map((m) => ChatMessage.fromJson(m))
//           .toList();
//       onSyncData?.call(session, messages);
//     });

//     // Session reopened
//     _socket!.on('chat:session_reopened', (data) {
//       print('📩 Session reopened: $data');
//       final session = ChatSession.fromJson(data['session']);
//       onSessionReopened?.call(session);
//     });

//     // Error handling
//     _socket!.on('chat:error', (data) {
//       print('❌ Chat error: $data');
//       onError?.call(data['message'] ?? 'Unknown error');
//     });
//   }

//   // Emit events
//   void selectTopic(String topic) {
//     if (!_isConnected) {
//       print('Cannot select topic: Socket not connected');
//       return;
//     }
//     print('📤 Selecting topic: $topic');
//     _socket!.emit('chat:select_topic', {'topic': topic});
//   }

//   void sendMessage({
//     required String sessionId,
//     required String senderId,
//     required String senderModel,
//     required String message,
//   }) {
//     if (!_isConnected) {
//       print('Cannot send message: Socket not connected');
//       return;
//     }
//     print('📤 Sending message: $message');
//     _socket!.emit('chat:send_message', {
//       'sessionId': sessionId,
//       'senderId': senderId,
//       'senderModel': senderModel,
//       'message': message,
//     });
//   }

//   void syncSession(String sessionId) {
//     if (!_isConnected) {
//       print('Cannot sync: Socket not connected');
//       return;
//     }
//     print('📤 Syncing session: $sessionId');
//     _socket!.emit('chat:sync', {'sessionId': sessionId});
//   }

//   void endChat(String sessionId) {
//     if (!_isConnected) {
//       print('Cannot end chat: Socket not connected');
//       return;
//     }
//     print('📤 Ending chat: $sessionId');
//     _socket!.emit('chat:end', {'sessionId': sessionId});
//   }

//   void submitFeedback(String sessionId, String feedback) {
//     if (!_isConnected) {
//       print('Cannot submit feedback: Socket not connected');
//       return;
//     }
//     print('📤 Submitting feedback: $feedback');
//     _socket!.emit('chat:submit_feedback', {
//       'sessionId': sessionId,
//       'feedback': feedback,
//     });
//   }

//   void disconnect() {
//     if (_socket != null) {
//       _socket!.disconnect();
//       _socket!.dispose();
//       _socket = null;
//       _isConnected = false;
//       print('Socket disconnected and disposed');
//     }
//   }
// }


// // repositories/chat_repository.dart


// class ChatRepository {
//   final SocketService _socketService = SocketService();
  
//   // Your server URL - update this to match your backend
//   static const String _serverUrl = 'http://192.168.0.126:8000'; // For development
//   // For production: 'https://your-domain.com'

//   Future<void> initialize() async {
//     final token = await SessionManager.getAccessToken();
//     if (token == null) {
//       throw Exception('No access token found');
//     }

//     await _socketService.connect(_serverUrl, token);
//   }

//   // Set up listeners
//   void setupListeners({
//     Function(Map<String, dynamic>)? onInitiate,
//     Function(ChatSession, ChatMessage)? onAutoResponse,
//     Function(ChatMessage)? onReceiveMessage,
//     Function(String)? onAdminJoined,
//     Function(String)? onSessionResolved,
//     Function(Map<String, dynamic>)? onRequestFeedback,
//     Function(String, String, String)? onConcluded,
//     Function(ChatSession, List<ChatMessage>)? onSyncData,
//     Function(String)? onError,
//     Function(ChatSession)? onSessionReopened,
//   }) {
//     _socketService.onInitiate = onInitiate;
//     _socketService.onAutoResponse = onAutoResponse;
//     _socketService.onReceiveMessage = onReceiveMessage;
//     _socketService.onAdminJoined = onAdminJoined;
//     _socketService.onSessionResolved = onSessionResolved;
//     _socketService.onRequestFeedback = onRequestFeedback;
//     _socketService.onConcluded = onConcluded;
//     _socketService.onSyncData = onSyncData;
//     _socketService.onError = onError;
//     _socketService.onSessionReopened = onSessionReopened;
//   }

//   // Actions
//   void selectTopic(String topic) {
//     _socketService.selectTopic(topic);
//   }

//   Future<void> sendMessage({
//     required String sessionId,
//     required String message,
//   }) async {
//     final userId = await SessionManager.getUserId();
//     if (userId == null) {
//       throw Exception('User ID not found');
//     }

//     _socketService.sendMessage(
//       sessionId: sessionId,
//       senderId: userId,
//       senderModel: 'User',
//       message: message,
//     );
//   }

//   void syncSession(String sessionId) {
//     _socketService.syncSession(sessionId);
//   }

//   void endChat(String sessionId) {
//     _socketService.endChat(sessionId);
//   }

//   void submitFeedback(String sessionId, String feedback) {
//     _socketService.submitFeedback(sessionId, feedback);
//   }

//   bool get isConnected => _socketService.isConnected;

//   void dispose() {
//     _socketService.disconnect();
//   }
// }