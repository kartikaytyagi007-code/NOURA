import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/api/api_failure.dart';
import '../../core/progress/progress_controller.dart';
import '../../core/ui/components/state_views.dart';
import '../../core/ui/tokens.dart';
import 'progress_photos_screen.dart' show ProgressPhotoImage;

/// A simple side-by-side progress-photo comparison: pick two dates, view the photos (M8 ticket).
/// This is pure UI — it fetches two already-stored photos by date and displays them. It never
/// analyzes physique, estimates body fat, or makes any judgment about the images' content.
class PhotoComparisonScreen extends ConsumerStatefulWidget {
  const PhotoComparisonScreen({super.key});

  @override
  ConsumerState<PhotoComparisonScreen> createState() => _PhotoComparisonScreenState();
}

class _PhotoComparisonScreenState extends ConsumerState<PhotoComparisonScreen> {
  String? _leftId;
  String? _rightId;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(progressPhotosControllerProvider);
    final controller = ref.read(progressPhotosControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Compare photos')),
      body: state.when(
        loading: () => const LoadingView(label: 'Loading your photos'),
        error: (error, _) => ErrorView(
          message: error is ApiFailure ? error.message : 'Something went wrong.',
          offline: error is ApiFailure && error.isOffline,
          onRetry: controller.reload,
        ),
        data: (list) {
          if (list.items.length < 2) {
            return const EmptyView(
              title: 'Not enough photos yet',
              message: 'Add at least two progress photos to compare them side by side.',
            );
          }
          final sorted = [...list.items]..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
          _leftId ??= sorted.first.id;
          _rightId ??= sorted.last.id;
          return Padding(
            padding: const EdgeInsets.all(NSpace.pageMargin),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _DatePicker(
                        label: 'First date',
                        photos: sorted,
                        selectedId: _leftId,
                        onChanged: (id) => setState(() => _leftId = id),
                      ),
                    ),
                    const SizedBox(width: NSpace.sm),
                    Expanded(
                      child: _DatePicker(
                        label: 'Second date',
                        photos: sorted,
                        selectedId: _rightId,
                        onChanged: (id) => setState(() => _rightId = id),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NSpace.md),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _ComparisonPane(photo: sorted.where((p) => p.id == _leftId).firstOrNull)),
                      const SizedBox(width: NSpace.sm),
                      Expanded(child: _ComparisonPane(photo: sorted.where((p) => p.id == _rightId).firstOrNull)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  const _DatePicker({required this.label, required this.photos, required this.selectedId, required this.onChanged});
  final String label;
  final List<ProgressPhoto> photos;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      initialValue: selectedId,
      items: [
        for (final photo in photos)
          DropdownMenuItem(value: photo.id, child: Text('${_formatDate(photo.capturedAt)} (${photo.angle.value})')),
      ],
      onChanged: onChanged,
    );
  }
}

class _ComparisonPane extends StatelessWidget {
  const _ComparisonPane({required this.photo});
  final ProgressPhoto? photo;

  @override
  Widget build(BuildContext context) {
    if (photo == null) {
      // Data-unavailable state: no photo exists for the selected date (M8 ticket).
      return const Center(child: Text('No photo for this date'));
    }
    return ProgressPhotoImage(mediaId: photo!.mediaId);
  }
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _formatDate(DateTime date) => '${_months[date.month - 1]} ${date.day}, ${date.year}';
