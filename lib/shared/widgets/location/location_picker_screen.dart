import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/places/domain/services/places_service.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/location/location_models.dart';
import 'package:loci/shared/widgets/location/location_picker_controller.dart';

/// Full-screen address search. Opened with `Get.to<PickedLocation?>(...)` and
/// returns a [PickedLocation] (address + coordinates) via `Get.back(result:)`,
/// or null if dismissed.
///
/// NOTE: the draggable pin-confirm step is intentionally not wired here yet —
/// [_onTap] resolves coordinates from the details endpoint and returns them
/// directly. When the map step is added, insert it between [resolve] and the
/// `Get.back`.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, this.title = 'Search location'});

  final String title;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late final LocationPickerController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = LocationPickerController(Get.find<PlacesService>());
  }

  @override
  void dispose() {
    _controller.close();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onTap(PlacePrediction prediction) async {
    final details = await _controller.resolve(prediction);
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
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: CustomTextField(
              controller: _searchController,
              hintText: 'Search address or place',
              autofocus: true,
              showClearButton: true,
              onChanged: _controller.onQueryChanged,
              onClear: () => _controller.onQueryChanged(''),
              prefixIcon: const Icon(Icons.search, size: 20),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_controller.isResolving.value ||
                  _controller.isSearching.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_controller.errorMessage.value != null) {
                return _MessageState(
                  icon: Icons.error_outline,
                  text: _controller.errorMessage.value!,
                );
              }
              if (!_controller.hasQuery) {
                return const _MessageState(
                  icon: Icons.location_searching,
                  text: 'Start typing an address to search',
                );
              }
              if (_controller.results.isEmpty) {
                return const _MessageState(
                  icon: Icons.search_off,
                  text:
                      'No places found.\nTry a street address, or drop a pin manually.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _controller.results.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                itemBuilder: (context, index) {
                  final p = _controller.results[index];
                  return ListTile(
                    leading: Icon(
                      Icons.place_outlined,
                      color: colorScheme.primary,
                    ),
                    title: Text(
                      p.mainText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.textMd(
                        color: colorScheme.onSurface,
                        weight: FontWeight.w600,
                      ),
                    ),
                    subtitle: p.secondaryText.isEmpty
                        ? null
                        : Text(
                            p.secondaryText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.textSm(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                    onTap: () => _onTap(p),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 44, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
