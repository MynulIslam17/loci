import 'package:get/get.dart';
import 'package:loci/core/enums/network_type.dart';
import 'package:loci/features/network/data/models/checkin_item.dart';
import 'package:loci/features/network/data/models/dashboard_count.dart';
import 'package:loci/features/network/domain/services/network_service.dart';

/// Dashboard stats and recent check-ins for [NetworkScreen].
class NetworkDashboardController extends GetxController {
  NetworkDashboardController(this._service);

  final NetworkService _service;

  final RxBool _isLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();
  final Rxn<DashboardCounts> _counts = Rxn<DashboardCounts>();
  final RxList<CheckInModel> _checkins = <CheckInModel>[].obs;

  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  DashboardCounts? get counts => _counts.value;
  List<CheckInModel> get checkins => List.unmodifiable(_checkins);

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final model = await _service.getDashboard(NetworkType.checkins);
      _counts.value = model.data.counts;
      _checkins.assignAll(
        model.data.activity.data.cast<CheckInModel>(),
      );
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() => fetchDashboard();
}
