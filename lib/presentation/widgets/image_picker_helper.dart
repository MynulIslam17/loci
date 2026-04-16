import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

//======== IMAGE PICKER HELPER METHOD=====================
class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<List<File>> pick({
    required bool multi,
    required ImageSource source,
  }) async {
    if (multi) {
      final files = await _picker.pickMultiImage();
      return files.map((e) => File(e.path)).toList();
    } else {
      final file = await _picker.pickImage(source: source);
      if (file == null) return [];
      return [File(file.path)];
    }
  }
}


// ================= IMAGE PICKER BOTTOMSHEET=================
void showImagePickerSheet({
  required BuildContext context,
  required Function(List<File>) onPicked,
  bool allowMultiple = false,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

             if(!allowMultiple)...[
               ListTile(
                 leading: const Icon(Icons.photo_library),
                 title: const Text("Gallery"),
                 onTap: () async {
                   final files = await ImagePickerHelper.pick(
                     multi: allowMultiple,
                     source: ImageSource.gallery,
                   );

                   if (ctx.mounted) Navigator.pop(ctx);
                   onPicked(files);
                 },
               ),

               ListTile(
                 leading: const Icon(Icons.camera_alt),
                 title: const Text("Camera"),
                 onTap: () async {
                   final files = await ImagePickerHelper.pick(
                     multi: false,
                     source: ImageSource.camera,
                   );

                   if (ctx.mounted) Navigator.pop(ctx);
                   onPicked(files);
                 },
               ),

             ],


            if (allowMultiple)
              ListTile(
                leading: const Icon(Icons.collections),
                title: const Text("Multiple Select"),
                onTap: () async {
                  final files = await ImagePickerHelper.pick(
                    multi: true,
                    source: ImageSource.gallery,
                  );

                  if (ctx.mounted) Navigator.pop(ctx);
                  onPicked(files);
                },
              ),
          ],
        ),
      );
    },
  );
}