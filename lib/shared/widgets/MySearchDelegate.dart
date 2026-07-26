import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/main_nav/presentation/controllers/nav_controller.dart';
import 'package:loci/features/routes/presentation/pages/explore_routes_screen.dart';
import 'package:loci/features/raffles/presentation/pages/active_raffles_screen.dart';
import 'package:loci/routes/app_routes.dart';

/// Logical grouping shown as a section header in the results list.
enum _FeatureCategory {
  main('Main'),
  network('Network'),
  business('Business & Ads'),
  community('Community'),
  utilities('Utilities'),
  account('Account & Settings');

  const _FeatureCategory(this.label);
  final String label;
}

/// One searchable section/feature in the app.
class _FeatureEntry {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final _FeatureCategory category;
  final List<String> keywords;
  final void Function(BuildContext context) onSelect;

  const _FeatureEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.category,
    required this.onSelect,
    this.keywords = const [],
  });

  /// Higher score = better match.  0 = no match.
  int score(String query) {
    if (query.isEmpty) return 1;
    final q = query.toLowerCase();
    final t = title.toLowerCase();
    if (t == q) return 100;
    if (t.startsWith(q)) return 80;
    if (t.contains(q)) return 60;
    if (subtitle.toLowerCase().contains(q)) return 30;
    for (final k in keywords) {
      if (k.toLowerCase().contains(q)) return 15;
    }
    return 0;
  }
}

class MySearchDelegate extends SearchDelegate {
  MySearchDelegate() : super(searchFieldLabel: "Search features & sections");

  static const _kRecentKey = 'global_search_recent_ids';
  static const _kMaxRecents = 5;

  final GetStorage _box = GetStorage();
  late final List<_FeatureEntry> _features = _buildFeatures();

  // ── Catalog ──────────────────────────────────────────────────────────────

