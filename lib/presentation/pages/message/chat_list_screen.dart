import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/routes/app_routes.dart';
import '../../widgets/custom_text_field.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {

  /// List containing chat data
  /// Each map represents one chat item
  final List<Map<String, dynamic>> chatData = [
    {
      "name": "Leah Smith",
      "lastMessage": "Did you finish your morning meeting?",
      "image": "assets/images/user1.jpg",
      "unreadCount": 1,
      "isOnline": true,
    },
    {
      "name": "Leslie Alexander",
      "lastMessage": "I really recommend the Caesar salad!",
      "image": "assets/images/user2.jpg",
      "unreadCount": 2,
      "isOnline": true,
    },
    {
      "name": "Julian Howard",
      "lastMessage": "Almost! I had to push it to after work today!",
      "image": "assets/images/user3.jpg",
      "unreadCount": 0,
      "isOnline": false,
    },
    {
      "name": "Theresa Webb",
      "lastMessage": "This meeting was so good! Thank you.",
      "image": "assets/images/user4.jpg",
      "unreadCount": 0,
      "isOnline": false,
    },
  ];

  @override
  Widget build(BuildContext context) {

    /// Access theme colors easily
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppbar(title: "Chats"),

      body: SafeArea(
        child: Column(
          children: [

            /// ---------------- SEARCH BAR ----------------
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomTextField(
                hintText: "Search chats",
                borderColor: colorScheme.outline,
                fontSize: 14,
                textColor: colorScheme.onSurface,
                hintTextColor: colorScheme.onSurfaceVariant,
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            /// ---------------- CHAT LIST ----------------
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: chatData.length,
                itemBuilder: (context, index) {

                  /// Current chat item
                  final chat = chatData[index];

                  return Card(
                    elevation: 0.5,
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: colorScheme.surfaceContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),

                      /// ---------- PROFILE IMAGE + ONLINE INDICATOR ----------
                      leading: Stack(
                        children: [

                          /// User profile image
                          CustomCachedImage(
                            width: 55,
                            height: 55,
                            imageUrl: chat["image"],
                            isCircle: true,
                          ),

                          /// Online green indicator
                          if (chat["isOnline"])
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.surface,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      /// ---------- USER NAME ----------
                      title: Text(
                        chat["name"],
                        style: AppTextStyle.textMd(
                          color: colorScheme.onSurface,
                          weight: FontWeight.w600,
                        ),
                      ),

                      /// ---------- LAST MESSAGE ----------
                      subtitle: Text(
                        chat["lastMessage"],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.textSm(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),

                      /// ---------- TRAILING SECTION ----------
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [

                          /// If there are unread messages show badge
                          if (chat["unreadCount"] > 0)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                chat["unreadCount"].toString(),
                                style: AppTextStyle.textXs(
                                  color: colorScheme.onPrimary,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            )

                          /// Otherwise show arrow icon
                          else
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: colorScheme.outlineVariant,
                            ),
                        ],
                      ),

                      /// When chat item is tapped
                      onTap: () {
                        // TODO: Navigate to chat screen
                        Get.toNamed(AppRoutes.message);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}