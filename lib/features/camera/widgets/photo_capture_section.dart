import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../records/providers/create_record_notifier.dart';
import '../photo_capture_service.dart';
import 'record_photo_preview.dart';

class PhotoCaptureSection extends ConsumerStatefulWidget {
  const PhotoCaptureSection({super.key});

  @override
  ConsumerState<PhotoCaptureSection> createState() =>
      _PhotoCaptureSectionState();
}

class _PhotoCaptureSectionState extends ConsumerState<PhotoCaptureSection> {
  final _service = PhotoCaptureService();
  File? _photo;
  String? _error;

  Future<void> _capture() async {
    setState(() => _error = null);
    try {
      final file = await _service.capturePhoto();
      if (file == null) return;
      ref.read(createRecordProvider.notifier).setImagePath(file.path);
      setState(() => _photo = file);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _delete() async {
    if (_photo != null) {
      await _service.deletePhoto(_photo!);
    }
    ref.read(createRecordProvider.notifier).setImagePath(null);
    setState(() {
      _photo = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('拍照', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '拍攝現場照片以保留採集環境（選填）。',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            if (_photo != null)
              RecordPhotoPreview(file: _photo)
            else
              Container(
                height: 160,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Icon(
                  Icons.photo_camera_outlined,
                  size: 48,
                  color: theme.colorScheme.outline,
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: 16),
            if (_photo == null)
              FilledButton.icon(
                onPressed: _capture,
                icon: const Icon(Icons.camera_alt),
                label: const Text('開啟相機拍照'),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _capture,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('重拍'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _delete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('刪除'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
