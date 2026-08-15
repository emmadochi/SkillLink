import '../../../../core/network/api_client.dart';
import '../models/chat_model.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> getConversation(int partnerId);
  Future<bool> sendMessage(int receiverId, String message, {String messageType = 'text', String? mediaUrl, int? mediaDuration});
  Future<Map<String, dynamic>?> uploadMedia(String filePath);
  Future<List<ChatConversation>> getChatHistory();
}

class ChatRepositoryImpl implements ChatRepository {
  final ApiClient _apiClient;

  ChatRepositoryImpl(this._apiClient);

  @override
  Future<List<ChatMessage>> getConversation(int partnerId) async {
    final response = await _apiClient.getConversation(partnerId);
    return response.data ?? [];
  }

  @override
  Future<bool> sendMessage(int receiverId, String message, {String messageType = 'text', String? mediaUrl, int? mediaDuration}) async {
    final response = await _apiClient.sendMessage({
      'receiver_id': receiverId,
      'message': message,
      'message_type': messageType,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (mediaDuration != null) 'media_duration': mediaDuration,
    });
    return response.status == 'success';
  }

  @override
  Future<Map<String, dynamic>?> uploadMedia(String filePath) async {
    final response = await _apiClient.uploadChatMedia(filePath);
    if (response.status == 'success' && response.data != null) {
      return response.data;
    }
    return null;
  }

  @override
  Future<List<ChatConversation>> getChatHistory() async {
    final response = await _apiClient.getChatHistory();
    return response.data ?? [];
  }
}
