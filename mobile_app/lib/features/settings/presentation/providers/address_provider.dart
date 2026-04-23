import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/api_client.dart';
import '../data/repositories/address_repository.dart';
import '../data/models/address_model.dart';

part 'address_provider.g.dart';

@riverpod
AddressRepository addressRepository(AddressRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  final apiClient = ApiClient(dio);
  return AddressRepositoryImpl(apiClient);
}

@riverpod
class UserAddresses extends _$UserAddresses {
  @override
  Future<List<UserAddress>> build() {
    return ref.watch(addressRepositoryProvider).getAddresses();
  }

  Future<void> addAddress(UserAddress address) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(addressRepositoryProvider).createAddress(address);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeAddress(int id) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(addressRepositoryProvider).deleteAddress(id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
