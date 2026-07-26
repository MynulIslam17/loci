import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

class ReviewBox extends StatefulWidget {
  final Future<void> Function(String review, double rating)? onSubmit;

  const ReviewBox({super.key, this.onSubmit});

  @override
  State<ReviewBox> createState() => _ReviewBoxState();
}

class _ReviewBoxState extends State<ReviewBox> {
  final TextEditingController _controller = TextEditingController();
  final _rating = 0.0.obs;
  final _isSubmitting = false.obs;
  final _textRevision = 0.obs;

  static const int _maxWords = 100;
  static const _purple = Color(0xFF7F77DD);
  static const _labels = ['', 'Poor', 'Fair', 'Good', 'Very good', 'Excellent'];

  int get _wordCount {
    _textRevision.value;
    return _controller.text.trim().isEmpty
        ? 0
        : _controller.text.trim().split(RegExp(r'\s+')).length;
  }

  bool get _canSubmit =>
      _rating.value > 0 &&
      _controller.text.trim().isNotEmpty &&
      _wordCount <= _maxWords;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit || _isSubmitting.value) return;
    _isSubmitting.value = true;
    try {
      await widget.onSubmit?.call(_controller.text.trim(), _rating.value);
      _controller.clear();
      _rating.value = 0;
      _textRevision.value++;
    } finally {
      if (mounted) _isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Card(
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Write your review',
                  style: AppTextStyle.textMd(weight: FontWeight.w500),
                ),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      KeyedSubtree(
                        key: ValueKey(_rating.value),
                        child: RatingBar.builder(
                          initialRating: _rating.value,
                          minRating: 1,
                          itemSize: 20,
                          glow: false,
                          unratedColor: colors.outline.withOpacity(0.4),
                          itemBuilder: (_, __) => const Icon(
                            Icons.star_rounded,
                            color: Color(0xFF7F77DD),
                          ),
                          onRatingUpdate: (val) => _rating.value = val,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _rating.value == 0
                            ? 'Tap to rate'
                            : _labels[_rating.value.toInt()],
                        style: AppTextStyle.textXs(
                          color: _rating.value == 0
                              ? colors.onSurfaceVariant
                              : _purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(height: 1, color: colors.outline.withOpacity(0.3)),
            const SizedBox(height: 12),

            // ── Text field ────────────────────────────────────────────────
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                TextField(
                  controller: _controller,
                  maxLines: 4,
                  minLines: 3,
                  onChanged: (val) {
                    // Block input beyond 100 words
                    final words = val.trim().isEmpty
                        ? 0
                        : val.trim().split(RegExp(r'\s+')).length;
                    if (words > _maxWords) {
                      final allowed = val
                          .trim()
                          .split(RegExp(r'\s+'))
                          .take(_maxWords)
                          .join(' ');
                      _controller.value = TextEditingValue(
                        text: allowed,
                        selection: TextSelection.collapsed(
                          offset: allowed.length,
                        ),
                      );
                    }
                    _textRevision.value++;
                  },
                  style: AppTextStyle.textSm(color: colors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Write your review within 100 words...',
                    hintStyle: AppTextStyle.textSm(
                      color: colors.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: colors.surface,
                    contentPadding: const EdgeInsets.fromLTRB(12, 12, 48, 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: colors.outline.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: colors.outline.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _purple, width: 1.5),
                    ),
                  ),
                ),

                // ── Send button ───────────────────────────────────────────
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Obx(() {
                    // Touch BOTH observables up front so the button re-evaluates
                    // on a rating change OR a text change. Reading _canSubmit
                    // alone isn't enough: its && short-circuits, so setting the
                    // star first would skip subscribing to _textRevision and the
                    // colour wouldn't update when text is typed afterwards.
                    _rating.value;
                    _textRevision.value;
                    final canSubmit = _canSubmit;
                    return GestureDetector(
                      onTap: _submit,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: canSubmit
                              ? _purple
                              : colors.outline.withOpacity(0.3),
                        ),
                        child: _isSubmitting.value
                            ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                      ),
                    );
                  }),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ── Word count ────────────────────────────────────────────────
            Obx(() {
              _textRevision.value;
              return Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$_wordCount / $_maxWords words',
                  style: AppTextStyle.textXs(color: colors.onSurfaceVariant),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
