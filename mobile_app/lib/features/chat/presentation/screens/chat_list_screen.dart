import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skilllink_empty_state.dart';
import '../providers/chat_provider.dart';
import '../../data/models/chat_model.dart';
import '../../../../core/utils/url_utils.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        ref.invalidate(chatHistoryProvider);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(chatHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Messages',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                )),
        backgroundColor: AppColors.surfaceContainerLowest,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(chatHistoryProvider.future),
        child: historyAsync.when(
          data: (chats) {
            if (chats.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: SkillLinkEmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Your Inbox is Clean',
                    message: 'When you message an artisan about a service or negotiation, your conversations will appear here.',
                    buttonLabel: 'Find an Artisan',
                    buttonIcon: Icons.search_rounded,
                    onButtonPressed: () => context.push(AppRoutes.artisanListing),
                  ),
                ),
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              itemCount: chats.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.surfaceContainerHigh),
              itemBuilder: (context, i) => _ChatTile(
                chat: chats[i],
                onTap: () {
                  final chat = chats[i];
                  context.push(
                    '${AppRoutes.chat}/${chat.partnerId}?name=${Uri.encodeComponent(chat.partnerName)}&avatar=${Uri.encodeComponent(chat.partnerAvatar ?? '')}',
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, __) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: SkillLinkEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Unable to Load Messages',
                message: 'Please verify your internet connection.',
                buttonLabel: 'Refresh',
                onButtonPressed: () => ref.refresh(chatHistoryProvider),
                accentColor: AppColors.error,
              ),
            ),
          ),
        ),
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      onTap: onTap,
      leading: CircleAvatar(
        radius: 26,
        backgroundImage: chat.partnerAvatar != null && chat.partnerAvatar!.isNotEmpty
            ? NetworkImage(UrlUtils.resolveImageUrl(chat.partnerAvatar))
            : null,
        child: chat.partnerAvatar == null || chat.partnerAvatar!.isEmpty
            ? const Icon(Icons.person, size: 26, color: AppColors.outline)
            : null,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              chat.partnerName,
              style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (chat.lastTime != null)
            Text(
              _formatTime(chat.lastTime!),
              style: AppTypography.labelSm.copyWith(color: AppColors.outline),
            ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          chat.lastMessage ?? 'Tap to chat',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySm.copyWith(color: AppColors.outline),
        ),
      ),
    );
  }

  String _formatTime(String timeStr) {
    try {
      final date = DateTime.parse(timeStr);
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        return DateFormat('h:mm a').format(date);
      }
      return DateFormat('MMM d').format(date);
    } catch (_) {
      return timeStr;
    }
  }
}
