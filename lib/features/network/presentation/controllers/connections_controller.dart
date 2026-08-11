import 'package:get/get.dart';
import 'package:loci/core/enums/network_type.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/chat/presentation/controllers/new_chat_controller.dart';
import 'package:loci/features/network/data/models/connection_item.dart';
import 'package:loci/features/network/domain/services/network_service.dart';

import 'package:loci/features/network/presentation/controllers/network_dashboard_controller.dart';

/// Connections list, search, and refresh for [ConnectionScreen].
class ConnectionsController extends GetxController {
  ConnectionsController(this._service);

  final NetworkService _service;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final Rxn<String> _errorMessage = Rxn<String>();
  final RxList<ConnectionModel> _connections = <ConnectionModel>[].obs;
  final RxString _searchQuery = ''.obs;
  final RxSet<String> _removingIds = <String>{}.obs;

  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  bool get isLoading => isInitialLoading;
  String? get errorMessage => _errorMessage.value;
  String get searchQuery => _searchQuery.value;
  List<ConnectionModel> get connections => List.unmodifiable(_connections);

  bool isRemoving(String id) => _removingIds.contains(id);

  List<ConnectionModel> get filteredConnections {
    final query = _searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return connections;

    return connections.where((connection) {
      return connection.name.toLowerCase().contains(query) ||
          connection.email.toLowerCase().contains(query) ||
          connection.organization.toLowerCase().contains(query) ||
          connection.phone.toLowerCase().contains(query);
    }).toList();
  }

  bool get hasSearchResults => filteredConnections.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    fetchConnections();
  }

  void onSearchChanged(String query) => _searchQuery.value = query;

  void clearSearch() => _searchQuery.value = '';

  Future<void> fetchConnections({bool isRefresh = false}) async {
    if (isInitialLoading || isRefreshing) return;

    _fetch.beginFirstPage(isRefresh: isRefresh);
    _errorMessage.value = null;

    try {
      final model = await _service.getDashboard(NetworkType.connections);
      _connections.assignAll(
        model.data.activity.data.cast<ConnectionModel>(),
      );
      _fetch.endFirstPage();
    } catch (e) {
      _errorMessage.value = AppErrorMessages.sanitize(e);
      _fetch.endFirstPage(markFetched: hasFetched);
    }
  }

  Future<void> refreshConnections() => fetchConnections(isRefresh: true);

  Future<bool> removeConnection(ConnectionModel connection) async {
    final targetId =
        connection.userId.isNotEmpty ? connection.userId : connection.id;
    if (targetId.isEmpty) return false;

    _removingIds.add(connection.id);
    try {
      await _service.removeConnection(otherUserId: targetId);
      _connections.removeWhere((item) => item.id == connection.id);

      if (Get.isRegistered<NetworkDashboardController>()) {
        Get.find<NetworkDashboardController>().fetchDashboard(isRefresh: true);
      }
      if (Get.isRegistered<NewChatController>()) {
        Get.find<NewChatController>().markStale();
      }

      SnackbarService.success('Connection removed');
      return true;
    } catch (e) {
      SnackbarService.error(AppErrorMessages.sanitize(e));
      return false;
    } finally {
      _removingIds.remove(connection.id);
    }
  }
}
