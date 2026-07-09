import 'dart:io';

import 'package:flutter/material.dart';

/// 顯示完整照片（不裁切），高度隨比例縮放至 [maxHeight] 內。
class RecordPhotoPreview extends StatelessWidget {
  const RecordPhotoPreview({
    super.key,
    this.file,
    this.imageUrl,
    this.maxHeight = 320,
  }) : assert(file != null || imageUrl != null);

  final File? file;
  final String? imageUrl;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget image;
    if (file != null) {
      image = Image.file(
        file!,
        fit: BoxFit.contain,
        width: double.infinity,
      );
    } else {
      image = Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        width: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            height: maxHeight * 0.6,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) => SizedBox(
          height: maxHeight * 0.4,
          child: Center(
            child: Text(
              '照片載入失敗',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: maxHeight),
        color: theme.colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: image,
      ),
    );
  }
}
