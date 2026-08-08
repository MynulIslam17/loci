import 'package:get/get.dart';
import 'package:loci/core/enums/network_type.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/chat/data/models/conversation_model.dart';
import 'package:loci/features/chat/domain/services/chat_service.dart';
import 'package:loci/features/network/data/models/connection_item.dart';
import 'package:loci/features/network/domain/services/network_service.dart';

/// Backs the "new chat" picker: you can only message your connections, so it
/// lists them (searchable) and starts/reuses the direct conversation on tap.
class NewChatController extends GetxController {
  NewChatController(this._networkService, this._chatService);

  final NetworkService _networkService;
  final ChatService _chatService;

  /// Cached connections are served instantly; a silent background refresh
  /// only runs when the cache is older than this.
  static const Duration _cacheTtl = Duration(minutes: 2);
  DateTime? _lastFetchedAt;
  bool _isFetching = false;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxList<ConnectionModel> connections = <ConnectionModel>[].obs;
  final RxString searchQuery = ''.obs;

  /// userId of the connection whose conversation is being created (spinner).
  final RxnString startingUserId = RxnString();

  List<ConnectionModel> get filteredConnections {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return connections;
    return connections
        .where(
          (c) =>
              c.name.toLowerCase().contains(query) ||
              c.organization.toLowerCase().contains(query),
        )
        .toList();
  }

  void onSearchChanged(String query) => searchQuery.value = query;

  /// Event-driven invalidation: called when the user's connections change
  /// (QR connect, remove connection) so the next open refetches regardless
  /// of the TTL.
  void markStale() => _lastFetchedAt = null;

  /// Called every time the picker opens. Shows the cached list instantly and
  /// only hits the network on first open, after an error, or when stale.
  Future<void> ensureLoaded() async {
    final neverLoaded = connections.isEmpty && _lastFetchedAt == null;
    if (neverLoaded || errorMessage.value != null) return fetchConnections();

    final isStale = _lastFetchedAt == null ||
        DateTime.now().difference(_lastFetchedAt!) > _cacheTtl;
    if (isStale) return _refreshSilently();
  }

  /// Full load with spinner — first open and explicit retry.
  Future<void> fetchConnections() async {
    if (_isFetching) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await _fetch();
    } catch (e) {
      errorMessage.value = AppErrorMessages.sanitize(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Background revalidation: keeps showing the cached list, and on failure
  /// silently keeps the cache instead of surfacing an error.
  Future<void> _refreshSilently() async {
    if (_isFetching) return;
    try {
      await _fetch();
    } catch (_) {
      // Stale cache is still more useful than an error screen here.
    }
  }

  Future<void> _fetch() async {
    _isFetching = true;
    try {
      final model = await _networkService.getDashboard(NetworkType.connections);
      connections.assignAll(model.data.activity.data.cast<ConnectionModel>());
      _lastFetchedAt = DateTime.now();
    } finally {
      _isFetching = false;
    }
  }

  /// Creates (or reuses — the endpoint is idempotent) the direct conversation
  /// with [connection]. Returns null and shows a snackbar on failure.
  Future<ConversationModel?> startChat(ConnectionModel connection) async {
    final userId =
        connection.userId.isNotEmpty ? connection.userId : connection.id;
    if (userId.isEmpty || startingUserId.value != null) return null;

    startingUserId.value = userId;
    try {
      return await _chatService.createConversation(userId);
    } catch (e) {
      SnackbarService.error(AppErrorMessages.sanitize(e));
      return null;
    } finally {
      startingUserId.value = null;
    }
  }
}
