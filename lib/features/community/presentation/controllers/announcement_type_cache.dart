import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/shared/models/pagination_model.dart';

/// Per-tab list cache for [AnnouncementController].
class AnnouncementTypeCache {
  AnnouncementTypeCache(this.type);

  final AnnouncementType type;
  final ids = <String>[];
  int currentPage = 1;
  PaginationMeta? meta;
  bool hasLoaded = false;
  bool isLoading = false;
  bool isRefreshing = false;
  bool isPaginationLoading = false;
  String? errorMessage;
  String searchQuery = '';

  bool get hasMore => meta?.hasNextPage ?? false;
  bool get isEmpty => ids.isEmpty;
}
