import '../../../../core/network/api_client.dart';
import '../models/chat_model.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> getConversation(int partnerId);
  Future<bool> sendMessage(int receiverId, String message);
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
  Future<bool> sendMessage(int receiverId, String message) async {
    final response = await _apiClient.sendMessage({
      'receiver_id': receiverId,
      'message': message,
    });
    return response.status == 'success';
  }

  @override
  Future<List<ChatConversation>> getChatHistory() async {
    final response = await _apiClient.getChatHistory();
    return response.data ?? [];
  }
}
