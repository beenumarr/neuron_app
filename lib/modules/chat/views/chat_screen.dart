import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/chat_controller.dart';
import 'widgets/chat_empty_state.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/conversation_list_sheet.dart';
import 'widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasInput = false;

  static const List<String> _suggestionChips = [
    'What should I eat for dinner?',
    'Healthy Nigerian breakfast',
    'Analyze my diet',
    'Best recovery foods',
    'Can I eat Jollof rice?',
    'Local protein sources',
  ];

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatController>().loadConversations();
    });
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasInput) {
      setState(() {
        _hasInput = hasText;
      });
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? overrideText]) {
    final text = overrideText ?? _textController.text;
    if (text.trim().isEmpty) return;

    if (overrideText == null) {
      _textController.clear();
    }

    final chatController = context.read<ChatController>();
    chatController.sendMessage(text).then((_) {
      _scrollToBottom();
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatController = context.watch<ChatController>();
    final messages = chatController.messages;
    final isSending = chatController.isSending;
    final convCount = chatController.conversations.length;

    // Auto-scroll when messages update
    if (messages.isNotEmpty || isSending) {
      _scrollToBottom();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundPage,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Header matching design prototype
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.backgroundCard,
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // NORI AI Avatar with Brand Gradient
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.brand, AppColors.indigo],
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.zap,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title & Live status indicator
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NORI AI',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.brand,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Online · Health companion',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Chat history / Conversations list button
                  IconButton(
                    tooltip: 'Chat History',
                    icon: Badge(
                      isLabelVisible: convCount > 0,
                      label: Text(
                        '$convCount',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: AppColors.brand,
                      child: const Icon(
                        LucideIcons.messageSquare,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    onPressed: () => ConversationListSheet.show(context),
                  ),
                  // New Consultation Button
                  IconButton(
                    tooltip: 'New Chat',
                    icon: const Icon(
                      LucideIcons.edit3,
                      size: 22,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => chatController.startNewConversation(),
                  ),
                ],
              ),
            ),

            // Suggestion Chips Row (Horizontal Scroll)
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _suggestionChips.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (ctx, index) {
                  final chip = _suggestionChips[index];
                  return ActionChip(
                    label: Text(
                      chip,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brand,
                      ),
                    ),
                    backgroundColor: AppColors.brandLight,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    onPressed: () => _sendMessage(chip),
                  );
                },
              ),
            ),
            const Divider(color: AppColors.border, height: 1),

            // Chat Body (Messages / Empty State / Loading)
            Expanded(
              child: chatController.isLoadingMessages
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.brand),
                    )
                  : messages.isEmpty
                      ? ChatEmptyState(
                          onSelectPrompt: (p) => _sendMessage(p),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: messages.length + (isSending ? 1 : 0),
                          itemBuilder: (ctx, index) {
                            if (index == messages.length && isSending) {
                              return const TypingIndicator();
                            }
                            final msg = messages[index];
                            return ChatMessageBubble(message: msg);
                          },
                        ),
            ),

            // Bottom Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.backgroundCard,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Text input container
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundPage,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 4,
                              minLines: 1,
                              decoration: const InputDecoration(
                                hintText: 'Ask NORI anything…',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 11),
                              ),
                              onSubmitted: isSending ? null : (_) => _sendMessage(),
                            ),
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: AppColors.brandLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.mic,
                              size: 15,
                              color: AppColors.brand,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Send button
                  InkWell(
                    onTap: (_hasInput && !isSending) ? () => _sendMessage() : null,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (_hasInput && !isSending)
                            ? AppColors.brand
                            : AppColors.brand.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: (_hasInput && !isSending)
                            ? [
                                BoxShadow(
                                  color: AppColors.brand.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.arrowUp,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
