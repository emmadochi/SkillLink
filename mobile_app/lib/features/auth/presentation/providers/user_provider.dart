import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/user_model.dart';
import 'dart:convert';

part 'user_provider.g.dart';

@Riverpod(keepAlive: true)
class UserState extends _$UserState {
  @override
  FutureOr<User?> build() async {
    const storage = FlutterSecureStorage();
    final userId = await storage.read(key: AppConstants.keyUserId);
    final name = await storage.read(key: 'user_name');
    final email = await storage.read(key: 'user_email');
    final role = await storage.read(key: AppConstants.keyUserRole);
    final phone = await storage.read(key: 'user_phone');
    final avatarUrl = await storage.read(key: 'user_avatar');
    final isVerifiedStr = await storage.read(key: 'user_is_verified');

    if (userId != null && name != null) {
      return User(
        id: int.parse(userId),
        name: name,
        email: email ?? '',
        role: role ?? 'customer',
        phone: phone,
        avatarUrl: avatarUrl,
        isVerified: isVerifiedStr == '1',
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
    await storage.write(key: 'user_phone', value: user.phone ?? '');
    await storage.write(key: 'user_avatar', value: user.avatarUrl ?? '');
    await storage.write(key: 'user_is_verified', value: user.isVerified ? '1' : '0');
    state = AsyncData(user);
  }

  Future<void> clearUser() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: AppConstants.keyUserId);
    await storage.delete(key: 'user_name');
    await storage.delete(key: 'user_email');
    await storage.delete(key: AppConstants.keyUserRole);
    await storage.delete(key: 'user_phone');
    await storage.delete(key: 'user_avatar');
    await storage.delete(key: 'user_is_verified');
    await storage.delete(key: AppConstants.keyToken);
    state = const AsyncData(null);
  }
}
