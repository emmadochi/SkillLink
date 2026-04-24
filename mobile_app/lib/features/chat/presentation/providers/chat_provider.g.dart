// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatRepositoryHash() => r'7142cfee20f15794584ae1a781d9a5054daf5085';

/// See also [chatRepository].
@ProviderFor(chatRepository)
final chatRepositoryProvider = AutoDisposeProvider<ChatRepository>.internal(
  chatRepository,
  name: r'chatRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatRepositoryRef = AutoDisposeProviderRef<ChatRepository>;
String _$conversationHash() => r'd84440bba0c150eeb2c86b85a58add9525e38427';

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

/// See also [conversation].
@ProviderFor(conversation)
const conversationProvider = ConversationFamily();

/// See also [conversation].
class ConversationFamily extends Family<AsyncValue<List<ChatMessage>>> {
  /// See also [conversation].
  const ConversationFamily();

  /// See also [conversation].
  ConversationProvider call(
    int partnerId,
  ) {
    return ConversationProvider(
      partnerId,
    );
  }

  @override
  ConversationProvider getProviderOverride(
    covariant ConversationProvider provider,
  ) {
    return call(
      provider.partnerId,
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
  String? get name => r'conversationProvider';
}

/// See also [conversation].
class ConversationProvider extends FutureProvider<List<ChatMessage>> {
  /// See also [conversation].
  ConversationProvider(
    int partnerId,
  ) : this._internal(
          (ref) => conversation(
            ref as ConversationRef,
            partnerId,
          ),
          from: conversationProvider,
          name: r'conversationProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$conversationHash,
          dependencies: ConversationFamily._dependencies,
          allTransitiveDependencies:
              ConversationFamily._allTransitiveDependencies,
          partnerId: partnerId,
        );

  ConversationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.partnerId,
  }) : super.internal();

  final int partnerId;

  @override
  Override overrideWith(
    FutureOr<List<ChatMessage>> Function(ConversationRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConversationProvider._internal(
        (ref) => create(ref as ConversationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        partnerId: partnerId,
      ),
    );
  }

  @override
  FutureProviderElement<List<ChatMessage>> createElement() {
    return _ConversationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationProvider && other.partnerId == partnerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, partnerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConversationRef on FutureProviderRef<List<ChatMessage>> {
  /// The parameter `partnerId` of this provider.
  int get partnerId;
}

class _ConversationProviderElement
    extends FutureProviderElement<List<ChatMessage>> with ConversationRef {
  _ConversationProviderElement(super.provider);

  @override
  int get partnerId => (origin as ConversationProvider).partnerId;
}

String _$chatHistoryHash() => r'1f9a2ca02c6fcf1f05cbd18f87622c01da5a8f20';

/// See also [chatHistory].
@ProviderFor(chatHistory)
final chatHistoryProvider = FutureProvider<List<ChatConversation>>.internal(
  chatHistory,
  name: r'chatHistoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$chatHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatHistoryRef = FutureProviderRef<List<ChatConversation>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
