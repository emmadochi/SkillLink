import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Messages',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFamily: 'PlusJakartaSans',
                  color: AppColors.onSurface,
                )),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (context, i) => _ChatTile(
          index: i,
          onTap: () => context.go('${AppRoutes.chat}/${i + 1}'),
        ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final int index;
  final VoidCallback onTap;

  const _ChatTile({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasUnread = index % 3 == 0;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasUnread
              ? AppColors.primary.withOpacity(0.04)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/80?img=${index + 5}'),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green.shade500,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('Emmanuel O.',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                          )),
                  const Spacer(),
                  Text('10:3${index}',
                      style: Theme.of(context).textTheme.labelSmall),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  Expanded(
                    child: Text(
                      'I\'ll be there by 10am. Please make sure the fuse box is accessible.',
                      style: AppTypography.bodyMd.copyWith(
                        color: hasUnread
                            ? AppColors.onSurface
                            : AppColors.outline,
                        fontWeight: hasUnread
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasUnread)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('2',
                            style: AppTypography.labelSm.copyWith(
                                color: Colors.white, fontSize: 10)),
                      ),
                    ),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
