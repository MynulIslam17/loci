import 'package:get/get.dart';
import 'package:loci/core/enums/network_type.dart';
import 'package:loci/core/utils/paginated_list_fetch_state.dart';
import 'package:loci/features/network/data/models/checkin_item.dart';
import 'package:loci/features/network/data/models/dashboard_count.dart';
import 'package:loci/features/network/domain/services/network_service.dart';

/// Dashboard stats and recent check-ins for [NetworkScreen].
class NetworkDashboardController extends GetxController {
  NetworkDashboardController(this._service);

  final NetworkService _service;
  final PaginatedListFetchState _fetch = PaginatedListFetchState();

  final Rxn<String> _errorMessage = Rxn<String>();
  final Rxn<DashboardCounts> _counts = Rxn<DashboardCounts>();
  final RxList<CheckInModel> _checkins = <CheckInModel>[].obs;

  bool get isInitialLoading => _fetch.initialLoading.value;
  bool get isRefreshing => _fetch.refreshing.value;
  bool get showInitialShimmer => _fetch.showInitialShimmer;
  bool get hasFetched => _fetch.hasFetched.value;
  bool get isLoading => isInitialLoading;
  String? get errorMessage => _errorMessage.value;
  DashboardCounts? get counts => _counts.value;
  List<CheckInModel> get checkins => List.unmodifiable(_checkins);

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard({bool isRefresh = false}) async {
    if (isInitialLoading || isRefreshing) return;

    _fetch.beginFirstPage(isRefresh: isRefresh);
    _errorMessage.value = null;

    try {
      final model = await _service.getDashboard(NetworkType.checkins);
      _counts.value = model.data.counts;
      _checkins.assignAll(
        model.data.activity.data.cast<CheckInModel>(),
      );
      _fetch.endFirstPage();
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      _fetch.endFirstPage(markFetched: hasFetched);
    }
  }

  Future<void> refreshDashboard() => fetchDashboard(isRefresh: true);
}
