import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/skilllink_button.dart';
import '../../../../shared/widgets/skilllink_input.dart';
import '../../data/models/address_model.dart';
import '../providers/address_provider.dart';

class SavedAddressesScreen extends ConsumerStatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  ConsumerState<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends ConsumerState<SavedAddressesScreen> {
  final _labelCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  void _showAddAddressSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add New Address', style: AppTypography.titleLg),
            const SizedBox(height: 24),
            SkillLinkInput(
              label: 'Label',
              hint: 'e.g. Home, Work',
              controller: _labelCtrl,
            ),
            const SizedBox(height: 16),
            SkillLinkInput(
              label: 'Full Address',
              hint: '123 Street Name, City',
              controller: _addressCtrl,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SkillLinkButton.gradient(
              label: 'Save Address',
              width: double.infinity,
              onPressed: () async {
                if (_labelCtrl.text.isNotEmpty && _addressCtrl.text.isNotEmpty) {
                  final newAddress = UserAddress(
                    label: _labelCtrl.text,
                    address: _addressCtrl.text,
                  );
                  await ref.read(userAddressesProvider.notifier).addAddress(newAddress);
                  if (mounted) {
                    Navigator.pop(context);
                    _labelCtrl.clear();
                    _addressCtrl.clear();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressesAsync = ref.watch(userAddressesProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Saved Addresses'),
      ),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_rounded,
                      size: 64, color: AppColors.outlineVariant),
                  const SizedBox(height: 16),
                  Text('No saved addresses yet', style: AppTypography.titleMd),
                  const SizedBox(height: 8),
                  const Text('Add your home or work address for faster booking'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final addr = addresses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.surfaceContainerLow,
                    child: Icon(Icons.location_on_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  title: Text(addr.label, style: AppTypography.titleSm),
                  subtitle: Text(addr.address,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.error, size: 20),
                    onPressed: () => ref
                        .read(userAddressesProvider.notifier)
                        .removeAddress(addr.id!),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, __) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAddressSheet,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