  List<_FeatureEntry> _buildFeatures() {
    final nav = Get.find<NavController>();

    void goToTab(BuildContext context, int index) {
      close(context, null);
      nav.changeIndex(index);
    }

    void goToRoute(BuildContext context, String route) {
      close(context, null);
      Get.toNamed(route);
    }

    // Drawer-style pages need to be pushed inside MainBottomNav's Scaffold
    // (via NavController.openDrawerPage), not via Get.toNamed — they don't
    // ship their own Scaffold and would otherwise crash with "No Material
    // widget found" because of their inner TextField.
    void goToDrawerPage(
      BuildContext context,
      Widget page,
      GlobalKey<NavigatorState> navigatorKey,
    ) {
      close(context, null);
      nav.openDrawerPage(page, navigatorKey: navigatorKey);
    }

    return [
      // ── Main ──
      _FeatureEntry(
        id: 'tab_home',
        title: 'Home',
        subtitle: 'Feed, ads, questions and polls',
        icon: Icons.home_rounded,
        category: _FeatureCategory.main,
        keywords: const ['feed', 'questions', 'polls', 'ads'],
        onSelect: (ctx) => goToTab(ctx, 0),
      ),
      _FeatureEntry(
        id: 'tab_browse',
        title: 'Browse Businesses',
        subtitle: 'Discover and search businesses near you',
        icon: Icons.storefront_outlined,
        category: _FeatureCategory.main,
        keywords: const ['business', 'discover', 'places', 'shops'],
        onSelect: (ctx) => goToTab(ctx, 1),
      ),
      _FeatureEntry(
        id: 'tab_events',
        title: 'Events',
        subtitle: 'Upcoming events and RSVPs',
        icon: Icons.calendar_month_rounded,
        category: _FeatureCategory.main,
        keywords: const ['rsvp', 'calendar', 'upcoming'],
        onSelect: (ctx) => goToTab(ctx, 2),
      ),
      _FeatureEntry(
        id: 'tab_network',
        title: 'Network',
        subtitle: 'Connections, referrals and meetings',
        icon: Icons.groups_rounded,
        category: _FeatureCategory.main,
        keywords: const ['people', 'contacts', 'connect'],
        onSelect: (ctx) => goToTab(ctx, 3),
      ),
      _FeatureEntry(
        id: 'tab_profile',
        title: 'Profile',
        subtitle: 'Your account and personal info',
        icon: Icons.person_rounded,
        category: _FeatureCategory.main,
        keywords: const ['account', 'me', 'avatar'],
        onSelect: (ctx) => goToTab(ctx, 4),
      ),

      // ── Network ──
      _FeatureEntry(
        id: 'connections',
        title: 'Connections',
        subtitle: 'View and manage your connections',
        icon: Icons.people_alt_outlined,
        category: _FeatureCategory.network,
        keywords: const ['friends', 'contacts'],
        onSelect: (ctx) => goToRoute(ctx, AppRoutes.connection),
      ),
      _FeatureEntry(
        id: 'meetings',
        title: 'Meetings',
        subtitle: 'Scheduled meetings and invitations',
        icon: Icons.event_available_outlined,
        category: _FeatureCategory.network,
        keywords: const ['calls', 'agenda', 'invite'],
        onSelect: (ctx) => goToRoute(ctx, AppRoutes.meeting),
      ),
      _FeatureEntry(
        id: 'schedule_meeting',
        title: 'Schedule a Meeting',
        subtitle: 'Book a new meeting',
        icon: Icons.event_outlined,
        category: _FeatureCategory.network,
        keywords: const ['book', 'create meeting', 'plan'],
        onSelect: (ctx) => goToRoute(ctx, AppRoutes.scheduleMeeting),
      ),
      _FeatureEntry(
        id: 'referrals',
        title: 'Referrals',
        subtitle: 'Referrals you have received',
        icon: Icons.handshake_outlined,
        category: _FeatureCategory.network,
        keywords: const ['recommend', 'intro'],
        onSelect: (ctx) => goToRoute(ctx, AppRoutes.referral),
      ),
      _FeatureEntry(
        id: 'send_referral',
        title: 'Send Referral',
        subtitle: 'Refer a contact to someone',
        icon: Icons.send_outlined,
        category: _FeatureCategory.network,
        keywords: const ['recommend', 'introduce', 'share'],
        onSelect: (ctx) => goToRoute(ctx, AppRoutes.sendReferral),
      ),

      // ── Business & Ads ──
      _FeatureEntry(
        id: 'my_business',
        title: 'My Business Profiles',
        subtitle: 'Manage businesses you have claimed',
        icon: Icons.business_center_outlined,
        category: _FeatureCategory.business,
        keywords: const ['my business', 'claim', 'owner'],
        onSelect: (ctx) => goToRoute(ctx, AppRoutes.searchBusiness),
      ),
      // "Create Ad" is intentionally not exposed in global search — it only
      // makes sense from a specific business profile (it expects a
      // `businessName` argument to lock the field).

      // ── Community ──
      _FeatureEntry(
        id: 'communities',
        title: 'Communities',
        subtitle: 'Browse and join communities',
        icon: Icons.diversity_3_rounded,
        category: _FeatureCategory.community,
        keywords: const ['groups', 'community'],
        onSelect: (ctx) => goToRoute(ctx, AppRoutes.allCommunity),
      ),

      // ── Utilities ──
      _FeatureEntry(
        id: 'qr',
        title: 'My QR Code',
        subtitle: 'Show your personal QR code',
        icon: Icons.qr_code_2_rounded,
        category: _FeatureCategory.utilities,
        keywords: const ['qrcode', 'scan', 'share'],
        onSelect: (ctx) => goToRoute(ctx, AppRoutes.myQrCode),
      ),
      _FeatureEntry(
        id: 'checkin',
        title: 'Check In',
        subtitle: 'Scan a code to check in',
        icon: Icons.qr_code_scanner_rounded,
        category: _FeatureCategory.utilities,
        keywords: const ['scan', 'attendance', 'arrive'],
        onSelect: (ctx) => goToRoute(ctx, AppRoutes.checkIn),
      ),
      _FeatureEntry(
        id: 'routes',
        title: 'Explore Routes',
        subtitle: 'Discover curated routes',
        icon: Icons.map_outlined,
        category: _FeatureCategory.utilities,
        keywords: const ['map', 'trail', 'discover'],
        onSelect: (ctx) => goToDrawerPage(
          ctx,
          const ExploreRoutesScreen(),
          ExploreRoutesScreen.navigatorKey,
        ),
      ),
      _FeatureEntry(
        id: 'raffles',
        title: 'Active Raffles',
        subtitle: 'Browse current raffles and prizes',
        icon: Icons.confirmation_number_outlined,
        category: _FeatureCategory.utilities,
        keywords: const ['ticket', 'prize', 'win', 'lottery'],
        onSelect: (ctx) => goToDrawerPage(
          ctx,
          const ActiveRafflesScreen(),
          ActiveRafflesScreen.navigatorKey,
        ),
      ),
      _FeatureEntry(
        id: 'recent_activity',
        title: 'Recent Activity',
        subtitle: 'Your recent actions across the app',
        icon: Icons.history_rounded,
        category: _FeatureCategory.utilities,
        keywords: const ['history', 'log', 'timeline'],
        onSelect: (ctx) => goToRoute(ctx, AppRoutes.recentActivity),
      ),
      _FeatureEntry(
        id: 'messages',
        title: 'Messages',
        subtitle: 'Your conversations',
        icon: Icons.forum_outlined,
        category: _FeatureCategory.utilities,
        keywords: const ['chat', 'inbox', 'dm'],
        onSelect: (ctx) => goToRoute(ctx, AppRoutes.chatList),
      ),
      _FeatureEntry(
        id: 'notifications',
        title: 'Notifications',
        subtitle: 'Recent alerts and updates',
        icon: Icons.notifications_outlined,
        category: _FeatureCategory.utilities,
        keywords: const ['alerts', 'updates'],
        onSelect: (ctx) => goToRoute(ctx, AppRoutes.notification),
      ),

      // ── Account & Settings ──
      _FeatureEntry(
        id: 'subscription',
        title: 'Subscription',
        subtitle: 'Manage your plan and billing',
        icon: Icons.workspace_premium_outlined,
        category: _FeatureCategory.account,
        keywords: const ['plan', 'billing', 'premium', 'pro'],
        onSelect: (ctx) => goToRoute(ctx, AppRoutes.subscription),
      ),
      _FeatureEntry(
        id: 'settings',
        title: 'Settings',
        subtitle: 'App preferences and account settings',
        icon: Icons.settings_outlined,
        category: _FeatureCategory.account,
        keywords: const ['preferences', 'config', 'options'],
        onSelect: (ctx) => goToRoute(ctx, AppRoutes.settings),
      ),
      _FeatureEntry(
        id: 'change_password',
        title: 'Change Password',
        subtitle: 'Update your account password',
        icon: Icons.lock_outline,
        category: _FeatureCategory.account,
        keywords: const ['password', 'security', 'reset'],
        onSelect: (ctx) => goToRoute(ctx, AppRoutes.changePassword),
      ),
      _FeatureEntry(
        id: 'delete_account',
        title: 'Delete Account',
        subtitle: 'Permanently remove your account',
        icon: Icons.delete_outline,
        category: _FeatureCategory.account,
        keywords: const ['remove', 'close account'],
        onSelect: (ctx) => goToRoute(ctx, AppRoutes.deleteAccount),
      ),
      _FeatureEntry(
        id: 'about',
        title: 'About App',
        subtitle: 'About Loci',
        icon: Icons.info_outline,
        category: _FeatureCategory.account,
        keywords: const ['version', 'info'],
        onSelect: (ctx) => goToRoute(ctx, AppRoutes.about),
      ),
      _FeatureEntry(
        id: 'terms',
        title: 'Terms & Conditions',
        subtitle: 'Read our terms of service',
        icon: Icons.description_outlined,
        category: _FeatureCategory.account,
        keywords: const ['terms', 'tos', 'legal', 'policy'],
        onSelect: (ctx) => goToRoute(ctx, AppRoutes.terms),
      ),
    ];
  }

