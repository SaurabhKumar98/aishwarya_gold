// import 'package:aishwarya_gold/data/models/settingmodels/chatmessage_models.dart';
// import 'package:flutter/foundation.dart';
// import 'package:aishwarya_gold/data/repo/settingrepo/supportchat_repo/supportchat_repo.dart';
// import 'package:aishwarya_gold/core/storage/sharedpreference.dart';

// class SocketChatProvider extends ChangeNotifier {
//   final SocketService _socketService = SocketService();
  
//   bool _isConnected = false;
//   bool _isLoadingChat = false;
//   bool _isSendingMessage = false;
//   bool _showTopicSelection = false;
//   bool _showFeedbackDialog = false;
//   bool _needsReauthentication = false;
  
//   String? _currentSessionId;
//   String? _errorMessage;
//   String? _userId;
  
//   List<SupportChat> _chatMessages = [];
//   List<String> _topicOptions = [];
//   List<String> _feedbackOptions = [];

//   // Getters
//   bool get isConnected => _isConnected;
//   bool get isLoadingChat => _isLoadingChat;
//   bool get isSendingMessage => _isSendingMessage;
//   bool get showTopicSelection => _showTopicSelection;
//   bool get showFeedbackDialog => _showFeedbackDialog;
//   bool get needsReauthentication => _needsReauthentication;
//   String? get currentSessionId => _currentSessionId;
//   String? get errorMessage => _errorMessage;
//   List<SupportChat> get chatMessages => _chatMessages;
//   List<String> get topicOptions => _topicOptions;
//   List<String> get feedbackOptions => _feedbackOptions;

//   // Initialize socket connection
//   Future<void> initialize(String token, String userId) async {
//     _userId = userId;
//     _isLoadingChat = true;
//     _needsReauthentication = false;
//     notifyListeners();

//     try {
//       // Setup callbacks
//       _socketService.onInitiate = _handleInitiate;
//       _socketService.onAutoResponse = _handleAutoResponse;
//       _socketService.onReceiveMessage = _handleReceiveMessage;
//       _socketService.onAdminJoined = _handleAdminJoined;
//       _socketService.onSessionResolved = _handleSessionResolved;
//       _socketService.onSessionReopened = _handleSessionReopened;
//       _socketService.onRequestFeedback = _handleRequestFeedback;
//       _socketService.onConcluded = _handleConcluded;
//       _socketService.onError = _handleError;

//       // Connect to socket
//       await _socketService.connect(token);
//       _isConnected = true;
//       _errorMessage = null;
//     } catch (e) {
//       _errorMessage = 'Failed to connect: $e';
//       _isConnected = false;
      
//       // Check if it's an authentication issue
//       if (e.toString().contains('Authentication') || 
//           e.toString().contains('jwt expired')) {
//         _needsReauthentication = true;
//       }
//     } finally {
//       _isLoadingChat = false;
//       notifyListeners();
//     }
//   }

//   // Retry connection with fresh token
//   Future<void> retryConnection() async {
//     debugPrint('🔄 Retrying connection...');
    
//     final token = await SessionManager.getAccessToken();
//     final userId = await SessionManager.getUserId();
    
//     if (token != null && userId != null) {
//       await initialize(token, userId);
//     } else {
//       _errorMessage = 'Please login again';
//       _needsReauthentication = true;
//       notifyListeners();
//     }
//   }

//   // Handle initial topic options
//   void _handleInitiate(Map<String, dynamic> data) {
//     debugPrint('📥 Handling initiate: $data');
//     final message = data['message'] as String?;
//     final options = (data['options'] as List?)?.cast<String>() ?? [];
    
//     if (message != null) {
//       _chatMessages.add(SupportChat(
//         message: message,
//         timestamp: DateTime.now(),
//         isUser: false,
//       ));
//     }
    
//     _topicOptions = options;
//     _showTopicSelection = true;
//     notifyListeners();
//   }

