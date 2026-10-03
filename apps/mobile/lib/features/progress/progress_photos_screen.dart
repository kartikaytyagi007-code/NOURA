import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../../core/api/api_failure.dart';
import '../../core/progress/progress_controller.dart';
import '../../core/providers.dart';
import '../../core/ui/components/n_button.dart';
import '../../core/ui/components/state_views.dart';
import '../../core/ui/tokens.dart';

ImageMime _mimeFor(XFile file) {
  final path = file.path.toLowerCase();
  if (path.endsWith('.png')) return ImageMime.imageSlashPng;
  if (path.endsWith('.webp')) return ImageMime.imageSlashWebp;
  return ImageMime.imageSlashJpeg;
}

/// Private progress-photo upload, listing and deletion (blueprint §6, §14, §16 M8). Reuses M4's
/// private-media-storage pattern end to end; no image content is ever analyzed here or server-side
/// (docs/decisions.md D-030) — this screen only stores and displays.
class ProgressPhotosScreen extends ConsumerWidget {
  const ProgressPhotosScreen({super.key});

  Future<void> _addPhoto(BuildContext context, WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, maxWidth: 2048, maxHeight: 2048, imageQuality: 90);
    if (file == null) return;
    final Uint8List bytes = await file.readAsBytes();
    if (!context.mounted) return;
    final angle = await showDialog<PhotoAngle>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Which angle?'),
        children: [
          for (final a in PhotoAngle.values)
            SimpleDialogOption(onPressed: () => Navigator.of(dialogContext).pop(a), child: Text(a.value)),
        ],
      ),
    );
    if (angle == null) return;
    try {
      await ref
          .read(progressPhotosControllerProvider.notifier)
          .upload(bytes: bytes, mime: _mimeFor(file), capturedAt: DateTime.now(), angle: angle);
    } on ApiFailure catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(progressPhotosControllerProvider);
    final controller = ref.read(progressPhotosControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Progress photos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          builder: (sheetContext) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _addPhoto(context, ref, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _addPhoto(context, ref, ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        ),
        child: const Icon(Icons.add_a_photo_outlined),
      ),
      body: state.when(
        loading: () => const LoadingView(label: 'Loading your photos'),
        error: (error, _) => ErrorView(
          message: error is ApiFailure ? error.message : 'Something went wrong.',
          offline: error is ApiFailure && error.isOffline,
          onRetry: controller.reload,
        ),
        data: (list) => list.items.isEmpty
            ? const EmptyView(
                title: 'No progress photos yet',
                message: 'Add a private photo to track your progress over time. It is never analyzed.',
              )
            : GridView.builder(
                padding: const EdgeInsets.all(NSpace.pageMargin),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: NSpace.sm,
                  mainAxisSpacing: NSpace.sm,
                  childAspectRatio: 0.8,
                ),
                itemCount: list.items.length,
                itemBuilder: (context, index) {
                  final photo = list.items[index];
                  return _PhotoTile(photo: photo, onDelete: () => controller.delete(photo.id));
                },
              ),
      ),
    );
  }
}

class _PhotoTile extends ConsumerWidget {
  const _PhotoTile({required this.photo, required this.onDelete});
  final ProgressPhoto photo;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(child: ProgressPhotoImage(mediaId: photo.mediaId)),
          Padding(
            padding: const EdgeInsets.all(NSpace.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${photo.angle.value} · ${_formatDate(photo.capturedAt)}'),
                IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => _confirmDelete(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this photo?'),
        content: const Text('This permanently deletes the photo and removes access to it.'),
        actions: [
          NButton(
            label: 'Cancel',
            variant: NButtonVariant.text,
            expand: false,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          NButton(label: 'Delete', expand: false, onPressed: () => Navigator.of(dialogContext).pop(true)),
        ],
      ),
    );
    if (confirmed == true) onDelete();
  }
}

/// Fetches a short-lived signed URL for one private progress photo and shows it, with its own
/// loading/error states (a failed or missing image never blocks the rest of the grid).
class ProgressPhotoImage extends ConsumerStatefulWidget {
  const ProgressPhotoImage({super.key, required this.mediaId});
  final String mediaId;

  @override
  ConsumerState<ProgressPhotoImage> createState() => _ProgressPhotoImageState();
}

class _ProgressPhotoImageState extends ConsumerState<ProgressPhotoImage> {
  late Future<String> _urlFuture;

  @override
  void initState() {
    super.initState();
    _urlFuture = ref.read(progressRepositoryProvider).getPhotoDownloadUrl(widget.mediaId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _urlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Icon(Icons.broken_image_outlined));
        }
        final url = snapshot.data!;
        if (url.startsWith('mock://')) {
          return Container(color: NColors.surfaceContainerLow, child: const Icon(Icons.image_outlined, size: 48));
        }
        return Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => const Center(child: Icon(Icons.broken_image_outlined)),
        );
      },
    );
  }
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _formatDate(DateTime date) => '${_months[date.month - 1]} ${date.day}';
