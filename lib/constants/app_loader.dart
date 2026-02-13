import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoader({super.key, this.size = 40.0, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          // Use theme color by default, or override if needed
          color: color ?? Theme.of(context).primaryColor,
          strokeWidth: 3.0,
        ),
      ),
    );
  }
}
