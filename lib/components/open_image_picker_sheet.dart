import 'package:flutter/material.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

Future<dynamic> openImagePickerSheet(controller) {
  return Get.bottomSheet(
    Container(
      height: 150,
      color: themeAccentOrange,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FoduuButtonWithIcon(
            name: "Camera",
            onPressed: () {
              Get.back();
              controller.getImageFromGalleryOrCamera(ImageSource.camera);
            },
            icon: Icons.camera_alt_outlined,
          ),
          const SizedBox(width: 20),
          FoduuButtonWithIcon(
            name: "Gallery",
            onPressed: () {
              Get.back();
              controller.getImageFromGalleryOrCamera(ImageSource.gallery);
            },
            icon: Icons.photo_library_outlined,
          ),
        ],
      ),
    ),
    isDismissible: true,
  );
}

class FoduuButtonWithIcon extends StatelessWidget {
  const FoduuButtonWithIcon({
    Key? key,
    required this.name,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  final String name;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipOval(
          child: Material(
            color: context.themePrimaryColor, // Button color
            child: InkWell(
              splashColor: Colors.red, // Splash color
              onTap: onPressed,
              child: SizedBox(
                width: 70,
                height: 70,
                child: Icon(
                  icon,
                  size: 35,
                  color: context.colors.onPrimary,
                ),
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            name,
            style: TextStyle(
              color: context.themeTextColor,
            ),
          ),
        ),
      ],
    );
  }
}
