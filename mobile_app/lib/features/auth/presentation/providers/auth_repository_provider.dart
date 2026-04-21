import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/api_client.dart';

part 'auth_repository_provider.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  final apiClient = ApiClient(dio);
  return AuthRepositoryImpl(apiClient);
}
