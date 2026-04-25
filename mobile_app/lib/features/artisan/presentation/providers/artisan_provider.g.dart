// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artisan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$artisanRepositoryHash() => r'a7f41df54dfc22cdab580374ed1d1e7bd85e9db7';

/// See also [artisanRepository].
@ProviderFor(artisanRepository)
final artisanRepositoryProvider =
    AutoDisposeProvider<ArtisanRepository>.internal(
  artisanRepository,
  name: r'artisanRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$artisanRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ArtisanRepositoryRef = AutoDisposeProviderRef<ArtisanRepository>;
String _$artisansHash() => r'708e1cf4a830a8e436dc3b734a9619837548db0b';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [artisans].
@ProviderFor(artisans)
const artisansProvider = ArtisansFamily();

/// See also [artisans].
class ArtisansFamily extends Family<AsyncValue<List<Artisan>>> {
  /// See also [artisans].
  const ArtisansFamily();

  /// See also [artisans].
  ArtisansProvider call({
    int? categoryId,
    double? minRating,
    String? query,
    String? skills,
  }) {
    return ArtisansProvider(
      categoryId: categoryId,
      minRating: minRating,
      query: query,
      skills: skills,
    );
  }

  @override
  ArtisansProvider getProviderOverride(
    covariant ArtisansProvider provider,
  ) {
    return call(
      categoryId: provider.categoryId,
      minRating: provider.minRating,
      query: provider.query,
      skills: provider.skills,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'artisansProvider';
}

/// See also [artisans].
class ArtisansProvider extends FutureProvider<List<Artisan>> {
  /// See also [artisans].
  ArtisansProvider({
    int? categoryId,
    double? minRating,
    String? query,
    String? skills,
  }) : this._internal(
          (ref) => artisans(
            ref as ArtisansRef,
            categoryId: categoryId,
            minRating: minRating,
            query: query,
            skills: skills,
          ),
          from: artisansProvider,
          name: r'artisansProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$artisansHash,
          dependencies: ArtisansFamily._dependencies,
          allTransitiveDependencies: ArtisansFamily._allTransitiveDependencies,
          categoryId: categoryId,
          minRating: minRating,
          query: query,
          skills: skills,
        );

  ArtisansProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
    required this.minRating,
    required this.query,
    required this.skills,
  }) : super.internal();

  final int? categoryId;
  final double? minRating;
  final String? query;
  final String? skills;

  @override
  Override overrideWith(
    FutureOr<List<Artisan>> Function(ArtisansRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ArtisansProvider._internal(
        (ref) => create(ref as ArtisansRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
        minRating: minRating,
        query: query,
        skills: skills,
      ),
    );
  }

  @override
  FutureProviderElement<List<Artisan>> createElement() {
    return _ArtisansProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ArtisansProvider &&
        other.categoryId == categoryId &&
        other.minRating == minRating &&
        other.query == query &&
        other.skills == skills;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);
    hash = _SystemHash.combine(hash, minRating.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);
    hash = _SystemHash.combine(hash, skills.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ArtisansRef on FutureProviderRef<List<Artisan>> {
  /// The parameter `categoryId` of this provider.
  int? get categoryId;

  /// The parameter `minRating` of this provider.
  double? get minRating;

  /// The parameter `query` of this provider.
  String? get query;

  /// The parameter `skills` of this provider.
  String? get skills;
}

class _ArtisansProviderElement extends FutureProviderElement<List<Artisan>>
    with ArtisansRef {
  _ArtisansProviderElement(super.provider);

  @override
  int? get categoryId => (origin as ArtisansProvider).categoryId;
  @override
  double? get minRating => (origin as ArtisansProvider).minRating;
  @override
  String? get query => (origin as ArtisansProvider).query;
  @override
  String? get skills => (origin as ArtisansProvider).skills;
}

String _$artisanProfileHash() => r'cd01d36c615fbed149c80633c95ab3aa352886a8';

/// See also [artisanProfile].
@ProviderFor(artisanProfile)
const artisanProfileProvider = ArtisanProfileFamily();

/// See also [artisanProfile].
class ArtisanProfileFamily extends Family<AsyncValue<Artisan>> {
  /// See also [artisanProfile].
  const ArtisanProfileFamily();

  /// See also [artisanProfile].
  ArtisanProfileProvider call(
    int id,
  ) {
    return ArtisanProfileProvider(
      id,
    );
  }

  @override
  ArtisanProfileProvider getProviderOverride(
    covariant ArtisanProfileProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'artisanProfileProvider';
}

/// See also [artisanProfile].
class ArtisanProfileProvider extends FutureProvider<Artisan> {
  /// See also [artisanProfile].
  ArtisanProfileProvider(
    int id,
  ) : this._internal(
          (ref) => artisanProfile(
            ref as ArtisanProfileRef,
            id,
          ),
          from: artisanProfileProvider,
          name: r'artisanProfileProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$artisanProfileHash,
          dependencies: ArtisanProfileFamily._dependencies,
          allTransitiveDependencies:
              ArtisanProfileFamily._allTransitiveDependencies,
          id: id,
        );

  ArtisanProfileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<Artisan> Function(ArtisanProfileRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ArtisanProfileProvider._internal(
        (ref) => create(ref as ArtisanProfileRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  FutureProviderElement<Artisan> createElement() {
    return _ArtisanProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ArtisanProfileProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ArtisanProfileRef on FutureProviderRef<Artisan> {
  /// The parameter `id` of this provider.
  int get id;
}

class _ArtisanProfileProviderElement extends FutureProviderElement<Artisan>
    with ArtisanProfileRef {
  _ArtisanProfileProviderElement(super.provider);

  @override
  int get id => (origin as ArtisanProfileProvider).id;
}

String _$savedArtisansHash() => r'84000ed8079444141fedd5ca0dd5dfa50bbd42fe';

/// See also [savedArtisans].
@ProviderFor(savedArtisans)
final savedArtisansProvider = FutureProvider<List<Artisan>>.internal(
  savedArtisans,
  name: r'savedArtisansProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$savedArtisansHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SavedArtisansRef = FutureProviderRef<List<Artisan>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
