import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../core/ui/components/mock_banner.dart';
import '../core/ui/components/state_views.dart';
import '../core/ui/theme.dart';
import 'router.dart';

class NouraApp extends ConsumerWidget {
  const NouraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useMocks = ref.watch(appConfigProvider).useMocks;
    return MaterialApp.router(
      title: 'NOURA',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => useMocks ? MockModeBanner(child: child!) : child!,
    );
  }
}

/// Shown instead of the app when build-time configuration is unsafe or incomplete (fail closed).
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key, required this.issues});

  final List<String> issues;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      home: Scaffold(
        body: SafeArea(
          child: MessageView(
            icon: Icons.settings_outlined,
            title: 'App configuration problem',
            message: issues.join('\n'),
          ),
        ),
      ),
    );
  }
}
