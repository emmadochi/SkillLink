import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/user_model.dart';
import 'dart:convert';

part 'user_provider.g.dart';

@riverpod
class UserState extends _$UserState {
  @override
  FutureOr<User?> build() async {
    const storage = FlutterSecureStorage();
    final userId = await storage.read(key: AppConstants.keyUserId);
    final name = await storage.read(key: 'user_name'); // We should save this on login
    final email = await storage.read(key: 'user_email');
    final role = await storage.read(key: AppConstants.keyUserRole);

    if (userId != null && name != null) {
      return User(
        id: int.parse(userId),
        name: name,
        email: email ?? '',
        role: role ?? 'customer',
      );
    }
    return null;
  }

  Future<void> setUser(User user) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: AppConstants.keyUserId, value: user.id.toString());
    await storage.write(key: 'user_name', value: user.name);
    await storage.write(key: 'user_email', value: user.email);
    await storage.write(key: AppConstants.keyUserRole, value: user.role);
    state = AsyncData(user);
  }

  Future<void> clearUser() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: AppConstants.keyUserId);
    await storage.delete(key: 'user_name');
    await storage.delete(key: 'user_email');
    await storage.delete(key: AppConstants.keyUserRole);
    await storage.delete(key: AppConstants.keyToken);
    state = const AsyncData(null);
  }
}
