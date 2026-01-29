import 'package:aishwarya_gold/res/constants/urls.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  String? _currentSessionId;
  
  // Callbacks
  Function(Map<String, dynamic>)? onInitiate;
  Function(Map<String, dynamic>)? onAutoResponse;
  Function(Map<String, dynamic>)? onReceiveMessage;
  Function(Map<String, dynamic>)? onAdminJoined;
  Function(Map<String, dynamic>)? onSessionResolved;
  Function(Map<String, dynamic>)? onSessionReopened;
  Function(Map<String, dynamic>)? onRequestFeedback;
  Function(Map<String, dynamic>)? onConcluded;
  Function(String)? onError;

  bool get isConnected => _socket?.connected ?? false;
  String? get currentSessionId => _currentSessionId;

  // Refresh token before connecting
  Future<String?> _refreshTokenIfNeeded(String currentToken) async {
    try {
      // Check if token is expired or about to expire
      final parts = currentToken.split('.');
      if (parts.length != 3) return currentToken;
      
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );
      
      final exp = payload['exp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      // If token expires in less than 5 minutes, refresh it
      if (exp - now < 300) {
        
        final refreshToken = await SessionManager.getRefreshToken();
        if (refreshToken == null) {
          return null;
        }
        
        // Call your refresh token endpoint
        final response = await http.post(
          Uri.parse('${AppUrl.localUrl}/auth/refresh'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'refreshToken': refreshToken}),
        );
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final newAccessToken = data['accessToken'];
          
          // Save new token
          await SessionManager.saveAccessToken(newAccessToken);
          return newAccessToken;
        } else {
          return null;
        }
      }
      
      return currentToken;
    } catch (e) {
      return currentToken;
    }
  }

  // Initialize socket connection
  Future<void> connect(String token) async {
    if (_socket?.connected ?? false) {
      return;
    }

    try {
      // Refresh token if needed
      final validToken = await _refreshTokenIfNeeded(token);
      
      if (validToken == null) {
        onError?.call('Token refresh failed. Please login again.');
        return;
      }

      _socket = IO.io(
        '${AppUrl.localUrl}',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(5)
            .setAuth({'token': validToken})
            .build(),
      );
      print(token);

      _setupListeners();
      _socket!.connect();
    } catch (e) {
      onError?.call('Connection failed: $e');
    }
  }

  // Setup all socket event listeners
  void _setupListeners() {
    _socket!.onConnect((_) {
    });

    _socket!.onDisconnect((_) {
    });

    _socket!.onConnectError((error) {
      
      // Check if it's an authentication error
      if (error.toString().contains('Authentication error') || 
          error.toString().contains('jwt expired')) {
        onError?.call('Session expired. Please login again.');
      } else {
        onError?.call('Connection error: $error');
      }
    });

    _socket!.onError((error) {
  
    });

    // Initial options when user connects
    _socket!.on('chat:initiate', (data) {
      onInitiate?.call(data as Map<String, dynamic>);
    });

    // Auto-response after topic selection
    _socket!.on('chat:auto_response', (data) {
      final response = data as Map<String, dynamic>;
      
      final sessionId = response['sessionId'];
      if (sessionId != null) {
        _currentSessionId = sessionId.toString();
      }
      
      onAutoResponse?.call(response);
    });

    // Receive chat messages
    _socket!.on('chat:receive_message', (data) {
      onReceiveMessage?.call(data as Map<String, dynamic>);
    });

    // Admin joined notification
    _socket!.on('chat:admin_joined', (data) {
      onAdminJoined?.call(data as Map<String, dynamic>);
    });

    // Session resolved by admin
    _socket!.on('chat:session_resolved', (data) {
      onSessionResolved?.call(data as Map<String, dynamic>);
    });

    // Session reopened
    _socket!.on('chat:session_reopened', (data) {
      onSessionReopened?.call(data as Map<String, dynamic>);
    });

    // Feedback request
    _socket!.on('chat:request_feedback', (data) {
      onRequestFeedback?.call(data as Map<String, dynamic>);
    });

    // Chat concluded
    _socket!.on('chat:concluded', (data) {
      onConcluded?.call(data as Map<String, dynamic>);
      _currentSessionId = null;
    });

    // Error handling
    _socket!.on('chat:error', (data) {
      final error = data as Map<String, dynamic>;
      onError?.call(error['message'] ?? 'Unknown error');
    });
  }

  // Select initial topic
  void selectTopic(String topic) {
    if (!isConnected) {
      onError?.call('Socket not connected');
      return;
    }

    _socket!.emit('chat:select_topic', {'topic': topic});
  }

  // Send message
  void sendMessage(String sessionId, String senderId, String message) {
    if (!isConnected) {
      onError?.call('Socket not connected');
      return;
    }

    _socket!.emit('chat:send_message', {
      'sessionId': sessionId,
      'senderId': senderId,
      'senderModel': 'User',
      'message': message,
    });
  }

  // End chat
  void endChat(String sessionId) {
    if (!isConnected) {
      onError?.call('Socket not connected');
      return;
    }

    _socket!.emit('chat:end', {'sessionId': sessionId});
  }

  // Submit feedback
  void submitFeedback(String sessionId, String feedback) {
    if (!isConnected) {
      onError?.call('Socket not connected');
      return;
    }

    _socket!.emit('chat:submit_feedback', {
      'sessionId': sessionId,
      'feedback': feedback,
    });
  }

  // Sync chat data
  void syncChat(String sessionId) {
    if (!isConnected) {
      onError?.call('Socket not connected');
      return;
    }

    _socket!.emit('chat:sync', {'sessionId': sessionId});
  }

  // Disconnect
  void disconnect() {
    if (_socket != null) {
      debugPrint('🔌 Disconnecting socket');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _currentSessionId = null;
    }
  }
}