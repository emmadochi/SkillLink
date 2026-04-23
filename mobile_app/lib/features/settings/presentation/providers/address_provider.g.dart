// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$addressRepositoryHash() => r'c40d45822a440b50eba414426c40ad56d817d291';

/// See also [addressRepository].
@ProviderFor(addressRepository)
final addressRepositoryProvider =
    AutoDisposeProvider<AddressRepository>.internal(
  addressRepository,
  name: r'addressRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$addressRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AddressRepositoryRef = AutoDisposeProviderRef<AddressRepository>;
String _$userAddressesHash() => r'ff8cb6d39fa71f8559bd6d9d5031d785f17a5f95';

/// See also [UserAddresses].
@ProviderFor(UserAddresses)
final userAddressesProvider =
    AutoDisposeAsyncNotifierProvider<UserAddresses, List<UserAddress>>.internal(
  UserAddresses.new,
  name: r'userAddressesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userAddressesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserAddresses = AutoDisposeAsyncNotifier<List<UserAddress>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
