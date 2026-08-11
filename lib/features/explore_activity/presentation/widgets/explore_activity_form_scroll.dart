import 'package:flutter/material.dart';

/// Standard scroll + dismiss-keyboard wrapper for create/edit forms.
class ExploreActivityFormScroll extends StatelessWidget {
  const ExploreActivityFormScroll({
    super.key,
    required this.formKey,
    required this.children,
  });

  final GlobalKey<FormState> formKey;
  final List<Widget> children;

  static const EdgeInsets padding = EdgeInsets.fromLTRB(16, 12, 16, 28);

  static EdgeInsets paddingOf(BuildContext context) {
    return padding.copyWith(
      bottom: 28 + MediaQuery.viewPaddingOf(context).bottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: formKey,
        child: ListView(
          padding: paddingOf(context),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: children,
        ),
      ),
    );
  }
}
