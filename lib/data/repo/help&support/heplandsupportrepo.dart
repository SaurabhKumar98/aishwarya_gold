// // repositories/help_support_repository.dart

// import 'dart:convert';
// import 'package:aishwarya_gold/data/models/faqmodels.dart';
// import 'package:http/http.dart' as http;

// class HelpSupportRepository {
//   static const String baseUrl = 'https://your-api-base-url.com/api';

//   // Fetch FAQs
//   Future<List<FAQModel>> getFAQs() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/faqs'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         return jsonData.map((faq) => FAQModel.fromJson(faq)).toList();
//       } else {
//         throw Exception('Failed to load FAQs');
//       }
//     } catch (e) {
//       // Return mock data for demo purposes
//       return _getMockFAQs();
//     }
//   }

//   // Send chat message
//   Future<ChatMessage> sendChatMessage(String message) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/chat'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'message': message,
//           'timestamp': DateTime.now().toIso8601String(),
//         }),
//       );

//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         return ChatMessage.fromJson(responseData);
//       } else {
//         throw Exception('Failed to send message');
//       }
//     } catch (e) {
//       // Return mock response for demo purposes
//       await Future.delayed(const Duration(seconds: 1));
//       return ChatMessage(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         message: _getMockResponse(message),
//         isUser: false,
//         timestamp: DateTime.now(),
//       );
//     }
//   }

//   // Get chat history
//   Future<List<ChatMessage>> getChatHistory() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/chat-history'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         return jsonData.map((msg) => ChatMessage.fromJson(msg)).toList();
//       } else {
//         throw Exception('Failed to load chat history');
//       }
//     } catch (e) {
//       return [];
//     }
//   }

//   // Mock data for demo
//   List<FAQModel> _getMockFAQs() {
//     return [
//       FAQModel(
//         id: '1',
//         question: 'How is my gold stored?',
//         answer: 'Your gold is stored in secure, insured vaults with 24/7 monitoring and advanced security systems.',
//         category: 'Storage',
//       ),
//       FAQModel(
//         id: '2',
//         question: 'What happens if I miss a payment?',
//         answer: 'If you miss a payment, you have a grace period of 7 days. After that, late fees may apply.',
//         category: 'Payments',
//       ),
//       FAQModel(
//         id: '3',
//         question: 'How do I redeem my savings?',
//         answer: 'You can redeem your savings through the app by going to the Investment section and selecting redeem.',
//         category: 'Redemption',
//       ),
//       FAQModel(
//         id: '4',
//         question: 'Is my investment insured?',
//         answer: 'Yes, all gold investments are fully insured against theft, loss, and damage.',
//         category: 'Insurance',
//       ),
//       FAQModel(
//         id: '5',
//         question: 'What are the current gold rates?',
//         answer: 'Gold rates are updated in real-time and can be viewed on the home screen of the app.',
//         category: 'Rates',
//       ),
//     ];
//   }

//   String _getMockResponse(String userMessage) {
//     if (userMessage.toLowerCase().contains('plan') || userMessage.toLowerCase().contains('maturity')) {
//       return "Hi! I can help with that. How can I assist you today? Could you please provide more details about your plan maturity question?";
//     } else if (userMessage.toLowerCase().contains('payment')) {
//       return "I can help you with payment-related queries. What specific information do you need?";
//     } else if (userMessage.toLowerCase().contains('gold') || userMessage.toLowerCase().contains('rate')) {
//       return "For current gold rates and related information, please check the rates section in the app. Is there anything specific you'd like to know?";
//     } else {
//       return "Thank you for choosing Aishwarya Gold! We’re happy to help you with any questions about your gold investment plan. How can we assist you today?";
//     }
//   }
// }