//   // Handle auto-response after topic selection
//   void _handleAutoResponse(Map<String, dynamic> data) {
//     debugPrint('📥 Handling auto response: $data');
    
//     final sessionId = data['sessionId'];
//     if (sessionId != null) {
//       _currentSessionId = sessionId.toString();
//       debugPrint('✅ Session ID received: $_currentSessionId');
//     }
    
//     final messageData = data['message'];
    
//     if (messageData != null) {
//       String? messageText;
      
//       if (messageData is Map<String, dynamic>) {
//         messageText = messageData['message'] as String?;
//       } else if (messageData is String) {
//         messageText = messageData;
//       }
      
//       if (messageText != null && messageText.isNotEmpty) {
//         debugPrint('💬 Adding auto-response message: $messageText');
//         _chatMessages.add(SupportChat(
//           message: messageText,
//           timestamp: DateTime.now(),
//           isUser: false,
//         ));
//       }
//     }
    
//     _showTopicSelection = false;
//     notifyListeners();
//   }

//   // Handle incoming messages
//   void _handleReceiveMessage(Map<String, dynamic> data) {
//     debugPrint('📥 Handling received message: $data');
    
//     final senderId = data['sender']?.toString();
//     final message = data['message'] as String?;
//     final senderModel = data['senderModel'] as String?;
    
//     if (message != null && message.isNotEmpty) {
//       final isFromCurrentUser = senderId == _userId;
      
//       if (!isFromCurrentUser) {
//         _chatMessages.add(SupportChat(
//           message: message,
//           timestamp: DateTime.now(),
//           isUser: senderModel == 'User',
//         ));
//         notifyListeners();
//       }
//     }
//   }

//   // Handle admin joined notification
//   void _handleAdminJoined(Map<String, dynamic> data) {
//     debugPrint('📥 Handling admin joined: $data');
//     final message = data['message'] as String?;
//     if (message != null) {
//       _chatMessages.add(SupportChat(
//         message: message,
//         timestamp: DateTime.now(),
//         isUser: false,
//         isSystemMessage: true,
//       ));
//       notifyListeners();
//     }
//   }

//   // Handle session resolved
//   void _handleSessionResolved(Map<String, dynamic> data) {
//     debugPrint('📥 Handling session resolved: $data');
//     final message = data['message'] as String?;
//     if (message != null) {
//       _chatMessages.add(SupportChat(
//         message: message,
//         timestamp: DateTime.now(),
//         isUser: false,
//         isSystemMessage: true,
//       ));
//       notifyListeners();
//     }
//   }

//   // Handle session reopened
//   void _handleSessionReopened(Map<String, dynamic> data) {
//     debugPrint('📥 Handling session reopened: $data');
//     _chatMessages.add(SupportChat(
//       message: 'Chat session has been reopened.',
//       timestamp: DateTime.now(),
//       isUser: false,
//       isSystemMessage: true,
//     ));
//     notifyListeners();
//   }

//   // Handle feedback request
//   void _handleRequestFeedback(Map<String, dynamic> data) {
//     debugPrint('📥 Handling feedback request: $data');
//     final message = data['message'] as String?;
//     final options = (data['options'] as List?)?.cast<String>() ?? [];
    
//     if (message != null) {
//       _chatMessages.add(SupportChat(
//         message: message,
//         timestamp: DateTime.now(),
//         isUser: false,
//       ));
//     }
    
//     _feedbackOptions = options;
//     _showFeedbackDialog = true;
//     notifyListeners();
//   }

//   // Handle chat concluded
//   void _handleConcluded(Map<String, dynamic> data) {
//     debugPrint('📥 Handling chat concluded: $data');
//     final status = data['status'] as String?;
    
//     _chatMessages.add(SupportChat(
//       message: 'Chat session ended. Status: ${status ?? "unknown"}',
//       timestamp: DateTime.now(),
//       isUser: false,
//       isSystemMessage: true,
//     ));
    
