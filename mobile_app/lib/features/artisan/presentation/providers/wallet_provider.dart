import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_providers.dart';
import '../../../auth/presentation/providers/auth_repository_provider.dart';

class WalletState {
  final double balance;
  final double pendingBalance;
  final double totalBalance;
  final List<Map<String, dynamic>> savedAccounts;
  final List<Map<String, dynamic>> transactions;
  final bool isLoading;
  final String? error;

  WalletState({
    this.balance = 0.0,
    this.pendingBalance = 0.0,
    this.totalBalance = 0.0,
    this.savedAccounts = const [],
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  WalletState copyWith({
    double? balance,
    double? pendingBalance,
    double? totalBalance,
    List<Map<String, dynamic>>? savedAccounts,
    List<Map<String, dynamic>>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      totalBalance: totalBalance ?? this.totalBalance,
      savedAccounts: savedAccounts ?? this.savedAccounts,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final ApiClient _apiClient;

  WalletNotifier(this._apiClient) : super(WalletState()) {
    fetchWalletData();
  }

  Future<void> fetchWalletData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _apiClient.getWalletBalance();
      if (res.status == 'success' && res.data != null) {
        final data = res.data!;
        state = state.copyWith(
          balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
          pendingBalance: (data['pending_balance'] as num?)?.toDouble() ?? 0.0,
          totalBalance: (data['total_balance'] as num?)?.toDouble() ?? 0.0,
          savedAccounts: List<Map<String, dynamic>>.from(data['saved_accounts'] ?? []),
          transactions: List<Map<String, dynamic>>.from(data['transactions'] ?? []),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: res.message ?? 'Failed to load wallet');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> withdraw({
    required double amount,
    required String bankName,
    required String bankCode,
    required String accountNumber,
    required String accountName,
    bool saveAccount = false,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await _apiClient.withdrawWalletFunds({
        'amount': amount,
        'bank_name': bankName,
        'bank_code': bankCode,
        'account_number': accountNumber,
        'account_name': accountName,
        'save_account': saveAccount,
      });

      if (res.status == 'success') {
        await fetchWalletData();
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: res.message ?? 'Withdrawal failed');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalletNotifier(apiClient);
});

final nigerianBanksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final res = await apiClient.getNigerianBanks();
  return res.data ?? [];
});
