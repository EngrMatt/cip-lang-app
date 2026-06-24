import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../records/providers/create_record_notifier.dart';
import '../audio_player_service.dart';
import '../audio_recorder_service.dart';

class AudioCaptureSection extends ConsumerStatefulWidget {
  const AudioCaptureSection({super.key});

  @override
  ConsumerState<AudioCaptureSection> createState() =>
      _AudioCaptureSectionState();
}

class _AudioCaptureSectionState extends ConsumerState<AudioCaptureSection> {
  final _recorder = AudioRecorderService();
  final _player = AudioPlayerService();
  bool _isRecording = false;
  String? _savedPath;
  String? _error;
  Timer? _uiTimer;
  int _seconds = 0;

  @override
  void dispose() {
    _uiTimer?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _startRecording() async {
    setState(() {
      _error = null;
    });
    try {
      await _recorder.start();
      _uiTimer?.cancel();
      _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _seconds = _recorder.elapsedSeconds);
      });
      setState(() {
        _isRecording = true;
        _savedPath = null;
        _seconds = 0;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _stopRecording() async {
    _uiTimer?.cancel();
    try {
      final path = await _recorder.stop();
      ref.read(createRecordProvider.notifier).setAudioPath(path);
      setState(() {
        _isRecording = false;
        _savedPath = path;
        _seconds = _recorder.elapsedSeconds;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _reRecord() async {
    await _recorder.discard();
    await _player.stop();
    ref.read(createRecordProvider.notifier).setAudioPath(null);
    setState(() {
      _isRecording = false;
      _savedPath = null;
      _seconds = 0;
      _error = null;
    });
  }

  Future<void> _preview() async {
    if (_savedPath == null) return;
    await _player.playFile(_savedPath!);
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
            Text('錄音', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '錄製訪談或語料內容，完成後可預覽再繼續。',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Icon(
                    _isRecording ? Icons.mic : Icons.mic_none,
                    size: 64,
                    color: _isRecording
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDuration(_seconds),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: 20),
            if (_isRecording)
              FilledButton.icon(
                onPressed: _stopRecording,
                icon: const Icon(Icons.stop),
                label: const Text('停止錄音'),
              )
            else if (_savedPath == null)
              FilledButton.icon(
                onPressed: _startRecording,
                icon: const Icon(Icons.fiber_manual_record),
                label: const Text('開始錄音'),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _preview,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('預覽'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _reRecord,
                      icon: const Icon(Icons.refresh),
                      label: const Text('重新錄音'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
