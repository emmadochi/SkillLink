import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../artisan/presentation/providers/artisan_provider.dart';
import '../providers/chat_provider.dart';
import '../../data/models/chat_model.dart';
import '../../../auth/presentation/providers/auth_repository_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String? partnerName;
  final String? partnerAvatar;
  const ChatScreen({
    super.key, 
    required this.conversationId,
    this.partnerName,
    this.partnerAvatar,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final partnerId = int.tryParse(widget.conversationId) ?? 1;
      ref.invalidate(conversationProvider(partnerId));
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    
    final partnerId = int.tryParse(widget.conversationId) ?? 1;
    final repo = ref.read(chatRepositoryProvider);
    
    _msgCtrl.clear();
    
    try {
      await repo.sendMessage(partnerId, text);
      ref.invalidate(conversationProvider(partnerId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final partnerId = int.tryParse(widget.conversationId) ?? 1;
    final artisanAsync = ref.watch(artisanProfileProvider(partnerId));
    final messagesAsync = ref.watch(conversationProvider(partnerId));
    
    // Listen for new messages to scroll to bottom safely
    ref.listen(conversationProvider(partnerId), (previous, next) {
      if (next.hasValue && (previous?.value?.length ?? 0) < (next.value?.length ?? 0)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollCtrl.hasClients) {
            _scrollCtrl.animateTo(
              _scrollCtrl.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: artisanAsync.when(
          data: (artisan) => _buildHeader(
            artisan.user?.name ?? widget.partnerName ?? 'User',
            artisan.user?.avatarUrl ?? widget.partnerAvatar,
          ),
          loading: () => widget.partnerName != null 
              ? _buildHeader(widget.partnerName!, widget.partnerAvatar)
              : const Text('Loading...'),
          error: (_, __) => _buildHeader(widget.partnerName ?? 'Chat', widget.partnerAvatar),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                return ListView.builder(
                  controller: _scrollCtrl,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isPartner = msg.senderId == partnerId;
                    return _MessageBubble(
                      text: msg.message,
                      isPartner: isPartner,
                      time: _formatTime(msg.createdAt),
                      partnerAvatar: isPartner 
                          ? (artisanAsync.value?.user?.avatarUrl ?? widget.partnerAvatar) 
                          : null,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, __) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Error loading messages: $e', 
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMd.copyWith(color: AppColors.error)),
                ),
              ),
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            color: AppColors.surfaceContainerLowest,
            child: Row(children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: TextField(
                    controller: _msgCtrl,
                    style: AppTypography.bodyMd,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String name, String? avatar) {
    return Row(children: [
      CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(avatar ?? 'https://i.pravatar.cc/60?u=${widget.conversationId}'),
      ),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: Theme.of(context).textTheme.titleSmall),
          Text('Online',
              style: AppTypography.labelSm.copyWith(
                  color: Colors.green.shade500)),
        ],
      ),
    ]);
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('h:mm a').format(date);
    } catch (e) {
      return '';
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isPartner;
  final String time;
  final String? partnerAvatar;

  const _MessageBubble({
    required this.text,
    required this.isPartner,
    required this.time,
    this.partnerAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isPartner ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isPartner) ...[
            CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(partnerAvatar ?? 'https://i.pravatar.cc/40?img=10'),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: isPartner
                  ? AppColors.surfaceContainerLowest
                  : AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isPartner ? 4 : 18),
                bottomRight: Radius.circular(isPartner ? 18 : 4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(text,
                    style: AppTypography.bodyMd.copyWith(
                      color: isPartner ? AppColors.onSurface : Colors.white,
                    )),
                const SizedBox(height: 4),
                Text(time,
                    style: AppTypography.labelSm.copyWith(
                      color: isPartner
                          ? AppColors.outline
                          : Colors.white.withOpacity(0.60),
                      fontSize: 10,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
