import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SecondaryAppHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onRightIconTap;
  final bool showBack;
  final bool showRight;
  final IconData rightIcon;
  final List<Widget>? extraActions;
  final Widget? titleWidget;
  final bool centerTitle;
  final Color? backgroundColor;
  final double elevation;

  const SecondaryAppHeader({
    Key? key,
    required this.title,
    this.onBack,
    this.onRightIconTap,
    this.showRight = true,
    this.showBack = true,
    this.rightIcon = Icons.more,
    this.extraActions,
    this.titleWidget,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation = 0,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final titleStyle = theme.appBarTheme.titleTextStyle?.copyWith(
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ) ??
        TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        );

    final List<Widget> actionsList = [];
    if (extraActions != null) {
      actionsList.addAll(extraActions!);
    }
    if (showRight) {
      actionsList.add(
        IconButton(
          icon: Icon(rightIcon),
          onPressed: onRightIconTap,
        ),
      );
    }

    return AppBar(
      title: titleWidget ??
          Text(
            title,
            style: titleStyle,
          ),
      centerTitle: centerTitle,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: onBack ?? () => Get.back(),
            )
          : null,
      automaticallyImplyLeading: false,
      actions: actionsList.isNotEmpty ? actionsList : null,
      elevation: elevation,
      backgroundColor: backgroundColor ??
          theme.appBarTheme.backgroundColor ??
          colorScheme.surface,
      scrolledUnderElevation: 0,
    );
  }
}