  /// IDs we surface in the empty-state "Suggested" row.
  static const _suggestedIds = <String>{
    'tab_home',
    'tab_browse',
    'notifications',
    'subscription',
    'qr',
  };

  // ── Recents persistence ──────────────────────────────────────────────────

  List<String> _readRecents() {
    final raw = _box.read<List<dynamic>>(_kRecentKey) ?? const [];
    return raw.whereType<String>().toList();
  }

  void _pushRecent(String id) {
    final list = _readRecents()..remove(id);
    list.insert(0, id);
    while (list.length > _kMaxRecents) {
      list.removeLast();
    }
    _box.write(_kRecentKey, list);
  }

  void _removeRecent(String id) {
    final list = _readRecents()..remove(id);
    _box.write(_kRecentKey, list);
  }

  _FeatureEntry? _findById(String id) {
    for (final f in _features) {
      if (f.id == id) return f;
    }
    return null;
  }

  void _selectFeature(BuildContext context, _FeatureEntry entry) {
    _pushRecent(entry.id);
    entry.onSelect(context);
  }

  // ── Theming ──────────────────────────────────────────────────────────────

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return theme.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: AppTextStyle.textLg(
          weight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: AppTextStyle.textSm(color: scheme.onSurfaceVariant),
        border: InputBorder.none,
      ),
    );
  }

  @override
  TextStyle? get searchFieldStyle =>
      AppTextStyle.textMd(weight: FontWeight.w500);

  // ── App bar controls ─────────────────────────────────────────────────────

  @override
  List<Widget>? buildActions(BuildContext context) {
    if (query.isEmpty) return const [];
    return [
      IconButton(
        tooltip: 'Clear',
        onPressed: () => query = '',
        icon: const Icon(Icons.close_rounded),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }

  // ── Bodies ───────────────────────────────────────────────────────────────

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    final q = query.trim();
    return q.isEmpty
        ? _EmptyStateBody(
            delegate: this,
            recents: _readRecents()
                .map(_findById)
                .whereType<_FeatureEntry>()
                .toList(),
            suggested: _features
                .where((f) => _suggestedIds.contains(f.id))
                .toList(),
            all: _features,
          )
        : _ResultsBody(delegate: this, query: q, features: _features);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty-state (no query): Recent + Suggested + All-by-category
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyStateBody extends StatefulWidget {
  final MySearchDelegate delegate;
  final List<_FeatureEntry> recents;
  final List<_FeatureEntry> suggested;
  final List<_FeatureEntry> all;

  const _EmptyStateBody({
    required this.delegate,
    required this.recents,
    required this.suggested,
    required this.all,
  });

  @override
  State<_EmptyStateBody> createState() => _EmptyStateBodyState();
}

class _EmptyStateBodyState extends State<_EmptyStateBody> {
  late final RxList<_FeatureEntry> _recents;

  @override
  void initState() {
    super.initState();
    _recents = RxList<_FeatureEntry>(widget.recents);
  }

  void _removeRecent(_FeatureEntry entry) {
    widget.delegate._removeRecent(entry.id);
    _recents.removeWhere((e) => e.id == entry.id);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final grouped = _groupByCategory(widget.all);

    return Obx(() {
      return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        // ── Recent ──
        if (_recents.isNotEmpty) ...[
          _SectionHeader(
            label: 'Recent',
            trailing: TextButton(
              onPressed: () {
                widget.delegate._box.remove(MySearchDelegate._kRecentKey);
                _recents.clear();
              },
              child: Text(
                'Clear',
                style: AppTextStyle.textXs(
                  color: scheme.primary,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ..._recents.map(
            (e) => _FeatureRow(
              entry: e,
              query: '',
              onTap: () => widget.delegate._selectFeature(context, e),
              onLongPress: () => _removeRecent(e),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // ── Suggested ──
        _SectionHeader(label: 'Suggested'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.suggested
              .map((e) => _SuggestionChip(
                    entry: e,
                    onTap: () => widget.delegate._selectFeature(context, e),
                  ))
              .toList(),
        ),
        const SizedBox(height: 24),

        // ── All sections by category ──
        _SectionHeader(label: 'All sections'),
        for (final entry in grouped.entries) ...[
          const SizedBox(height: 12),
          _CategoryLabel(label: entry.key.label),
          ...entry.value.map(
            (e) => _FeatureRow(
              entry: e,
              query: '',
              onTap: () => widget.delegate._selectFeature(context, e),
            ),
          ),
        ],
      ],
    );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Results body (with query): grouped by category, scored, highlighted
// ─────────────────────────────────────────────────────────────────────────────

class _ResultsBody extends StatelessWidget {
  final MySearchDelegate delegate;
  final String query;
  final List<_FeatureEntry> features;

  const _ResultsBody({
    required this.delegate,
    required this.query,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    final scored = <(_FeatureEntry, int)>[];
    for (final f in features) {
      final s = f.score(query);
      if (s > 0) scored.add((f, s));
    }
    scored.sort((a, b) => b.$2.compareTo(a.$2));

    if (scored.isEmpty) {
      return _NoResults(query: query);
    }

    final grouped = _groupByCategory(scored.map((e) => e.$1).toList());

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        for (final entry in grouped.entries) ...[
          _CategoryLabel(label: entry.key.label),
          ...entry.value.map(
            (e) => _FeatureRow(
              entry: e,
              query: query,
              onTap: () => delegate._selectFeature(context, e),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Visual primitives
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Widget? trailing;
  const _SectionHeader({required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyle.textMd(
              weight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _CategoryLabel extends StatelessWidget {
  final String label;
  const _CategoryLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyle.textXs(
          weight: FontWeight.w700,
          color: scheme.onSurfaceVariant,
        ).copyWith(letterSpacing: 0.8),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final _FeatureEntry entry;
  final String query;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _FeatureRow({
    required this.entry,
    required this.query,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(entry.icon, size: 20, color: scheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HighlightedText(
                      text: entry.title,
                      query: query,
                      baseStyle: AppTextStyle.textMd(
                        weight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                      highlightColor: scheme.primary,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.textXs(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.north_east_rounded,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final _FeatureEntry entry;
  final VoidCallback onTap;
  const _SuggestionChip({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(entry.icon, size: 16, color: scheme.primary),
              const SizedBox(width: 6),
              Text(
                entry.title,
                style: AppTextStyle.textSm(
                  weight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle baseStyle;
  final Color highlightColor;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: baseStyle);
    }
    final lower = text.toLowerCase();
    final q = query.toLowerCase();
    final idx = lower.indexOf(q);
    if (idx < 0) {
      return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: baseStyle);
    }
    final before = text.substring(0, idx);
    final match = text.substring(idx, idx + query.length);
    final after = text.substring(idx + query.length);
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: before),
          TextSpan(
            text: match,
            style: baseStyle.copyWith(
              color: highlightColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 36,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No matches for "$query"',
              textAlign: TextAlign.center,
              style: AppTextStyle.textMd(
                weight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try another keyword like "qr", "raffles", or "billing".',
              textAlign: TextAlign.center,
              style: AppTextStyle.textSm(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Map<_FeatureCategory, List<_FeatureEntry>> _groupByCategory(
  List<_FeatureEntry> items,
) {
  final map = <_FeatureCategory, List<_FeatureEntry>>{};
  for (final cat in _FeatureCategory.values) {
    final group = items.where((f) => f.category == cat).toList();
    if (group.isNotEmpty) map[cat] = group;
  }
  return map;
}
