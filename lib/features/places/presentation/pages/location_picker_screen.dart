import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/places/data/models/place_models.dart';
import 'package:loci/features/places/domain/services/places_service.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/form_labels.dart';
import 'package:uuid/uuid.dart';

/// Full-screen address search. Returns a [PickedLocation] via `Get.back`, or
/// null if dismissed.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, this.title = 'Choose location'});

  final String title;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late final _LocationPickerSession _session;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _session = _LocationPickerSession(Get.find<PlacesService>());
  }

  @override
  void dispose() {
    _session.close();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onTap(PlacePrediction prediction) async {
    final details = await _session.resolve(prediction);
    if (details == null || !mounted) return;

    Get.back(
      result: PickedLocation(
        address: details.address,
        lat: details.lat,
        lng: details.lng,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppbar(title: widget.title),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find your place',
                      style: AppTextStyle.textMd(
                        weight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Search by street, neighborhood, or business name.',
                      style: AppTextStyle.textSm(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: CustomTextField(
                      controller: _searchController,
                      hintText: 'Search address or place',
                      autofocus: true,
                      showClearButton: true,
                      onChanged: _session.onQueryChanged,
                      onClear: () => _session.onQueryChanged(''),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      borderColor: colorScheme.outline,
                      fillColor: colorScheme.surface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (_session.isSearching.value) {
                    return _LoadingState(colorScheme: colorScheme);
                  }
                  if (_session.errorMessage.value != null) {
                    return _EmptyState(
                      icon: Icons.error_outline,
                      title: 'Something went wrong',
                      subtitle: _session.errorMessage.value!,
                      iconColor: colorScheme.error,
                      iconBackground: colorScheme.errorContainer
                          .withValues(alpha: 0.45),
                    );
                  }
                  if (!_session.hasQuery) {
                    return _EmptyState(
                      icon: Icons.location_searching,
                      title: 'Start searching',
                      subtitle: _session.query.value.trim().isEmpty
                          ? 'Enter at least 3 characters to see matching places.'
                          : 'Keep typing — at least 3 characters needed.',
                      iconColor: colorScheme.primary,
                      iconBackground:
                          colorScheme.primary.withValues(alpha: 0.1),
                    );
                  }
                  if (_session.results.isEmpty) {
                    return _EmptyState(
                      icon: Icons.search_off,
                      title: 'No places found',
                      subtitle:
                          'Try a different spelling, a nearby landmark, or a full street address.',
                      iconColor: colorScheme.primary,
                      iconBackground:
                          colorScheme.primary.withValues(alpha: 0.1),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FormSectionLabel(
                          label: 'Results (${_session.results.length})',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: _session.results.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final prediction = _session.results[index];
                            return _PlaceResultTile(
                              prediction: prediction,
                              onTap: () => _onTap(prediction),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
          Obx(() {
            if (!_session.isResolving.value) return const SizedBox.shrink();
            return Container(
              color: colorScheme.scrim.withValues(alpha: 0.35),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Confirming location…',
                        style: AppTextStyle.textMd(
                          weight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fetching coordinates for your selection',
                        textAlign: TextAlign.center,
                        style: AppTextStyle.textSm(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PlaceResultTile extends StatelessWidget {
  const _PlaceResultTile({
    required this.prediction,
    required this.onTap,
  });

  final PlacePrediction prediction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHigh,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.place_outlined,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prediction.mainText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.textMd(
                        color: colorScheme.onSurface,
                        weight: FontWeight.w600,
                      ),
                    ),
                    if (prediction.secondaryText.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        prediction.secondaryText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.textSm(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBackground,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyle.textMd(
                weight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Searching places…',
            style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Session-scoped search state for one picker open.
class _LocationPickerSession {
  _LocationPickerSession(this._service);

  final PlacesService _service;
  final String sessionToken = const Uuid().v4();

  static const int _minChars = 3;
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  Timer? _debounce;
  int _requestSeq = 0;

  final RxString query = ''.obs;
  final RxList<PlacePrediction> results = <PlacePrediction>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool isResolving = false.obs;
  final Rxn<String> errorMessage = Rxn<String>();

  bool get hasQuery => query.value.trim().length >= _minChars;

  void onQueryChanged(String value) {
    query.value = value;
    _debounce?.cancel();

    final trimmed = value.trim();
    if (trimmed.length < _minChars) {
      results.clear();
      isSearching.value = false;
      errorMessage.value = null;
      return;
    }

    _debounce = Timer(_debounceDelay, () => _search(trimmed));
  }

  Future<void> _search(String q) async {
    final seq = ++_requestSeq;
    isSearching.value = true;
    errorMessage.value = null;

    try {
      final res = await _service.autocomplete(
        query: q,
        sessionToken: sessionToken,
      );
      if (seq != _requestSeq) return;
      results.assignAll(res);
    } catch (e) {
      if (seq != _requestSeq) return;
      results.clear();
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (seq == _requestSeq) isSearching.value = false;
    }
  }

  Future<PlaceDetails?> resolve(PlacePrediction prediction) async {
    isResolving.value = true;
    errorMessage.value = null;
    try {
      return await _service.details(
        placeId: prediction.placeId,
        sessionToken: sessionToken,
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isResolving.value = false;
    }
  }

  void close() => _debounce?.cancel();
}
