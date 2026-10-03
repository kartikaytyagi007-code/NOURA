import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_failure.dart';
import '../../core/providers.dart';
import '../../core/ui/components/state_views.dart';

/// Shown when the signed-in user's profile cannot be loaded. Always offers retry and sign-out so
/// the user is never trapped (blueprint §4).
class SessionErrorScreen extends ConsumerWidget {
  const SessionErrorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(sessionProfileProvider).error;
    final failure = error is ApiFailure ? error : null;
    final offline = failure?.isOffline ?? false;
    return Scaffold(
      body: SafeArea(
        child: MessageView(
          icon: offline ? Icons.cloud_off_outlined : Icons.error_outline,
          title: offline ? "You're offline" : "We couldn't load your account",
          message: failure?.message ?? 'Something went wrong. Please try again.',
          actionLabel: 'Try again',
          onAction: () => ref.invalidate(meControllerProvider),
          secondaryLabel: 'Sign out',
          onSecondary: () => ref.read(authRepositoryProvider).signOut(),
        ),
      ),
    );
  }
}
