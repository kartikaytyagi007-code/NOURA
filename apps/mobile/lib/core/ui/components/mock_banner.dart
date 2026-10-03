import 'package:flutter/material.dart';

import '../tokens.dart';

/// Persistent, unmissable marker that the app runs on development mocks (no real auth or data).
class MockModeBanner extends StatelessWidget {
  const MockModeBanner({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: NColors.mockBanner,
          child: SafeArea(
            bottom: false,
            child: Semantics(
              liveRegion: true,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: NSpace.md, vertical: NSpace.xs),
                child: Text(
                  'DEVELOPMENT MOCKS · not real accounts or data',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: MediaQuery.removePadding(context: context, removeTop: true, child: child),
        ),
      ],
    );
  }
}
