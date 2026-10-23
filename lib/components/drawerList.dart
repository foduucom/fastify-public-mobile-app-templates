// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';

// class drawerList extends StatelessWidget {
//   const drawerList({
//     Key? key,
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.pressevent,
//   }) : super(key: key);

//   final String icon;
//   final String title;
//   final String subtitle;
//   final VoidCallback pressevent;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 60,
//       child: GestureDetector(
//         onTap: pressevent,
//         child: ListTile(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//           minLeadingWidth: 0,
//           leading: Container(
//             height: double.infinity,
//             child: SvgPicture.asset(
//               icon,
//               width: 20,
//             ),
//           ),
//           title: Text(title,
//               style: const TextStyle(
//                   fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
//           subtitle: Text(subtitle,
//               style: const TextStyle(fontFamily: 'Poppins', fontSize: 12)),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zouhi/constants/theme_ext.dart';

class drawerList extends StatefulWidget {
  const drawerList({
    Key? key,
    this.icon = '',
    this.iconData,
    required this.title,
    required this.subtitle,
    required this.pressevent,
    this.children,
    this.trailing,
    this.badgeText,
  }) : super(key: key);

  final String icon;
  final IconData? iconData;
  final String title;
  final String subtitle;
  final VoidCallback pressevent;
  final List<Widget>? children; // List of nested options
  final Widget? trailing;
  final String? badgeText;

  @override
  _DrawerListState createState() => _DrawerListState();
}

class _DrawerListState extends State<drawerList> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded; // Toggle expansion
            });
            widget.pressevent(); // Call the main event
          },
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            minLeadingWidth: 0,
            leading: widget.iconData != null
                ? SizedBox(
                    height: double.infinity,
                    child: Icon(
                      widget.iconData,
                      size: 22,
                      color: context.themeTextColor,
                    ),
                  )
                : widget.icon.isNotEmpty
                    ? SizedBox(
                        height: double.infinity,
                        child: SvgPicture.asset(
                          widget.icon,
                          width: 20,
                          colorFilter: ColorFilter.mode(
                              context.themeTextColor, BlendMode.srcIn),
                        ),
                      )
                    : null,
            title: widget.badgeText != null && widget.badgeText!.isNotEmpty
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            color: context.themeTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: const Color(0xFFFDE68A), width: 0.8),
                        ),
                        child: Text(
                          widget.badgeText!,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: context.themeTextColor,
                    ),
                  ),
            subtitle: widget.subtitle.isNotEmpty
                ? Text(widget.subtitle,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: context.themeSecondrytext))
                : null,
            trailing: widget.trailing ??
                (widget.children != null && widget.children!.isNotEmpty
                    ? Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: context.themeSecondrytext,
                      )
                    : null),
          ),
        ),
        if (_isExpanded && widget.children != null)
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Column(
              children: widget.children!.map((child) {
                return child; // Render child items
              }).toList(),
            ),
          ),
      ],
    );
  }
}

