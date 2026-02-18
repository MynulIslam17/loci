import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/controllers/nav_controller.dart';

import '../../../core/theme/app_colors.dart';
import '../../../gen/assets.gen.dart';
import '../../pages/event/event_screen.dart';
import '../../pages/home/home_screen.dart';
import '../../pages/network/network_screen.dart';
import '../../pages/profile/profile_screen.dart';
import '../../pages/search/search_screen.dart';

class MainBottomNav extends StatefulWidget {
  const MainBottomNav({super.key});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  final navController = Get.find<NavController>();



  final List<Map<String, dynamic>> drawerMenuItems = [
    {'title': 'QR Code', 'icon': 'qr_code'},
    {'title': 'Explore Routes', 'icon': 'map'},
    {'title': 'Upcoming Events', 'icon': 'calander'},
    {'title': 'Active Raffles', 'icon': 'rafel'},
    {'title': 'Recent Activity', 'icon': 'paper'},
    {'title': 'Business Profiles', 'icon': 'building'},
    {'title': 'Subscription', 'icon': 'qrown'},
    {'title': 'About App', 'icon': 'about'},
    {'title': 'Settings', 'icon': 'setting'},
    {'title': 'Terms & Conditions', 'icon': 'paper'},
    {'title': 'Sign Out', 'icon': 'logout', 'isDanger': true},
  ];





  final List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
    EventScreen(),
    NetworkScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,

      /// drawer
      drawer: Drawer(

        backgroundColor: context.colorScheme.surface,
        child: Column(
          children: [

            // --- CUSTOM HEADER START ---

            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHigh,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 30),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [


                    CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage(
                        Assets.images.user1.path,

                      ),
                    ),

                    const SizedBox(width: 20,),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text("Mynul Islam",style: AppTextStyle.textLg(color: context.colorScheme.onSurface,weight: FontWeight.w600),),
                        Text("Business name",style: AppTextStyle.textXs(color: context.colorScheme.onSurfaceVariant,),),



                      ],
                    )




                  ],
                ),
              ),
            ),



            // --- list of item  START ---

            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: drawerMenuItems.length,
                itemBuilder: (context, index) {
                  final item = drawerMenuItems[index];
                  final bool isDanger = item['isDanger'] ?? false; // Check if it's "Sign Out"

                  return ListTile(
                    onTap: () => Get.back(),
                    leading: SvgPicture.asset(
                      'assets/icons/${item["icon"]}.svg',
                      width: 20,
                      height: 20,

                      colorFilter: ColorFilter.mode(
                        isDanger ? Colors.red : context.colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                    title: Text(
                      item["title"],
                      style: AppTextStyle.textSm(
                        color: isDanger ? Colors.red : context.colorScheme.onSurface,
                        weight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            )

          ],
        ),




      ),


      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.05),

        toolbarHeight: 64,


        leading:  Builder(builder: (context){
          return IconButton(
            onPressed: () {

              Scaffold.of(context).openDrawer();

            },
            icon: const Icon(Icons.menu_rounded),
            padding: const EdgeInsets.all(8),
            splashRadius: 20,
          );
        }),

        title: Text(
          "Hello Mynul !",
          style: AppTextStyle.textLg(
            color: context.colorScheme.onSurface,
            weight: FontWeight.w600,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            splashRadius: 20,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.forum_outlined),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            splashRadius: 20,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            splashRadius: 20,
          ),

          const SizedBox(width: 4),
        ],



      ),



      body: SafeArea(
        child: GetBuilder<NavController>(
          builder: (controller) {
            return _screens[controller.currentIndex];
          },
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: GetBuilder<NavController>(
            builder: (controller) {
              return BottomNavigationBar(
                currentIndex: controller.currentIndex,
                onTap: (index) {
                  controller.changeIndex(index);
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                // Icon Styling
                iconSize: 20,
                selectedIconTheme: IconThemeData(
                  color: context.colorScheme.primary,
                  size: 27,
                ),
                unselectedIconTheme: IconThemeData(
                  color: context.colorScheme.onSurfaceVariant,
                  size: 22,
                ),

                // Text Styling
                selectedLabelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.primary,
                  height: 1.2,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: context.colorScheme.onSurfaceVariant,
                  height: 1.2,
                ),

                showSelectedLabels: true,
                showUnselectedLabels: true,

                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home_outlined),
                    activeIcon: const Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.search_outlined),
                    activeIcon: const Icon(Icons.search_rounded),
                    label: 'Browse',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.calendar_month_outlined),
                    activeIcon: const Icon(Icons.calendar_month_rounded),
                    label: 'Event',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.groups_outlined),
                    activeIcon: const Icon(Icons.groups_rounded),
                    label: 'Network',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person_outline),
                    activeIcon: const Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
