import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../artisan/presentation/providers/artisan_provider.dart';
import '../providers/chat_provider.dart';
import '../../data/models/chat_model.dart';
import '../../../../core/utils/url_utils.dart';

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

class _ChatScreenState extends ConsumerState<ChatScreen> with SingleTickerProviderStateMixin {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _picker = ImagePicker();
  Timer? _refreshTimer;

  // Voice note recording state
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final partnerId = int.tryParse(widget.conversationId);
      if (partnerId != null) {
        ref.invalidate(conversationProvider(partnerId));
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _recordTimer?.cancel();
    _pulseController.dispose();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage({String messageType = 'text', String? mediaUrl, int? mediaDuration, String? text}) async {
    final msgText = text ?? _msgCtrl.text.trim();
    if (msgText.isEmpty && mediaUrl == null) return;
    
    final partnerId = int.tryParse(widget.conversationId);
    if (partnerId == null) return;
    
    final repo = ref.read(chatRepositoryProvider);
    
    if (messageType == 'text') {
      _msgCtrl.clear();
    }
    
    try {
      await repo.sendMessage(
        partnerId, 
        msgText.isNotEmpty ? msgText : (messageType == 'image' ? '📷 Photo' : (messageType == 'video' ? '🎥 Video' : '🎤 Voice Note')),
        messageType: messageType,
        mediaUrl: mediaUrl,
        mediaDuration: mediaDuration,
      );
      ref.invalidate(conversationProvider(partnerId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    }
  }

  // --- Media Picker Sheet (Photos / Videos of Damage & Work) ---
  void _openAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Share Work or Damage Proof', style: AppTypography.titleMd.copyWith(color: AppColors.primary)),
              const SizedBox(height: 4),
              Text('Upload photos or videos for quick inspection', style: AppTypography.bodySm.copyWith(color: AppColors.outline)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _AttachmentOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickAndSendMedia(ImageSource.camera, isVideo: false);
                    },
                  ),
                  _AttachmentOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Photo Gallery',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickAndSendMedia(ImageSource.gallery, isVideo: false);
                    },
                  ),
                  _AttachmentOption(
                    icon: Icons.videocam_rounded,
                    label: 'Video Proof',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickAndSendMedia(ImageSource.gallery, isVideo: true);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndSendMedia(ImageSource source, {bool isVideo = false}) async {
    try {
      XFile? file;
      if (isVideo) {
        file = await _picker.pickVideo(source: source, maxDuration: const Duration(minutes: 2));
      } else {
        file = await _picker.pickImage(source: source, imageQuality: 80);
      }

      if (file == null) return;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading media attachment...'), duration: Duration(seconds: 2)),
      );

      final repo = ref.read(chatRepositoryProvider);
      final uploadRes = await repo.uploadMedia(file.path);

      if (uploadRes != null && uploadRes['media_url'] != null) {
        _sendMessage(
          messageType: isVideo ? 'video' : 'image',
          mediaUrl: uploadRes['media_url'],
          text: isVideo ? '🎥 Job Site Video' : '📷 Site Inspection Photo',
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload media. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Media selection error: $e')),
        );
      }
    }
  }

