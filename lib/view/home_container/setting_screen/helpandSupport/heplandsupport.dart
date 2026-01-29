
import 'package:aishwarya_gold/core/storage/sharedpreference.dart';
import 'package:aishwarya_gold/data/models/settingmodels/chatmessage_models.dart';
import 'package:aishwarya_gold/data/models/settingmodels/faqmodels.dart';
import 'package:aishwarya_gold/res/constants/app_color.dart';
import 'package:aishwarya_gold/view_models/faq_provider/faq_provider.dart';
import 'package:aishwarya_gold/view_models/supportmessage_provider/chatmessage_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  
  // ADDED: Flag to prevent multiple feedback dialogs
  bool _isFeedbackDialogShown = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load FAQs
      if (!mounted) return;
      context.read<FaqProvider>().fetchFaqs();

      // Get token and userId from SessionManager
      final token = await SessionManager.getAccessToken() ?? '';
      final userId = await SessionManager.getUserId() ?? '';

      // Initialize Socket Chat
      if (!mounted) return;
      context.read<SocketChatProvider>().initialize(token, userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    // Disconnect socket when leaving screen
    context.read<SocketChatProvider>().disconnect();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(
          title: const Text(
            "Help & Support",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            // End chat button (only visible in chat tab with active session)
            Consumer<SocketChatProvider>(
              builder: (context, provider, child) {
                if (_tabController.index == 1 &&
                    provider.currentSessionId != null) {
                  return IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'End Chat',
                    onPressed: () => _showEndChatDialog(context, provider),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.help_outline), text: "Help & Support"),
              Tab(icon: Icon(Icons.chat_bubble_outline), text: "Support Chat"),
            ],
            indicatorColor: AppColors.primaryGold,
            labelColor: AppColors.primaryGold,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildHelpSupportTab(), _buildSupportChatTab()],
        ),
      ),
    );
  }

  // ==================== FAQ TAB (UNCHANGED) ====================
  Widget _buildHelpSupportTab() {
    return Consumer<FaqProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search FAQs...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: provider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            provider.clearSearch();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                onChanged: provider.searchFAQs,
              ),
            ),

            // FAQ List
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading FAQs',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: provider.fetchFaqs,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : provider.faqs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.searchQuery.isNotEmpty
                                ? 'No FAQs found for "${provider.searchQuery}"'
                                : 'No FAQs available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.faqs.length,
                      itemBuilder: (context, index) {
                        final faq = provider.faqs[index];
                        return _buildFAQItem(faq);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFAQItem(FaqData faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            faq.tag,
            style: TextStyle(
              color: AppColors.primaryGold,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              faq.answer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SOCKET CHAT TAB (FIXED) ====================
  Widget _buildSupportChatTab() {
    return Consumer<SocketChatProvider>(
      builder: (context, provider, child) {
        // Show error snackbar if any (guard against deactivated context)
        if (provider.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.errorMessage!),
                action: SnackBarAction(
                  label: 'Dismiss',
                  onPressed: provider.clearError,
                ),
              ),
            );
            provider.clearError();
          });
        }

        // FIXED: Show feedback dialog with local flag check
        if (provider.showFeedbackDialog && !_isFeedbackDialogShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _isFeedbackDialogShown) return;
            
            // Set flag BEFORE showing dialog to prevent multiple calls
            _isFeedbackDialogShown = true;
            
            // Reset provider flag immediately to prevent rebuilds
            provider.resetFeedbackDialogFlag();
            
            // Show the dialog
            _showFeedbackDialog(context, provider);
          });
        }
        
        // Reset local flag when provider flag is false
        if (!provider.showFeedbackDialog && _isFeedbackDialogShown) {
          _isFeedbackDialogShown = false;
        }

        return Column(
          children: [
            // Connection Status Banner
            if (!provider.isConnected && !provider.isLoadingChat)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade700, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Disconnected from server',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ],
                ),
              ),

            // Chat Messages Area
            Expanded(
              child: provider.isLoadingChat
                  ? const Center(child: CircularProgressIndicator())
                  : provider.chatMessages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _chatScrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.chatMessages.length,
                      itemBuilder: (context, index) {
                        final message = provider.chatMessages[index];
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _scrollToBottom(),
                        );
                        return _buildChatMessage(message);
                      },
                    ),
            ),

            // Topic Selection (shown initially)
            if (provider.showTopicSelection) _buildTopicSelection(provider),

            // Message Input (shown after topic selected)
            if (provider.currentSessionId != null &&
                !provider.showTopicSelection)
              _buildMessageInput(provider),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Connecting to support...',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we connect you',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopicSelection(SocketChatProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a topic to start chatting:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.topicOptions.map((topic) {
              return ElevatedButton(
                onPressed: () => provider.selectTopic(topic),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: Text(topic),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(SocketChatProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.primaryGold),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryGold,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: provider.isSendingMessage
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: provider.isSendingMessage
                  ? null
                  : () {
                      final message = _chatController.text;
                      if (message.trim().isNotEmpty) {
                        provider.sendMessage(message);
                        _chatController.clear();
                        _scrollToBottom();
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(SupportChat message) {
    final isSystemMessage = message.isSystemMessage ?? false;

    // System messages (admin joined, chat ended, etc.)
    if (isSystemMessage) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          message.message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.blue.shade700,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    // Regular user/admin messages
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primaryGold : Colors.grey[200],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: message.isUser ? Colors.white70 : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DIALOGS ====================
  void _showEndChatDialog(BuildContext context, SocketChatProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('End Chat?'),
        content: const Text('Are you sure you want to end this chat session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              provider.endChat();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
            ),
            child: const Text(
              'End Chat',
              style: TextStyle(color: AppColors.backgroundLight),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, SocketChatProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Chat Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Was your issue resolved?'),
            const SizedBox(height: 16),
            ...provider.feedbackOptions.map((option) {
              return ListTile(
                title: Text(
                  option == 'resolved' ? '✅ Resolved' : '❌ Not Resolved',
                  style: const TextStyle(fontSize: 16),
                ),
                onTap: () {
                  // Close dialog first
                  Navigator.pop(dialogContext);
                  
                  // Submit feedback
                  provider.submitFeedback(option);
                  
                  // Reset local flag
                  _isFeedbackDialogShown = false;
                },
              );
            }).toList(),
          ],
        ),
      ),
    ).then((_) {
      // Also reset flag if dialog is dismissed by other means
      _isFeedbackDialogShown = false;
    });
  }

  // ==================== HELPER METHODS ====================
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}