//     _showFeedbackDialog = false;
//     _currentSessionId = null;
//     notifyListeners();
//   }

//   // Handle errors
//   void _handleError(String error) {
//     debugPrint('❌ Error: $error');
//     _errorMessage = error;
    
//     // Check if it's an authentication error
//     if (error.contains('Session expired') || 
//         error.contains('login again') ||
//         error.contains('Authentication')) {
//       _needsReauthentication = true;
//       _isConnected = false;
//     }
    
//     notifyListeners();
//   }

//   // Select a topic to start chat
//   void selectTopic(String topic) {
//     debugPrint('🔘 Selecting topic: $topic');
    
//     _chatMessages.add(SupportChat(
//       message: topic,
//       timestamp: DateTime.now(),
//       isUser: true,
//     ));
    
//     _socketService.selectTopic(topic);
//     notifyListeners();
//   }

//   // Send a message
//   Future<void> sendMessage(String message) async {
//     if (_currentSessionId == null || _userId == null) {
//       _errorMessage = 'No active chat session';
//       notifyListeners();
//       return;
//     }

//     _isSendingMessage = true;
//     notifyListeners();

//     try {
//       _chatMessages.add(SupportChat(
//         message: message,
//         timestamp: DateTime.now(),
//         isUser: true,
//       ));

//       _socketService.sendMessage(_currentSessionId!, _userId!, message);
//       _errorMessage = null;
//     } catch (e) {
//       _errorMessage = 'Failed to send message: $e';
//     } finally {
//       _isSendingMessage = false;
//       notifyListeners();
//     }
//   }

//   // End chat session
//   void endChat() {
//     if (_currentSessionId == null) return;
//     _socketService.endChat(_currentSessionId!);
//   }

//   // Submit feedback
//   void submitFeedback(String feedback) {
//     if (_currentSessionId == null) return;
//     _socketService.submitFeedback(_currentSessionId!, feedback);
//     _showFeedbackDialog = false;
//     notifyListeners();
//   }

//   // Clear error message
//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }

//   // Disconnect socket
//   void disconnect() {
//     _socketService.disconnect();
//     _isConnected = false;
//     _chatMessages.clear();
//     _currentSessionId = null;
//     notifyListeners();
//   }

//   @override
//   void dispose() {
//     disconnect();
//     super.dispose();
//   }
// }


import 'package:aishwarya_gold/data/models/settingmodels/chatmessage_models.dart';
import 'package:flutter/foundation.dart';
import 'package:aishwarya_gold/data/repo/settingrepo/supportchat_repo/supportchat_repo.dart';
import 'package:aishwarya_gold/core/storage/sharedpreference.dart';

class SocketChatProvider extends ChangeNotifier {
  final SocketService _socketService = SocketService();
  
  bool _isConnected = false;
  bool _isLoadingChat = false;
  bool _isSendingMessage = false;
  bool _showTopicSelection = false;
  bool _showFeedbackDialog = false;
  bool _needsReauthentication = false;
  
  String? _currentSessionId;
  String? _errorMessage;
  String? _userId;
  
  List<SupportChat> _chatMessages = [];
  List<String> _topicOptions = [];
  List<String> _feedbackOptions = [];

  // Getters
  bool get isConnected => _isConnected;
  bool get isLoadingChat => _isLoadingChat;
  bool get isSendingMessage => _isSendingMessage;
  bool get showTopicSelection => _showTopicSelection;
  bool get showFeedbackDialog => _showFeedbackDialog;
  bool get needsReauthentication => _needsReauthentication;
  String? get currentSessionId => _currentSessionId;
  String? get errorMessage => _errorMessage;
  List<SupportChat> get chatMessages => _chatMessages;
  List<String> get topicOptions => _topicOptions;
  List<String> get feedbackOptions => _feedbackOptions;

