import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../artisan/presentation/providers/category_provider.dart';

class SubServiceSheet extends ConsumerStatefulWidget {
  final int categoryId;
  final String categoryName;

  const SubServiceSheet({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  ConsumerState<SubServiceSheet> createState() => _SubServiceSheetState();
}

class _SubServiceSheetState extends ConsumerState<SubServiceSheet> {
  final Set<String> _selectedServices = {};

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(categoryServicesProvider(widget.categoryId));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'What Service do you need?',
                  style: AppTypography.headlineSm.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerLow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.categoryName,
                style: AppTypography.titleSm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          servicesAsync.when(
            data: (services) {
              if (services.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No sub-services available.'),
                  ),
                );
              }
              return Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  itemBuilder: (context, i) {
                    final serviceName = services[i]['service_name'] as String;
                    final isSelected = _selectedServices.contains(serviceName);

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedServices.add(serviceName);
                          } else {
                            _selectedServices.remove(serviceName);
                          }
                        });
                      },
                      title: Text(
                        serviceName,
                        style: AppTypography.labelLg.copyWith(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      activeColor: AppColors.primary,
                      checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                final skillsQuery = _selectedServices.join(',');
                context.pop(); // Close sheet
                context.push(
                  '${AppRoutes.artisanListing}?category=${widget.categoryName}&categoryId=${widget.categoryId}${skillsQuery.isNotEmpty ? '&skills=$skillsQuery' : ''}',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Go',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
