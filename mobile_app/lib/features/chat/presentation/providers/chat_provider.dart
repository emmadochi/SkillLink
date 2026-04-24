import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/models/chat_model.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/api_client.dart';

part 'chat_provider.g.dart';

@riverpod
ChatRepository chatRepository(ChatRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  final apiClient = ApiClient(dio);
  return ChatRepositoryImpl(apiClient);
}

@Riverpod(keepAlive: true)
Future<List<ChatMessage>> conversation(ConversationRef ref, int partnerId) {
  return ref.watch(chatRepositoryProvider).getConversation(partnerId);
}

@Riverpod(keepAlive: true)
Future<List<ChatConversation>> chatHistory(ChatHistoryRef ref) {
  return ref.watch(chatRepositoryProvider).getChatHistory();
}
