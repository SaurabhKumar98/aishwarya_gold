// // providers/help_support_provider.dart

// import 'package:aishwarya_gold/data/models/faqmodels.dart';
// import 'package:aishwarya_gold/data/repo/help&support/heplandsupportrepo.dart';
// import 'package:flutter/foundation.dart';

// class HelpSupportProvider extends ChangeNotifier {
//   final HelpSupportRepository _repository = HelpSupportRepository();

//   // FAQ related properties
//   List<FAQModel> _faqs = [];
//   List<FAQModel> _filteredFAQs = [];
//   bool _isLoadingFAQs = false;
//   String? _faqError;
//   String _searchQuery = '';

//   // Chat related properties
//   List<ChatMessage> _chatMessages = [];
//   bool _isSendingMessage = false;
//   bool _isLoadingChat = false;
//   String? _chatError;

//   // Getters
//   List<FAQModel> get faqs => _filteredFAQs.isNotEmpty || _searchQuery.isNotEmpty ? _filteredFAQs : _faqs;
//   bool get isLoadingFAQs => _isLoadingFAQs;
//   String? get faqError => _faqError;
//   String get searchQuery => _searchQuery;

//   List<ChatMessage> get chatMessages => _chatMessages;
//   bool get isSendingMessage => _isSendingMessage;
//   bool get isLoadingChat => _isLoadingChat;
//   String? get chatError => _chatError;

//   // FAQ Methods
//   Future<void> loadFAQs() async {
//     _isLoadingFAQs = true;
//     _faqError = null;
//     notifyListeners();

//     try {
//       _faqs = await _repository.getFAQs();
//       _filteredFAQs = List.from(_faqs);
//     } catch (e) {
//       _faqError = e.toString();
//     } finally {
//       _isLoadingFAQs = false;
//       notifyListeners();
//     }
//   }

//   void searchFAQs(String query) {
//     _searchQuery = query;
    
//     if (query.isEmpty) {
//       _filteredFAQs = List.from(_faqs);
//     } else {
//       _filteredFAQs = _faqs.where((faq) {
//         return faq.question.toLowerCase().contains(query.toLowerCase()) ||
//                faq.answer.toLowerCase().contains(query.toLowerCase()) ||
//                faq.category.toLowerCase().contains(query.toLowerCase());
//       }).toList();
//     }
    
//     notifyListeners();
//   }

//   void clearSearch() {
//     _searchQuery = '';
//     _filteredFAQs = List.from(_faqs);
//     notifyListeners();
//   }

//   // Chat Methods
//   Future<void> loadChatHistory() async {
//     _isLoadingChat = true;
//     _chatError = null;
//     notifyListeners();

//     try {
//       _chatMessages = await _repository.getChatHistory();
//     } catch (e) {
//       _chatError = e.toString();
//     } finally {
//       _isLoadingChat = false;
//       notifyListeners();
//     }
//   }

//   Future<void> sendMessage(String message) async {
//     if (message.trim().isEmpty) return;

//     // Add user message immediately
//     final userMessage = ChatMessage(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       message: message.trim(),
//       isUser: true,
//       timestamp: DateTime.now(),
//     );

//     _chatMessages.add(userMessage);
//     _isSendingMessage = true;
//     notifyListeners();

//     try {
//       // Send message to server and get response
//       final response = await _repository.sendChatMessage(message.trim());
//       _chatMessages.add(response);
//     } catch (e) {
//       _chatError = e.toString();
      
//       // Add error message
//       final errorMessage = ChatMessage(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         message: "Sorry, I couldn't process your message. Please try again.",
//         isUser: false,
//         timestamp: DateTime.now(),
//         status: MessageStatus.failed,
//       );
//       _chatMessages.add(errorMessage);
//     } finally {
//       _isSendingMessage = false;
//       notifyListeners();
//     }
//   }

//   void clearChat() {
//     _chatMessages.clear();
//     _chatError = null;
//     notifyListeners();
//   }

//   void retryLastMessage() {
//     if (_chatMessages.isNotEmpty && _chatMessages.last.isUser) {
//       final lastMessage = _chatMessages.last.message;
//       sendMessage(lastMessage);
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }