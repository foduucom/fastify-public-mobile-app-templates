import 'package:flutter/material.dart';

class DrawerScaffold extends StatelessWidget {
  const DrawerScaffold(
      {Key? key, this.appBar, required this.body, this.bottomNavigationBar})
      : super(key: key);
  final AppBar? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
