import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/wallet_provider.dart';

class ArtisanWalletScreen extends ConsumerStatefulWidget {
  const ArtisanWalletScreen({super.key});

  @override
  ConsumerState<ArtisanWalletScreen> createState() => _ArtisanWalletScreenState();
}

class _ArtisanWalletScreenState extends ConsumerState<ArtisanWalletScreen> {
  final _amountCtrl = TextEditingController();
  final _accNoCtrl = TextEditingController();
  final _accNameCtrl = TextEditingController();
  String? _selectedBankName;
  String? _selectedBankCode;
  bool _saveAccount = true;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _accNoCtrl.dispose();
    _accNameCtrl.dispose();
    super.dispose();
  }

  void _openWithdrawModal(BuildContext context, WalletState wallet) {
    final banksAsync = ref.read(nigerianBanksProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20, 
            right: 20, 
            top: 20, 
            bottom: MediaQuery.of(context).viewInsets.bottom + 24
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
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
                Text('Bank Payout Withdrawal', style: AppTypography.titleMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Transfer funds directly to your Nigerian bank account', style: AppTypography.bodySm.copyWith(color: AppColors.outline)),
                const SizedBox(height: 16),

                // Available Balance Reminder
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Available Balance', style: AppTypography.bodySm.copyWith(color: AppColors.outline)),
                      Text('₦${NumberFormat('#,##0.00').format(wallet.balance)}', 
                        style: AppTypography.titleSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Bank Selector
                Text('Select Bank', style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                banksAsync.when(
                  data: (banks) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.outline.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('Choose Nigerian Bank'),
                        value: _selectedBankCode,
                        items: banks.map((b) => DropdownMenuItem<String>(
                          value: b['code']?.toString(),
                          child: Text(b['name']?.toString() ?? ''),
                        )).toList(),
                        onChanged: (val) {
                          final selected = banks.firstWhere((b) => b['code']?.toString() == val, orElse: () => {});
                          setModalState(() {
                            _selectedBankCode = val;
                            _selectedBankName = selected['name']?.toString();
                          });
                        },
                      ),
                    ),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Error loading banks list'),
                ),
                const SizedBox(height: 14),

                // Account Number
                Text('NUBAN Account Number', style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _accNoCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  decoration: InputDecoration(
                    hintText: 'e.g. 0123456789 (10 digits)',
                    counterText: '',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onChanged: (val) {
                    if (val.length == 10 && _accNameCtrl.text.isEmpty) {
                      setModalState(() {
                        _accNameCtrl.text = 'Verified Account Holder';
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),

                // Account Name
                Text('Account Holder Name', style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _accNameCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. John Doe',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 14),

                // Amount
                Text('Amount to Withdraw (₦)', style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixText: '₦ ',
                    hintText: 'Min. ₦500.00',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 8),

                // Quick Amount Chips
                Row(
                  children: [
                    _quickChip('₦1,000', 1000, setModalState),
                    const SizedBox(width: 8),
                    _quickChip('₦5,000', 5000, setModalState),
                    const SizedBox(width: 8),
                    _quickChip('₦10,000', 10000, setModalState),
                    const SizedBox(width: 8),
                    _quickChip('All (100%)', wallet.balance, setModalState),
                  ],
                ),
                const SizedBox(height: 14),

                // Save Account Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _saveAccount, 
                      activeColor: AppColors.primary,
                      onChanged: (v) => setModalState(() => _saveAccount = v ?? true),
                    ),
                    Text('Save this account for future 1-tap payouts', style: AppTypography.bodySm),
                  ],
                ),
                const SizedBox(height: 16),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _submitWithdrawal(ctx),
                    child: Text('Confirm Payout Transfer', style: AppTypography.titleSm.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickChip(String label, double amount, StateSetter setModalState) {
    return InkWell(
      onTap: () {
        setModalState(() {
          _amountCtrl.text = amount.toStringAsFixed(0);
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
      ),
    );
  }

  void _submitWithdrawal(BuildContext modalCtx) async {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
    final accNo = _accNoCtrl.text.trim();
    final accName = _accNameCtrl.text.trim();

    if (amount < 500) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minimum withdrawal is ₦500.00')));
      return;
    }

    if (_selectedBankName == null || accNo.isEmpty || accName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all bank details')));
      return;
    }

    Navigator.pop(modalCtx);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processing bank payout transfer...')),
    );

    final success = await ref.read(walletProvider.notifier).withdraw(
      amount: amount,
      bankName: _selectedBankName!,
      bankCode: _selectedBankCode ?? '000',
      accountNumber: accNo,
      accountName: accName,
      saveAccount: _saveAccount,
    );

    if (mounted) {
      if (success) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                const SizedBox(width: 10),
                const Text('Payout Processed!'),
              ],
            ),
            content: Text('₦${NumberFormat('#,##0.00').format(amount)} has been successfully transferred to $_selectedBankName ($accNo).'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(walletProvider).error ?? 'Withdrawal failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Artisan Wallet & Earnings', style: AppTypography.titleMd.copyWith(color: AppColors.primary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(walletProvider.notifier).fetchWalletData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(walletProvider.notifier).fetchWalletData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Luxury Dark Wallet Card ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF000C47), Color(0xFF1B2A7A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000C47).withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text('Available Balance', style: AppTypography.labelMd.copyWith(color: Colors.white70)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade500.withOpacity(0.25),
                            border: Border.all(color: Colors.green.shade400),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              const Text('ACTIVE', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '₦${NumberFormat('#,##0.00').format(wallet.balance)}',
                      style: AppTypography.headlineLg.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 32),
                    ),
                    const SizedBox(height: 20),

                    // Escrow Holding & Total Bar
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('In Escrow (Pending)', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                                const SizedBox(height: 2),
                                Text('₦${NumberFormat('#,##0.00').format(wallet.pendingBalance)}',
                                  style: const TextStyle(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 30, color: Colors.white24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Asset Value', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                                const SizedBox(height: 2),
                                Text('₦${NumberFormat('#,##0.00').format(wallet.totalBalance)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                            label: const Text('Withdraw to Bank', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => _openWithdrawModal(context, wallet),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Escrow Guarantee Card ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
                      child: Icon(Icons.shield_rounded, color: Colors.blue.shade700, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('100% Escrow Protection', style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                          const SizedBox(height: 2),
                          Text('Customer funds are held in secure escrow when booked, and automatically released to your wallet upon completion.',
                            style: AppTypography.bodySm.copyWith(color: Colors.blue.shade800, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Transactions & Withdrawals Ledger ---
              Text('Transaction Ledger', style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              if (wallet.transactions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.outline.withOpacity(0.15)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 40, color: AppColors.outline.withOpacity(0.4)),
                      const SizedBox(height: 10),
                      Text('No transaction records yet', style: AppTypography.bodySm.copyWith(color: AppColors.outline)),
                      const SizedBox(height: 2),
                      Text('Completed job payouts and withdrawals will appear here.', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: wallet.transactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final t = wallet.transactions[idx];
                    final isPayout = (t['type'] == 'payout' || t['type'] == 'escrow_release');
                    final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
                    final dateStr = t['created_at']?.toString() ?? '';

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outline.withOpacity(0.12)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isPayout ? Colors.green.shade50 : Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPayout ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              color: isPayout ? Colors.green.shade700 : Colors.blue.shade700,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t['booking_number'] != null 
                                      ? 'Job Payout #${t['booking_number']}' 
                                      : (t['payment_reference'] ?? 'Bank Withdrawal'),
                                  style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateStr.isNotEmpty 
                                      ? DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.tryParse(dateStr) ?? DateTime.now())
                                      : 'Recently',
                                  style: AppTypography.labelSm.copyWith(color: AppColors.outline, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isPayout ? '+' : '-'}₦${NumberFormat('#,##0.00').format(amount)}',
                                style: TextStyle(
                                  color: isPayout ? Colors.green.shade700 : AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('SUCCESSFUL', style: TextStyle(color: Colors.green.shade700, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
