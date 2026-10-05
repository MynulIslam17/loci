import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/auth/presentation/widgets/auth_parallax_header.dart';
import 'package:loci/gen/assets.gen.dart';

/// Shared image header and scrolling form surface for authentication pages.
class AuthCollapsingScaffold extends StatefulWidget {
  const AuthCollapsingScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  State<AuthCollapsingScaffold> createState() => _AuthCollapsingScaffoldState();
}

class _AuthCollapsingScaffoldState extends State<AuthCollapsingScaffold> {
  static const _expandedHeight = 360.0;
  static const _toolbarHeight = 64.0;
  static const _collapseDistance = _expandedHeight - _toolbarHeight;
  static const _panelOverlap = 40.0;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final surfaceColor = colors.surface;
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: surfaceColor,
      body: LayoutBuilder(
        builder: (context, viewport) {
          // Short forms still need enough scroll range to fully collapse the
          // header. The panel fills the space below the pinned toolbar.
          final minimumPanelHeight =
              (viewport.maxHeight - topInset - _toolbarHeight).clamp(
                0.0,
                double.infinity,
              );

          return CustomScrollView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: surfaceColor,
                surfaceTintColor: Colors.transparent,
                scrolledUnderElevation: 0,
                pinned: true,
                expandedHeight: _expandedHeight,
                toolbarHeight: _toolbarHeight,
                stretch: true,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final expandedFraction =
                        ((constraints.maxHeight - topInset - _toolbarHeight) /
                                _collapseDistance)
                            .clamp(0.0, 1.0);
                    final imageOpacity = ((expandedFraction - 0.08) / 0.35)
                        .clamp(0.0, 1.0);
                    final barOpacity = ((0.45 - expandedFraction) / 0.35).clamp(
                      0.0,
                      1.0,
                    );

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Opacity(
                          opacity: imageOpacity,
                          child: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            stretchModes: const [StretchMode.zoomBackground],
                            background: AuthParallaxHeader(
                              firstImage: Assets.images.onimg5,
                              secondImage: Assets.images.onimg6,
                            ),
                          ),
                        ),
                        IgnorePointer(
                          ignoring: barOpacity < 0.95,
                          child: Opacity(
                            opacity: barOpacity,
                            child: SafeArea(
                              bottom: false,
                              child: SizedBox(
                                height: _toolbarHeight,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Text(
                                      widget.title,
                                      style: AppTextStyle.textLg(
                                        color: colors.onSurface,
                                        weight: FontWeight.w700,
                                      ),
                                    ),
                                    if (Navigator.canPop(context))
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 12,
                                          ),
                                          child: IconButton(
                                            tooltip: 'Back',
                                            onPressed: () => Navigator.of(
                                              context,
                                            ).maybePop(),
                                            icon: const Icon(
                                              Icons.arrow_back_rounded,
                                            ),
                                            color: colors.onSurface,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minimumPanelHeight),
                  child: AnimatedBuilder(
                    animation: _scrollController,
                    builder: (context, child) {
                      final offset = _scrollController.hasClients
                          ? _scrollController.offset
                          : 0.0;
                      final expandedFraction = (1 - offset / _collapseDistance)
                          .clamp(0.0, 1.0);
                      return Transform.translate(
                        offset: Offset(0, -_panelOverlap * expandedFraction),
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 40),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