  // Initialize socket connection
  Future<void> initialize(String token, String userId) async {
    _userId = userId;
    _isLoadingChat = true;
    _needsReauthentication = false;
    notifyListeners();

    try {
      // Setup callbacks
      _socketService.onInitiate = _handleInitiate;
      _socketService.onAutoResponse = _handleAutoResponse;
      _socketService.onReceiveMessage = _handleReceiveMessage;
      _socketService.onAdminJoined = _handleAdminJoined;
      _socketService.onSessionResolved = _handleSessionResolved;
      _socketService.onSessionReopened = _handleSessionReopened;
      _socketService.onRequestFeedback = _handleRequestFeedback;
      _socketService.onConcluded = _handleConcluded;
      _socketService.onError = _handleError;

      // Connect to socket
      await _socketService.connect(token);
      _isConnected = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to connect: $e';
      _isConnected = false;
      
      // Check if it's an authentication issue
      if (e.toString().contains('Authentication') || 
          e.toString().contains('jwt expired')) {
        _needsReauthentication = true;
      }
    } finally {
      _isLoadingChat = false;
      notifyListeners();
    }
  }

  // Retry connection with fresh token
  Future<void> retryConnection() async {
    debugPrint('🔄 Retrying connection...');
    
    final token = await SessionManager.getAccessToken();
    final userId = await SessionManager.getUserId();
    
    if (token != null && userId != null) {
      await initialize(token, userId);
    } else {
      _errorMessage = 'Please login again';
      _needsReauthentication = true;
      notifyListeners();
    }
  }

  // Handle initial topic options
  void _handleInitiate(Map<String, dynamic> data) {
    debugPrint('📥 Handling initiate: $data');
    final message = data['message'] as String?;
    final options = (data['options'] as List?)?.cast<String>() ?? [];
    
    if (message != null) {
      _chatMessages.add(SupportChat(
        message: message,
        timestamp: DateTime.now(),
        isUser: false,
      ));
    }
    
    _topicOptions = options;
    _showTopicSelection = true;
    notifyListeners();
  }

  // Handle auto-response after topic selection
  void _handleAutoResponse(Map<String, dynamic> data) {
    debugPrint('📥 Handling auto response: $data');
    
    final sessionId = data['sessionId'];
    if (sessionId != null) {
      _currentSessionId = sessionId.toString();
      debugPrint('✅ Session ID received: $_currentSessionId');
    }
    
    final messageData = data['message'];
    
    if (messageData != null) {
      String? messageText;
      
      if (messageData is Map<String, dynamic>) {
        messageText = messageData['message'] as String?;
      } else if (messageData is String) {
        messageText = messageData;
      }
      
      if (messageText != null && messageText.isNotEmpty) {
        debugPrint('💬 Adding auto-response message: $messageText');
        _chatMessages.add(SupportChat(
          message: messageText,
          timestamp: DateTime.now(),
          isUser: false,
        ));
      }
    }
    
    _showTopicSelection = false;
    notifyListeners();
  }

  // Handle incoming messages
  void _handleReceiveMessage(Map<String, dynamic> data) {
    debugPrint('📥 Handling received message: $data');
    
    final senderId = data['sender']?.toString();
    final message = data['message'] as String?;
    final senderModel = data['senderModel'] as String?;
    
    if (message != null && message.isNotEmpty) {
      final isFromCurrentUser = senderId == _userId;
      
      if (!isFromCurrentUser) {
        _chatMessages.add(SupportChat(
          message: message,
          timestamp: DateTime.now(),
          isUser: senderModel == 'User',
        ));
        notifyListeners();
      }
    }
  }

  // Handle admin joined notification
  void _handleAdminJoined(Map<String, dynamic> data) {
    debugPrint('📥 Handling admin joined: $data');
    final message = data['message'] as String?;
    if (message != null) {
      _chatMessages.add(SupportChat(
        message: message,
        timestamp: DateTime.now(),
        isUser: false,
        isSystemMessage: true,
      ));
      notifyListeners();
    }
  }

