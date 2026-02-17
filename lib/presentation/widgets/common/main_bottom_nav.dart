// import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:lock_smith_car_service/core/constants/app_colors.dart';
// import 'package:lock_smith_car_service/presentation/pages/home/home_screen.dart';
// import 'package:lock_smith_car_service/presentation/pages/job/my_jobs_screen.dart';
// import 'package:lock_smith_car_service/presentation/pages/profile/profile_screen.dart';
//
// class MainBottomNav extends StatefulWidget {
//   const MainBottomNav({super.key});
//
//   @override
//   State<MainBottomNav> createState() => _MainBottomNavState();
// }
//
// class _MainBottomNavState extends State<MainBottomNav> {
//   int _bottomNavIndex = 0;
//
//
//   final List<Widget>_screens=[
//     HomeScreen(),
//     MyJobsScreen(),
//     ProfileScreen()
//
//   ];
//
//
//   final List<Map<String, String>> navItems = [
//     {'icon': 'assets/icons/home.svg', 'label': 'Home'},
//     {'icon': 'assets/icons/bag.svg', 'label': 'My Jobs'},
//     {'icon': 'assets/icons/user.svg', 'label': 'Profile'},
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: _screens[_bottomNavIndex],
//       bottomNavigationBar: AnimatedBottomNavigationBar.builder(
//       itemCount: _screens.length,
//
//       height: 68,
//       tabBuilder: (int index, bool isActive) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             // Icon in a small circle
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: isActive ? Colors.white : Colors.transparent,
//                 shape: BoxShape.circle,
//               ),
//               child: SvgPicture.asset(
//                 navItems[index]['icon']!,
//                 height: 19,
//                 colorFilter: ColorFilter.mode(
//                   isActive ? AppColors.red500 : Colors.white.withOpacity(0.8),
//                   BlendMode.srcIn,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 5), // small gap
//             // Label
//             Text(
//               navItems[index]['label']!,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 10,
//                 fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
//                 height: 1.0,
//               ),
//             ),
//             const SizedBox(height: 4),
//           ],
//         );
//       },
//       backgroundColor: AppColors.red500,
//       activeIndex: _bottomNavIndex,
//       gapLocation: GapLocation.none,
//       leftCornerRadius: 32,
//       rightCornerRadius: 32,
//       //notchSmoothness: NotchSmoothness.smoothEdge,
//       onTap: (index) => setState(() => _bottomNavIndex = index),
//     ),
//     );
//   }
// }