  // --- Voice Note Recording Flow ---
  void _startVoiceRecording() {
    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
    });

    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordSeconds++;
        });
      }
    });
  }

  void _cancelVoiceRecording() {
    _recordTimer?.cancel();
    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
    });
  }

  void _sendVoiceNote() {
    final duration = _recordSeconds > 0 ? _recordSeconds : 3;
    _recordTimer?.cancel();
    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
    });

    // Send voice note with duration
    _sendMessage(
      messageType: 'audio',
      mediaUrl: 'uploads/chat/voice_note_sample.m4a',
      mediaDuration: duration,
      text: '🎤 Voice Note (${_formatDuration(duration)})',
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final partnerId = int.tryParse(widget.conversationId);
    if (partnerId == null) {
      return const Scaffold(body: Center(child: Text('Invalid Conversation')));
    }

    final artisanAsync = ref.watch(artisanProfileProvider(partnerId));
    final messagesAsync = ref.watch(conversationProvider(partnerId));
    
    // Auto-scroll on new message
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
        elevation: 0.5,
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
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.outline.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        Text('No messages yet', style: AppTypography.bodyMd.copyWith(color: AppColors.outline)),
                        const SizedBox(height: 4),
                        Text('Share photos or voice notes to get started', style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollCtrl,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isPartner = msg.senderId == partnerId;
                    return _MessageBubble(
                      message: msg,
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

          // --- Input Bar / Voice Recorder HUD ---
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    if (_isRecording) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        color: AppColors.surfaceContainerLowest,
        child: Row(
          children: [
            FadeTransition(
              opacity: _pulseController,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Recording Voice Note: ${_formatDuration(_recordSeconds)}',
              style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold, color: Colors.red.shade700),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey),
              onPressed: _cancelVoiceRecording,
              tooltip: 'Cancel',
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendVoiceNote,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      color: AppColors.surfaceContainerLowest,
      child: Row(
        children: [
          // Attachment Button (Photos / Videos)
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 26),
            onPressed: _openAttachmentSheet,
            tooltip: 'Attach Media',
          ),
          
          // Text input
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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

          // Send button or Voice Note Trigger
          GestureDetector(
            onTap: () {
              if (_msgCtrl.text.trim().isNotEmpty) {
                _sendMessage();
              } else {
                _startVoiceRecording();
              }
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                gradient: AppColors.buttonGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _msgCtrl.text.trim().isNotEmpty ? Icons.send_rounded : Icons.mic_rounded,
                color: Colors.white, 
                size: 20
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String name, String? avatar) {
    return Row(children: [
      CircleAvatar(
        radius: 18,
        backgroundImage: avatar != null && avatar.isNotEmpty
            ? NetworkImage(UrlUtils.resolveImageUrl(avatar))
            : null,
        child: avatar == null || avatar.isEmpty
            ? const Icon(Icons.person, size: 18, color: AppColors.outline)
            : null,
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

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isPartner;
  final String time;
  final String? partnerAvatar;

  const _MessageBubble({
    required this.message,
    required this.isPartner,
    required this.time,
    this.partnerAvatar,
  });

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  bool _isPlayingAudio = false;

  @override
  Widget build(BuildContext context) {
    final type = widget.message.messageType;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            widget.isPartner ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (widget.isPartner) ...[
            CircleAvatar(
              radius: 14,
              backgroundImage: widget.partnerAvatar != null && widget.partnerAvatar!.isNotEmpty
                  ? NetworkImage(UrlUtils.resolveImageUrl(widget.partnerAvatar!))
                  : null,
              child: widget.partnerAvatar == null || widget.partnerAvatar!.isEmpty
                  ? const Icon(Icons.person, size: 14, color: AppColors.outline)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.76,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isPartner
                  ? AppColors.surfaceContainerLowest
                  : AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(widget.isPartner ? 4 : 18),
                bottomRight: Radius.circular(widget.isPartner ? 18 : 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Render based on message type
                if (type == 'image')
                  _buildImageBubble()
                else if (type == 'video')
                  _buildVideoBubble()
                else if (type == 'audio')
                  _buildAudioBubble()
                else
                  Text(
                    widget.message.message,
                    style: AppTypography.bodyMd.copyWith(
                      color: widget.isPartner ? AppColors.onSurface : Colors.white,
                    ),
                  ),

                const SizedBox(height: 4),
                Text(
                  widget.time,
                  style: AppTypography.labelSm.copyWith(
                    color: widget.isPartner
                        ? AppColors.outline
                        : Colors.white.withOpacity(0.65),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageBubble() {
    final mediaUrl = widget.message.mediaUrl;
    final fullUrl = mediaUrl != null ? UrlUtils.resolveImageUrl(mediaUrl) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fullUrl != null)
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(fullUrl, fit: BoxFit.contain),
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                fullUrl,
                width: 200,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 200,
                  height: 140,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
          ),
        if (widget.message.message.isNotEmpty && widget.message.message != '📷 Photo') ...[
          const SizedBox(height: 6),
          Text(
            widget.message.message,
            style: AppTypography.bodySm.copyWith(
              color: widget.isPartner ? AppColors.onSurface : Colors.white,
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildVideoBubble() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 200,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.videocam_rounded, size: 48, color: Colors.white.withOpacity(0.3)),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('VIDEO PROOF', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        if (widget.message.message.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            widget.message.message,
            style: AppTypography.bodySm.copyWith(
              color: widget.isPartner ? AppColors.onSurface : Colors.white,
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildAudioBubble() {
    final duration = widget.message.mediaDuration ?? 5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isPlayingAudio = !_isPlayingAudio;
            });
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.isPartner ? AppColors.primary : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: widget.isPartner ? Colors.white : AppColors.primary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(12, (index) {
                final height = ((index * 7) % 16 + 8).toDouble();
                return Container(
                  width: 3,
                  height: _isPlayingAudio ? ((index * 11) % 20 + 6).toDouble() : height,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: widget.isPartner 
                        ? AppColors.primary.withOpacity(0.7) 
                        : Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
            const SizedBox(height: 4),
            Text(
              'Voice Note (${(duration ~/ 60)}:${(duration % 60).toString().padLeft(2, '0')})',
              style: AppTypography.labelSm.copyWith(
                color: widget.isPartner ? AppColors.outline : Colors.white.withOpacity(0.8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
