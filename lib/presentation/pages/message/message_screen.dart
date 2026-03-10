import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  // --- Data Structure ---
  final List<Map<String, dynamic>> messages = [
    {
      "text": "Hey, did you finish your morning meeting? I'm on the way Washington dc warehouse.",
      "isMe": true,
      "time": "8:30 AM"
    },
    {
      "text": "Almost! I had to push it to after work today. But I won't skip it!",
      "isMe": false,
      "time": "8:32 AM"
    },
    {
      "text": "I'll send you a post-meeting selfie!",
      "isMe": false,
      "time": "8:32 AM"
    },
    {
      "text": "No worries, just don't skip it! You've been consistent all week for this.",
      "isMe": true,
      "time": "8:35 AM"
    },
    {
      "text": "I'll give you update our inventory slot.",
      "isMe": true,
      "time": "8:35 AM"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CustomCachedImage(
              width: 40,
              height: 40,
              imageUrl: "assets/images/user1.png",
              isCircle: true,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Leah Smith",
                  style: AppTextStyle.textSm(
                    color: colorScheme.onSurface,
                    weight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Business name",
                  style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          /// --- Message List ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final bool isMe = msg["isMe"];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isMe) ...[
                        const CustomCachedImage(
                          width: 30,
                          height: 30,
                          imageUrl: "assets/images/user2.png",
                          isCircle: true,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe
                                ? colorScheme.primary
                                : colorScheme.onSurface.withOpacity(0.1),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 16),
                            ),
                          ),
                          child: Text(
                            msg["text"],
                            style: AppTextStyle.textSm(
                              color: isMe ? Colors.white : colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          /// --- Input Field ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
            ),
            child: TextField(
              maxLines: 2,
              minLines: 1,
              decoration: InputDecoration(
                hintText: "Your message...",
                hintStyle: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                filled: true,
                fillColor: colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                suffixIcon: SizedBox(
                  width: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(child: IconButton(onPressed: (){}, icon: Icon(Icons.attach_file, color: colorScheme.onSurfaceVariant, size: 20))),
                      const SizedBox(width: 10),
                      Expanded(child: IconButton(onPressed: (){}, icon: Icon(Icons.sentiment_satisfied_alt, color: colorScheme.onSurfaceVariant, size: 20))),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}