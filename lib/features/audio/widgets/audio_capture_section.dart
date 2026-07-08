import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart' hide PlayerState;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../../records/providers/create_record_notifier.dart';
import '../audio_player_service.dart';
import '../audio_recorder_service.dart';
import 'audio_playback_bar.dart';

class AudioCaptureSection extends ConsumerStatefulWidget {
  const AudioCaptureSection({super.key});

  @override
  ConsumerState<AudioCaptureSection> createState() =>
      _AudioCaptureSectionState();
}

class _AudioCaptureSectionState extends ConsumerState<AudioCaptureSection> {
  RecorderController? _waveformController;
  final _fallbackRecorder = AudioRecorderService();
  final _player = AudioPlayerService();
  bool _useWaveform = true;
  bool _isRecording = false;
  bool _isPreviewPlaying = false;
  bool _isPreviewReady = false;
  String? _savedPath;
  String? _error;
  Timer? _uiTimer;
  int _seconds = 0;
  StreamSubscription<PlayerState>? _playerSub;

  @override
  void initState() {
    super.initState();
    _initWaveform();
    _playerSub = _player.playerStateStream.listen(_onPlayerState);
  }

  void _onPlayerState(PlayerState playerState) {
    if (!mounted) return;
    if (playerState.processingState == ProcessingState.completed) {
      _player.seek(Duration.zero);
    }
    final playing = playerState.playing &&
        playerState.processingState != ProcessingState.completed;
    if (_isPreviewPlaying != playing) {
      setState(() => _isPreviewPlaying = playing);
    }
  }

  Future<void> _initWaveform() async {
    try {
      final controller = RecorderController()..sampleRate = 44100;
      await controller.checkPermission();
      if (mounted) {
        setState(() => _waveformController = controller);
      }
    } catch (_) {
      if (mounted) setState(() => _useWaveform = false);
    }
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    _playerSub?.cancel();
    _waveformController?.dispose();
    _fallbackRecorder.dispose();
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatAudioDuration(Duration duration) {
    return _formatDuration(duration.inSeconds);
  }

  Future<String> _newRecordingPath() async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

  Future<void> _startRecording() async {
    setState(() => _error = null);
    try {
      _uiTimer?.cancel();
      _seconds = 0;
      _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _seconds++);
      });

      if (_useWaveform && _waveformController != null) {
        final path = await _newRecordingPath();
        await _waveformController!.record(path: path);
      } else {
        await _fallbackRecorder.start();
      }

      setState(() {
        _isRecording = true;
        _savedPath = null;
        _isPreviewReady = false;
      });
    } catch (e) {
      if (_useWaveform) {
        setState(() => _useWaveform = false);
        await _startRecordingFallback();
      } else {
        setState(() => _error = e.toString());
      }
    }
  }

  Future<void> _startRecordingFallback() async {
    try {
      await _fallbackRecorder.start();
      setState(() {
        _isRecording = true;
        _savedPath = null;
        _isPreviewReady = false;
        _seconds = 0;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _preparePreview(String path) async {
    setState(() => _isPreviewReady = false);
    try {
      await _player.prepareFile(path);
      if (mounted) setState(() => _isPreviewReady = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _stopRecording() async {
    _uiTimer?.cancel();
    try {
      String? path;
      if (_useWaveform && _waveformController != null) {
        path = await _waveformController!.stop();
        _seconds = _waveformController!.elapsedDuration.inSeconds;
      } else {
        path = await _fallbackRecorder.stop();
        _seconds = _fallbackRecorder.elapsedSeconds;
      }

      if (path != null) {
        ref.read(createRecordProvider.notifier).setAudioPath(path);
        await _preparePreview(path);
      }
      setState(() {
        _isRecording = false;
        _savedPath = path;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _reRecord() async {
    if (_useWaveform && _waveformController != null) {
      _waveformController!.reset();
    } else {
      await _fallbackRecorder.discard();
    }
    await _player.stop();
    ref.read(createRecordProvider.notifier).setAudioPath(null);
    setState(() {
      _isRecording = false;
      _savedPath = null;
      _isPreviewReady = false;
      _seconds = 0;
      _error = null;
    });
  }

  Future<void> _togglePreview() async {
    if (_savedPath == null || !_isPreviewReady) return;
    try {
      if (_isPreviewPlaying) {
        await _player.pause();
        return;
      }
      await _player.playFromStart();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
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
            SizedBox(
              height: 100,
              child: Center(
                child: _isRecording &&
                        _useWaveform &&
                        _waveformController != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: AudioWaveforms(
                              recorderController: _waveformController!,
                              size: Size(
                                MediaQuery.of(context).size.width - 72,
                                60,
                              ),
                              waveStyle: WaveStyle(
                                waveColor: theme.colorScheme.error,
                                extendWaveform: true,
                                showMiddleLine: false,
                              ),
                            ),
                          ),
                          Text(
                            _formatDuration(_seconds),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isRecording ? Icons.mic : Icons.mic_none,
                            size: 48,
                            color: _isRecording
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatDuration(_seconds),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
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
              AudioPlaybackBar(
                player: _player,
                isPlaying: _isPreviewPlaying,
                isLoading: !_isPreviewReady,
                isReady: _isPreviewReady,
                formatDuration: _formatAudioDuration,
                onPlayPause: _togglePreview,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _reRecord,
                icon: const Icon(Icons.refresh),
                label: const Text('重新錄音'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
