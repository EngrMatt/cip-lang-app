import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoCaptureService {
  PhotoCaptureService() : _picker = ImagePicker();

  final ImagePicker _picker;

  Future<bool> requestPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<File?> capturePhoto() async {
    final granted = await requestPermission();
    if (!granted) throw StateError('相機權限未授予');

    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  Future<void> deletePhoto(File file) async {
    if (await file.exists()) await file.delete();
  }
}
