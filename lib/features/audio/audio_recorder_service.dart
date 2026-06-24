import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class AudioRecorderService {
  AudioRecorderService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;
  String? _currentPath;
  Timer? _timer;
  int _elapsedSeconds = 0;

  String? get currentPath => _currentPath;
  int get elapsedSeconds => _elapsedSeconds;

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> hasPermission() async {
    return _recorder.hasPermission();
  }

  Future<void> start() async {
    if (!await hasPermission()) {
      final granted = await requestPermission();
      if (!granted) throw StateError('麥克風權限未授予');
    }

    final dir = await getTemporaryDirectory();
    _currentPath =
        '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _elapsedSeconds = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
    });

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: _currentPath!,
    );
  }

  Future<String?> stop() async {
    _timer?.cancel();
    _timer = null;
    final path = await _recorder.stop();
    return path ?? _currentPath;
  }

  Future<void> discard() async {
    _timer?.cancel();
    _timer = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    if (_currentPath != null) {
      final file = File(_currentPath!);
      if (await file.exists()) await file.delete();
    }
    _currentPath = null;
    _elapsedSeconds = 0;
  }

  Future<bool> isRecording() => _recorder.isRecording();

  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
  }
}