  // Handle session resolved
  void _handleSessionResolved(Map<String, dynamic> data) {
    debugPrint('📥 Handling session resolved: $data');
    final message = data['message'] as String?;
    if (message != null) {
      _chatMessages.add(SupportChat(
        message: message,
        timestamp: DateTime.now(),
        isUser: false,
        isSystemMessage: true,
      ));
      notifyListeners();
    }
  }

  // Handle session reopened
  void _handleSessionReopened(Map<String, dynamic> data) {
    debugPrint('📥 Handling session reopened: $data');
    _chatMessages.add(SupportChat(
      message: 'Chat session has been reopened.',
      timestamp: DateTime.now(),
      isUser: false,
      isSystemMessage: true,
    ));
    notifyListeners();
  }

  // Handle feedback request
  void _handleRequestFeedback(Map<String, dynamic> data) {
    debugPrint('📥 Handling feedback request: $data');
    final message = data['message'] as String?;
    final options = (data['options'] as List?)?.cast<String>() ?? [];
    
    if (message != null) {
      _chatMessages.add(SupportChat(
        message: message,
        timestamp: DateTime.now(),
        isUser: false,
      ));
    }
    
    _feedbackOptions = options;
    _showFeedbackDialog = true;
    notifyListeners();
  }

  // Handle chat concluded
  void _handleConcluded(Map<String, dynamic> data) {
    debugPrint('📥 Handling chat concluded: $data');
    final status = data['status'] as String?;
    
    _chatMessages.add(SupportChat(
      message: 'Chat session ended. Status: ${status ?? "unknown"}',
      timestamp: DateTime.now(),
      isUser: false,
      isSystemMessage: true,
    ));
    
    _showFeedbackDialog = false;
    _currentSessionId = null;
    notifyListeners();
  }

  // Handle errors
  void _handleError(String error) {
    debugPrint('❌ Error: $error');
    _errorMessage = error;
    
    // Check if it's an authentication error
    if (error.contains('Session expired') || 
        error.contains('login again') ||
        error.contains('Authentication')) {
      _needsReauthentication = true;
      _isConnected = false;
    }
    
    notifyListeners();
  }

  // Select a topic to start chat
  void selectTopic(String topic) {
    debugPrint('🔘 Selecting topic: $topic');
    
    _chatMessages.add(SupportChat(
      message: topic,
      timestamp: DateTime.now(),
      isUser: true,
    ));
    
    _socketService.selectTopic(topic);
    notifyListeners();
  }

  // Send a message
  Future<void> sendMessage(String message) async {
    if (_currentSessionId == null || _userId == null) {
      _errorMessage = 'No active chat session';
      notifyListeners();
      return;
    }

    _isSendingMessage = true;
    notifyListeners();

    try {
      _chatMessages.add(SupportChat(
        message: message,
        timestamp: DateTime.now(),
        isUser: true,
      ));

      _socketService.sendMessage(_currentSessionId!, _userId!, message);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to send message: $e';
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  // End chat session
  void endChat() {
    if (_currentSessionId == null) return;
    _socketService.endChat(_currentSessionId!);
  }

  // Submit feedback
  void submitFeedback(String feedback) {
    if (_currentSessionId == null) return;
    
    // Reset dialog flag FIRST to prevent multiple dialogs
    _showFeedbackDialog = false;
    
    // Then submit the feedback
    _socketService.submitFeedback(_currentSessionId!, feedback);
    
    notifyListeners();
  }

  // ADDED: Reset feedback dialog flag without notifying listeners
  void resetFeedbackDialogFlag() {
    _showFeedbackDialog = false;
    // Don't call notifyListeners() here to avoid rebuilds
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Disconnect socket
  void disconnect() {
    _socketService.disconnect();
    _isConnected = false;
    _chatMessages.clear();
    _currentSessionId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}