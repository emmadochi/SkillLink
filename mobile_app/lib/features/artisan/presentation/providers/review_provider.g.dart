// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reviewRepositoryHash() => r'02ccc93a3cdbd596ab5b0b16d13ea7987861638c';

/// See also [reviewRepository].
@ProviderFor(reviewRepository)
final reviewRepositoryProvider = AutoDisposeProvider<ReviewRepository>.internal(
  reviewRepository,
  name: r'reviewRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reviewRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReviewRepositoryRef = AutoDisposeProviderRef<ReviewRepository>;
String _$artisanReviewsHash() => r'b3f708f9cb79a1bdbcda1ab58eb50cf4b9fb6903';

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

/// See also [artisanReviews].
@ProviderFor(artisanReviews)
const artisanReviewsProvider = ArtisanReviewsFamily();

/// See also [artisanReviews].
class ArtisanReviewsFamily extends Family<AsyncValue<List<Review>>> {
  /// See also [artisanReviews].
  const ArtisanReviewsFamily();

  /// See also [artisanReviews].
  ArtisanReviewsProvider call(
    int artisanId,
  ) {
    return ArtisanReviewsProvider(
      artisanId,
    );
  }

  @override
  ArtisanReviewsProvider getProviderOverride(
    covariant ArtisanReviewsProvider provider,
  ) {
    return call(
      provider.artisanId,
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
  String? get name => r'artisanReviewsProvider';
}

/// See also [artisanReviews].
class ArtisanReviewsProvider extends AutoDisposeFutureProvider<List<Review>> {
  /// See also [artisanReviews].
  ArtisanReviewsProvider(
    int artisanId,
  ) : this._internal(
          (ref) => artisanReviews(
            ref as ArtisanReviewsRef,
            artisanId,
          ),
          from: artisanReviewsProvider,
          name: r'artisanReviewsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$artisanReviewsHash,
          dependencies: ArtisanReviewsFamily._dependencies,
          allTransitiveDependencies:
              ArtisanReviewsFamily._allTransitiveDependencies,
          artisanId: artisanId,
        );

  ArtisanReviewsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.artisanId,
  }) : super.internal();

  final int artisanId;

  @override
  Override overrideWith(
    FutureOr<List<Review>> Function(ArtisanReviewsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ArtisanReviewsProvider._internal(
        (ref) => create(ref as ArtisanReviewsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        artisanId: artisanId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Review>> createElement() {
    return _ArtisanReviewsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ArtisanReviewsProvider && other.artisanId == artisanId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, artisanId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ArtisanReviewsRef on AutoDisposeFutureProviderRef<List<Review>> {
  /// The parameter `artisanId` of this provider.
  int get artisanId;
}

class _ArtisanReviewsProviderElement
    extends AutoDisposeFutureProviderElement<List<Review>>
    with ArtisanReviewsRef {
  _ArtisanReviewsProviderElement(super.provider);

  @override
  int get artisanId => (origin as ArtisanReviewsProvider).artisanId;
}

String _$reviewControllerHash() => r'7e9cb0f0c50d3711a20b741766d26d7d7111161d';

/// See also [ReviewController].
@ProviderFor(ReviewController)
final reviewControllerProvider =
    AutoDisposeNotifierProvider<ReviewController, AsyncValue<void>>.internal(
  ReviewController.new,
  name: r'reviewControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reviewControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReviewController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
