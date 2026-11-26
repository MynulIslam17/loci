import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Hides the keyboard (whatever field has focus).
void hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

/// Wraps a form so the keyboard is always easy to dismiss:
/// * on iOS a "Done" bar sits on top of the keyboard while it's open — the
///   number pad, phone pad and multi-line fields have no key that closes it;
/// * tapping anywhere outside a field closes it;
/// * the focused field is always scrolled fully into view above the keyboard
///   (and the Done bar) — not just the line with the cursor.
///
/// Use it as (or around) a Scaffold body. The bar takes real layout space, so
/// it never covers a field or a bottom button.
class KeyboardDoneArea extends StatefulWidget {
  const KeyboardDoneArea({super.key, required this.child, this.showDoneBar});

  final Widget child;

  /// Defaults to iOS only (Android keyboards have their own close key).
  final bool? showDoneBar;

  @override
  State<KeyboardDoneArea> createState() => _KeyboardDoneAreaState();
}

class _KeyboardDoneAreaState extends State<KeyboardDoneArea>
    with WidgetsBindingObserver {
  bool _keyboardOpen = false;
  Timer? _revealTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FocusManager.instance.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    FocusManager.instance.removeListener(_onFocusChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Moving to another field while the keyboard is up.
  void _onFocusChanged() {
    if (_keyboardOpen) _revealFocusedField();
  }

  /// After the next layout (keyboard + Done bar in place), scroll so the
  /// whole focused field — border, label area and counter — is visible.
  void _revealFocusedField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final BuildContext? focused = FocusManager.instance.primaryFocus?.context;
      if (focused == null || !focused.mounted) return;
      final BuildContext target = _fieldContext(focused);
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }

  /// The decorated field (InputDecorator) around the focused editable text,
  /// so the full box is revealed rather than only the cursor line.
  static BuildContext _fieldContext(BuildContext focused) {
    BuildContext target = focused;
    int depth = 0;
    focused.visitAncestorElements((Element element) {
      if (element.widget is InputDecorator) {
        target = element;
        return false;
      }
      return ++depth < 30;
    });
    return target;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncKeyboard();
  }

  @override
  void didChangeMetrics() => _syncKeyboard();

  // Scaffold strips the keyboard inset from its body's MediaQuery, so read
  // the raw inset from the view itself.
  void _syncKeyboard() {
    if (!mounted) return;
    final bool open = View.of(context).viewInsets.bottom > 0;
    // The inset changes every frame while the keyboard animates; reveal the
    // field once it has settled.
    if (open) {
      _revealTimer?.cancel();
      _revealTimer = Timer(
        const Duration(milliseconds: 120),
        _revealFocusedField,
      );
    }
    if (open != _keyboardOpen) setState(() => _keyboardOpen = open);
  }

  @override
  Widget build(BuildContext context) {
    final bool showBar =
        _keyboardOpen &&
        (widget.showDoneBar ?? defaultTargetPlatform == TargetPlatform.iOS);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: hideKeyboard,
      child: Column(
        children: <Widget>[
          Expanded(child: widget.child),
          if (showBar) const KeyboardDoneBar(),
        ],
      ),
    );
  }
}

/// The thin bar with a "Done" button shown above the keyboard.
class KeyboardDoneBar extends StatelessWidget {
  const KeyboardDoneBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHigh,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: colors.outlineVariant, width: 0.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.centerRight,
        child: TextButton(
          key: const Key('keyboard_done'),
          onPressed: hideKeyboard,
          child: Text(
            'Done',
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
