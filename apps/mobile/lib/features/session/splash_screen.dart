import 'package:flutter/material.dart';

import '../../core/ui/components/state_views.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(body: LoadingView(label: 'Restoring your session'));
}
