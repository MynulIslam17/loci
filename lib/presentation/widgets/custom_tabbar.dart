// import 'package:flutter/material.dart';
// import '../../core/constants/app_colors.dart';
//
// class CustomPillTabBar extends StatelessWidget {
//   final TabController tabController;
//   final List<String> tabs;
//
//   const CustomPillTabBar({
//     super.key,
//     required this.tabController,
//     required this.tabs,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // ✅ Use AnimatedBuilder to REBUILD when tabController.index changes
//     return AnimatedBuilder(
//       animation: tabController,
//       builder: (context, child) {
//         return Container(
//           decoration: const BoxDecoration(
//             border: Border(
//               bottom: BorderSide(color: Colors.red, width: 1.0),
//             ),
//           ),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: List.generate(tabs.length, (index) {
//                 // ✅ Get current index from tabController (always fresh)
//                 final isSelected = tabController.index == index;
//
//                 return GestureDetector(
//                   onTap: () => tabController.animateTo(index),
//                   child: Container(
//                     margin: const EdgeInsets.only(right: 8),
//                     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                     decoration: BoxDecoration(
//                       color: isSelected ? AppColors.red500 : Colors.white,
//                       border: Border.all(color: Colors.red, width: 1),
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(12),
//                         topRight: Radius.circular(12),
//                       ),
//                     ),
//                     child: Text(
//                       tabs[index],
//                       style: TextStyle(
//                         color: isSelected ? Colors.white : Colors.black87,
//                         fontWeight: FontWeight.w500,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }