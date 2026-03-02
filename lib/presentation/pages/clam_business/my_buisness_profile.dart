import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/custom_image_container.dart';
import '../../widgets/custom_imagepicker.dart';
// Ensure these paths match your project structure
// import '../../widgets/custom_imagepicker.dart';
// import '../../widgets/custom_cached_image.dart';

class MyBusinessProfile extends StatefulWidget {
  const MyBusinessProfile({super.key});

  @override
  State<MyBusinessProfile> createState() => _MyBusinessProfileState();
}

class _MyBusinessProfileState extends State<MyBusinessProfile> {
  // State variables for images
  File? _profileImage;
  File? _heroAdImage;
  final List<File> _photos = [];

  final ImagePicker _picker = ImagePicker();
  final Color primaryTeal = const Color(0xFF64BDB1);

  // API images (replace later with real API response)
  final List<String> _apiPhotos = [
    "https://picsum.photos/seed/1/400/300",
    "https://picsum.photos/seed/2/400/300",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Business profile",
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildDescriptionCard(),
            const SizedBox(height: 25),
            _buildSectionHeader("Photos"),
            _buildPhotoGrid(),
            const SizedBox(height: 25),
            _buildSectionHeader("Advertisements"),
            _buildPollCreator(),
            const SizedBox(height: 12),
            _buildWideButton("Explore Activities"),
            const SizedBox(height: 25),
            _buildSectionHeader("Hero Ads"),
            _buildHeroAdPicker(),
            const SizedBox(height: 12),
            _buildWideButton("+ Create New Ads"),
            const SizedBox(height: 25),
            _buildSectionHeader("Reviews", showViewAll: true),
            _buildReviewsList(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // ================= PROFILE HEADER =================

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryTeal.withOpacity(0.5), width: 1),
              ),
              child: CustomCachedImage(
                imageFile: _profileImage,
                imageUrl: "https://via.placeholder.com/150",
                height: 110,
                width: 110,
                isCircle: true,
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: _editCircleButton(() {
                _showImageSourceDialog((file) => setState(() => _profileImage = file));
              }),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text("Marland Clutch", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryTeal)),
        const SizedBox(height: 4),
        const Text("23601 Hoover Rd, Warren, MI 48089", style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text("+1 800-216-3515", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text("Maintenance & Repair | Services & More", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("3 Review  ", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ...List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 16)),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionChip("Community", null),
            const SizedBox(width: 12),
            _buildActionChip("QR", Icons.qr_code_scanner),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            padding: const EdgeInsets.symmetric(horizontal: 40),
          ),
          child: Text("Change Subscription", style: TextStyle(color: primaryTeal)),
        ),
      ],
    );
  }

  // ================= DESCRIPTION =================

  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 25),
            child: Text(
              "Marland Clutch, founded in 1931, is a prominent global manufacturer specializing in heavy duty industrial backstopping and overrunning clutches...",
              style: TextStyle(color: Colors.black54, height: 1.5, fontSize: 13),
            ),
          ),
          Positioned(right: 0, top: 0, child: Icon(Icons.edit_outlined, color: primaryTeal, size: 20)),
        ],
      ),
    );
  }

  // ================= PHOTO GRID =================

  Widget _buildPhotoGrid() {
    final int totalImages = _apiPhotos.length + _photos.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: totalImages + 1, // +1 for Add button
      itemBuilder: (context, index) {

        /// ADD BUTTON (always last)
        if (index == totalImages) {
          return _buildAddPhotoButton();
        }

        /// API IMAGES
        if (index < _apiPhotos.length) {
          return Stack(
            children: [
              CustomCachedImage(
                imageUrl: _apiPhotos[index],
                width: double.infinity,
                height: double.infinity,
                borderRadius: 12,
              ),
              Positioned(
                right: 5,
                top: 5,
                child: _editCircleButton(() {
                  setState(() {
                    _apiPhotos.removeAt(index);
                  });
                }, size: 20),
              ),
            ],
          );
        }

        /// LOCAL IMAGES
        final localIndex = index - _apiPhotos.length;

        return Stack(
          children: [
            CustomCachedImage(
              imageFile: _photos[localIndex],
              width: double.infinity,
              height: double.infinity,
              borderRadius: 12,
            ),
            Positioned(
              right: 5,
              top: 5,
              child: _editCircleButton(() {
                setState(() {
                  _photos.removeAt(localIndex);
                });
              }, size: 20),
            ),
          ],
        );
      },
    );
  }

  // ================= HERO AD =================

  Widget _buildHeroAdPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomImagePicker(
          selectedImage: _heroAdImage,
          imageUrl: "https://via.placeholder.com/400x200", // Default ad image
          height: 180,
          borderRadius: 15,
          onImageSelected: (file) => setState(() => _heroAdImage = file),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Ads will run February 2, 2026", style: TextStyle(color: Colors.grey, fontSize: 11)),
            Text("Credit remain: 10", style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        )
      ],
    );
  }

  // ================= POLL & REVIEWS =================

  Widget _buildPollCreator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Create a poll", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              hintText: "Create a poll...",
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              suffixIcon: Icon(Icons.send_outlined, color: primaryTeal.withOpacity(0.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    return Column(
      children: List.generate(2, (index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade100),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 18, backgroundImage: NetworkImage("https://i.pravatar.cc/150")),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Alexandra Broke", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text("Barclay Pizza", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
                Row(children: List.generate(5, (i) => const Icon(Icons.star, color: Colors.amber, size: 14))),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "This was one of the most epic experience, that I've got myself involved in!",
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      )),
    );
  }

  // ================= UTILITY HELPERS =================

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: () => _showImageSourceDialog((file) => setState(() => _photos.add(file))),
      child: Container(
        decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.image_outlined, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text("Add image", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(String label, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(color: primaryTeal, borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 6)],
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildWideButton(String label) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showViewAll = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTeal)),
          if (showViewAll) const Text("view all", style: TextStyle(color: Color(0xFF64BDB1), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _editCircleButton(VoidCallback onTap, {double size = 26}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Icon(Icons.edit_outlined, size: size * 0.7, color: primaryTeal),
      ),
    );
  }

  void _showImageSourceDialog(Function(File) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) onSelected(File(image.path));
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                if (image != null) onSelected(File(image.path));
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}