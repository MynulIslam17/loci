import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  /// --- State for billing toggle: true = Monthly, false = One-time ---
  bool _isMonthly = true;

  /// --- Track which subscription card is expanded ---
  int? _expandedIndex;

  /// --- Mock subscription plans data ---
  final List<Map<String, dynamic>> _plans = [
    {
      "id": "starter",
      "category_title": "Get Discovered",
      "plan_name": "Free",
      "price": 0,
      "description": "Start here and let locals find you naturally.",
      "button_text": "Join For Free",
      "benefits": ["Basic Profile", "Search Visibility", "Local Discovery"],
    },
    {
      "id": "pro",
      "category_title": "Be Seen",
      "plan_name": "50",
      "price": 50,
      "description":
      "Step into the conversation and build trust with your audience.",
      "button_text": "Increase Visibility",
      "benefits": [
        "Everything in Free",
        "75 Hero Spotlight credits/month",
        "Priority Support",
      ],
    },
    {
      "id": "enterprise",
      "category_title": "Build Locally",
      "plan_name": "75",
      "price": 75,
      "description": "Turn visibility into engagement, events, and momentum.",
      "button_text": "Increase Engagement",
      "benefits": [
        "Everything in \$50 package",
        "Create & promote events",
        "Create Routes / Shop-Hops",
        "200 Hero Spotlight credits/month",
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: "Subscription Plan"),
      body: Column(
        children: [
          const SizedBox(height: 20),

          /// --- Billing Toggle Switch ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child:Row(
                children: [
                  _buildBillingToggle(
                    title: "Monthly",
                    isSelected: _isMonthly,
                    onTap: () => setState(() => _isMonthly = true),
                    colorScheme: colorScheme,
                  ),
                  _buildBillingToggle(
                    title: "Billed One-time",
                    isSelected: !_isMonthly,
                    onTap: () => setState(() => _isMonthly = false),
                    colorScheme: colorScheme,
                  ),
                ],
              )
            ),
          ),

          const SizedBox(height: 10),

          /// --- List of subscription cards ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _plans.length,
              itemBuilder: (context, index) {
                final plan = _plans[index];
                return _buildSubscriptionCard(plan, colorScheme, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// --- Build individual subscription card ---
  Widget _buildSubscriptionCard(
      Map<String, dynamic> plan, ColorScheme colorScheme, int index) {
    final bool isExpanded = _expandedIndex == index;
    final bool isFree = plan['price'] == 0;

    return Card(

      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
      ),
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Plan category/title
            Text(
              plan['category_title'],
              style: AppTextStyle.textSm(
                color: colorScheme.onSurface,
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            /// Price display
            Text(
              isFree ? "Free" : "\$${plan['price']}${_isMonthly ? '/month' : ''}",
              style: AppTextStyle.textXl(
                color: colorScheme.primary,
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            /// Plan description
            Text(
              plan['description'],
              style: AppTextStyle.textXs(
                color: colorScheme.onSurfaceVariant,
                weight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),

            /// --- Expand / Collapse button ---
            InkWell(
              onTap: () {
                setState(() {
                  _expandedIndex = isExpanded ? null : index;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isExpanded ? "Hide benefits" : "See benefits",
                    style: AppTextStyle.textSm(
                      color: colorScheme.onSurface,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 20,
                    color: colorScheme.onSurface,
                  ),
                ],
              ),
            ),

            /// --- Animated list of benefits ---
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity,),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: (plan['benefits'] as List<String>).map((benefit) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check, color: colorScheme.primary, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              benefit,
                              style: AppTextStyle.textXs(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),

            const SizedBox(height: 16),

            /// --- Action Button ---
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(plan['button_text']),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// --- Build a reusable billing toggle button ---

  Widget _buildBillingToggle({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 48,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTextStyle.textSm(
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              weight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}