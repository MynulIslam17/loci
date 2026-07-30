import 'package:get/get.dart';
import 'package:loci/core/enums/network_type.dart';
import 'package:loci/features/network/data/models/connection_item.dart';
import 'package:loci/features/network/domain/services/network_service.dart';

/// Connections list, search, and refresh for [ConnectionScreen].
class ConnectionsController extends GetxController {
  ConnectionsController(this._service);

  final NetworkService _service;

  final RxBool _isLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();
  final RxList<ConnectionModel> _connections = <ConnectionModel>[].obs;
  final RxString _searchQuery = ''.obs;

  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  String get searchQuery => _searchQuery.value;
  List<ConnectionModel> get connections => List.unmodifiable(_connections);
  bool get isInitialLoading => isLoading && _connections.isEmpty;

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

  Future<void> fetchConnections() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final model = await _service.getDashboard(NetworkType.connections);
      _connections.assignAll(
        model.data.activity.data.cast<ConnectionModel>(),
      );
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshConnections() => fetchConnections();
}
