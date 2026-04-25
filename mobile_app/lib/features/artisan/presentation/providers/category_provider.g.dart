// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoriesHash() => r'79f29ca2e3f5a97904305318e8dbf266e47f8466';

/// See also [categories].
@ProviderFor(categories)
final categoriesProvider = StreamProvider<List<Category>>.internal(
  categories,
  name: r'categoriesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$categoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoriesRef = StreamProviderRef<List<Category>>;
String _$categoryServicesHash() => r'2d0681202e0e3aaa8a93158b329fb1f2b30f2457';

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

/// See also [categoryServices].
@ProviderFor(categoryServices)
const categoryServicesProvider = CategoryServicesFamily();

/// See also [categoryServices].
class CategoryServicesFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [categoryServices].
  const CategoryServicesFamily();

  /// See also [categoryServices].
  CategoryServicesProvider call(
    int categoryId,
  ) {
    return CategoryServicesProvider(
      categoryId,
    );
  }

  @override
  CategoryServicesProvider getProviderOverride(
    covariant CategoryServicesProvider provider,
  ) {
    return call(
      provider.categoryId,
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
  String? get name => r'categoryServicesProvider';
}

/// See also [categoryServices].
class CategoryServicesProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [categoryServices].
  CategoryServicesProvider(
    int categoryId,
  ) : this._internal(
          (ref) => categoryServices(
            ref as CategoryServicesRef,
            categoryId,
          ),
          from: categoryServicesProvider,
          name: r'categoryServicesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryServicesHash,
          dependencies: CategoryServicesFamily._dependencies,
          allTransitiveDependencies:
              CategoryServicesFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  CategoryServicesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final int categoryId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(CategoryServicesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoryServicesProvider._internal(
        (ref) => create(ref as CategoryServicesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _CategoryServicesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryServicesProvider && other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CategoryServicesRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `categoryId` of this provider.
  int get categoryId;
}

class _CategoryServicesProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with CategoryServicesRef {
  _CategoryServicesProviderElement(super.provider);

  @override
  int get categoryId => (origin as CategoryServicesProvider).categoryId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
