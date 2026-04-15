import 'package:flutter/material.dart';
import 'app_back_button.dart'; // Make sure this path is correct

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true, // By default, the back arrow will show
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,

      // 1. The Left Side (Back Arrow)
      leading: showBackButton
          ? const Padding(
        padding: EdgeInsets.only(left: 16),
        child: AppBackButton(),
      )
          : null, // Hides the back button completely if false

      // 2. The Center (Title)
      centerTitle: true,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),

      // 3. The Right Side (Icons like 'more_vert')
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}