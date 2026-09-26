import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';

class ChatApiService {
  final ApiClient apiClient;

  ChatApiService({required this.apiClient});

  /// Retrieve paginated conversations for the current user
  Future<List<ConversationModel>> getConversations({
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final response = await apiClient.get<List<ConversationModel>>(
        '/api/v1/chat/conversations',
        queryParameters: {'limit': limit, 'offset': offset},
        parser: (data) {
          if (data is List) {
            return data
                .map((c) => ConversationModel.fromJson(c as Map<String, dynamic>))
                .toList();
          }
          return <ConversationModel>[];
        },
      );
      return response.data ?? [];
    } catch (e) {
      debugPrint('[ChatApiService] getConversations error: $e');
      rethrow;
    }
  }

  /// Create a new conversational session
  Future<ConversationModel> createConversation() async {
    try {
      final response = await apiClient.post<ConversationModel>(
        '/api/v1/chat/conversations',
        data: {},
        parser: (data) => ConversationModel.fromJson(data as Map<String, dynamic>),
      );
      return response.data!;
    } catch (e) {
      debugPrint('[ChatApiService] createConversation error: $e');
      rethrow;
    }
  }

  /// Retrieve full conversation details with message history
  Future<ConversationModel> getConversation(String conversationId) async {
    try {
      final response = await apiClient.get<ConversationModel>(
        '/api/v1/chat/conversations/$conversationId',
        parser: (data) => ConversationModel.fromJson(data as Map<String, dynamic>),
      );
      return response.data!;
    } catch (e) {
      debugPrint('[ChatApiService] getConversation error: $e');
      rethrow;
    }
  }

  /// Send message to conversation and receive assistant response
  Future<ChatMessageModel> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final response = await apiClient.post<ChatMessageModel>(
        '/api/v1/chat/conversations/$conversationId/messages',
        data: {'content': content},
        parser: (data) => ChatMessageModel.fromJson(data as Map<String, dynamic>),
      );
      return response.data!;
    } catch (e) {
      debugPrint('[ChatApiService] sendMessage error: $e');
      rethrow;
    }
  }
}
