import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../artisan/presentation/providers/artisan_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_Message> _messages = [
    _Message('Hello! I saw your profile and I\'m interested in your services.', false, '10:00'),
  ];

  void _sendMessage() {
    if (_msgCtrl.text.trim().isEmpty) return;
    setState(() {
      _messages.add(_Message(_msgCtrl.text.trim(), false, '${TimeOfDay.now().hour}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}'));
    });
    _msgCtrl.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Attempt to parse conversationId as artisanId for now
    final artisanId = int.tryParse(widget.conversationId) ?? 1;
    final artisanAsync = ref.watch(artisanProfileProvider(artisanId));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: artisanAsync.when(
          data: (artisan) => Row(children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(artisan.user?.avatarUrl ?? 'https://i.pravatar.cc/60?img=10'),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(artisan.user?.name ?? 'Artisan',
                    style: Theme.of(context).textTheme.titleSmall),
                Text('Online',
                    style: AppTypography.labelSm.copyWith(
                        color: Colors.green.shade500)),
              ],
            ),
          ]),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Chat'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: artisanAsync.when(
              data: (artisan) => ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, i) => _MessageBubble(
                  msg: _messages[i],
                  artisanAvatar: artisan.user?.avatarUrl,
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, i) => _MessageBubble(msg: _messages[i]),
              ),
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            color: AppColors.surfaceContainerLowest,
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.attach_file_rounded,
                    color: AppColors.outline),
                onPressed: () {},
              ),
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
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: AppTypography.bodyMd.copyWith(
                          color: AppColors.outline),
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
}

class _Message {
  final String text;
  final bool isArtisan;
  final String time;
  _Message(this.text, this.isArtisan, this.time);
}

class _MessageBubble extends ConsumerWidget {
  final _Message msg;
  final String? artisanAvatar;
  const _MessageBubble({required this.msg, this.artisanAvatar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            msg.isArtisan ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (msg.isArtisan) ...[
            CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(artisanAvatar ?? 'https://i.pravatar.cc/40?img=10'),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: msg.isArtisan
                  ? AppColors.surfaceContainerLowest
                  : AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(msg.isArtisan ? 4 : 18),
                bottomRight: Radius.circular(msg.isArtisan ? 18 : 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(msg.text,
                    style: AppTypography.bodyMd.copyWith(
                      color: msg.isArtisan ? AppColors.onSurface : Colors.white,
                    )),
                const SizedBox(height: 4),
                Text(msg.time,
                    style: AppTypography.labelSm.copyWith(
                      color: msg.isArtisan
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
