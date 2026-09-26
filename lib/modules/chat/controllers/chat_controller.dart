import 'package:flutter/foundation.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';
import '../services/chat_api_service.dart';

class ChatController extends ChangeNotifier {
  final ChatApiService chatApiService;

  ChatController({required this.chatApiService});

  List<ConversationModel> _conversations = [];
  String? _activeConversationId;
  List<ChatMessageModel> _messages = [];

  bool _isLoadingConversations = false;
  bool _isLoadingMessages = false;
  bool _isSending = false;
  String? _errorMessage;

  List<ConversationModel> get conversations => _conversations;
  String? get activeConversationId => _activeConversationId;
  List<ChatMessageModel> get messages => _messages;

  bool get isLoadingConversations => _isLoadingConversations;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  ConversationModel? get activeConversation {
    if (_activeConversationId == null) return null;
    try {
      return _conversations.firstWhere((c) => c.id == _activeConversationId);
    } catch (_) {
      return null;
    }
  }

  /// Initialize and load conversations
  Future<void> loadConversations({bool silent = false}) async {
    if (!silent) {
      _isLoadingConversations = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final list = await chatApiService.getConversations();
      _conversations = list;

      // If no conversation currently selected and we have existing ones,
      // select the most recent one
      if (_activeConversationId == null && _conversations.isNotEmpty) {
        await selectConversation(_conversations.first.id);
      }
      _errorMessage = null;
    } catch (e) {
      debugPrint('[ChatController] loadConversations error: $e');
      _errorMessage = 'Unable to load conversations. Please try again.';
    } finally {
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  /// Select and load a specific conversation
  Future<void> selectConversation(String conversationId) async {
    _activeConversationId = conversationId;
    _isLoadingMessages = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final detail = await chatApiService.getConversation(conversationId);
      _messages = detail.messages;

      // Update in conversation list if present
      final idx = _conversations.indexWhere((c) => c.id == conversationId);
      if (idx != -1) {
        _conversations[idx] = detail;
      }
    } catch (e) {
      debugPrint('[ChatController] selectConversation error: $e');
      _errorMessage = 'Failed to load conversation history.';
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  /// Start a clean new conversation session
  void startNewConversation() {
    _activeConversationId = null;
    _messages = [];
    _errorMessage = null;
    notifyListeners();
  }

  /// Send message to current or newly created conversation
  Future<bool> sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || _isSending) return false;

    _isSending = true;
    _errorMessage = null;

    try {
      // 1. If no active conversation exists, create one first
      if (_activeConversationId == null) {
        final newConv = await chatApiService.createConversation();
        _activeConversationId = newConv.id;
        _conversations = [newConv, ..._conversations];
      }

      final convId = _activeConversationId!;

      // 2. Optimistically append user message
      final optimisticUserMessage = ChatMessageModel(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: convId,
        role: 'user',
        content: cleanText,
        createdAt: DateTime.now(),
      );
      _messages = [..._messages, optimisticUserMessage];
      notifyListeners();

      // 3. Post to backend and await assistant response
      final assistantMsg = await chatApiService.sendMessage(
        conversationId: convId,
        content: cleanText,
      );

      _messages = [..._messages, assistantMsg];

      // 4. Silently refresh conversation list to update titles/timestamps
      chatApiService.getConversations().then((updatedList) {
        _conversations = updatedList;
        notifyListeners();
      }).catchError((_) {});

      return true;
    } catch (e) {
      debugPrint('[ChatController] sendMessage error: $e');
      _errorMessage = 'Could not send message. Please try again.';
      // Add assistant error hint if conversation is active
      _messages = [
        ..._messages,
        ChatMessageModel(
          id: 'err_${DateTime.now().millisecondsSinceEpoch}',
          conversationId: _activeConversationId ?? '',
          role: 'assistant',
          content: "I'm having trouble connecting right now. Please check your internet connection or server settings and try again.",
          createdAt: DateTime.now(),
        ),
      ];
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
