import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../providers/chat_provider.dart';
import '../../data/models/chat_model.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(chatHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Messages',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSurface,
                )),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: historyAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.outline.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('No messages yet', style: AppTypography.bodyLg.copyWith(color: AppColors.outline)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: chats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, i) => _ChatTile(
              chat: chats[i],
              onTap: () => context.push('${AppRoutes.chat}/${chats[i].partnerId}'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatConversation chat;
  final VoidCallback onTap;

  const _ChatTile({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(
                chat.partnerAvatar ?? 'https://i.pravatar.cc/80?u=${chat.partnerId}'),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(chat.partnerName,
                      style: Theme.of(context).textTheme.titleSmall),
                  const Spacer(),
                  Text(_formatTime(chat.lastTime),
                      style: Theme.of(context).textTheme.labelSmall),
                ]),
                const SizedBox(height: 4),
                Text(
                  chat.lastMessage ?? 'No messages',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.outline),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return '';
    try {
      final date = DateTime.parse(timeStr);
      return DateFormat('h:mm a').format(date);
    } catch (e) {
      return timeStr;
    }
  }
}
