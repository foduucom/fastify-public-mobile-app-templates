import 'package:flutter/material.dart';

import 'home_view.dart';

/// Compatibility entry point used by the home route and bottom navigation.
/// HomeView owns the CMS layout rendering.
class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) => const HomeView();
}
