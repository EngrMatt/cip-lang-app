import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/widgets/async_value_widget.dart';
import '../../audio/audio_player_service.dart';
import '../providers/records_providers.dart';

class RecordDetailPage extends ConsumerStatefulWidget {
  const RecordDetailPage({super.key, required this.recordId});

  final int recordId;

  @override
  ConsumerState<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends ConsumerState<RecordDetailPage> {
  final _player = AudioPlayerService();
  PlayerController? _waveformPlayer;
  bool _isPlaying = false;
  bool _waveformReady = false;
  String? _waveformError;

  @override
  void dispose() {
    _waveformPlayer?.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _prepareWaveform(String url) async {
    try {
      final controller = PlayerController();
      await controller.preparePlayer(
        path: url,
        shouldExtractWaveform: true,
      );
      if (mounted) {
        setState(() {
          _waveformPlayer = controller;
          _waveformReady = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _waveformError = e.toString();
          _waveformReady = false;
        });
      }
    }
  }

  Future<void> _togglePlay(String? url) async {
    if (url == null) return;
    try {
      if (_isPlaying) {
        await _player.pause();
        await _waveformPlayer?.pausePlayer();
        setState(() => _isPlaying = false);
      } else {
        if (_waveformPlayer == null && _waveformError == null) {
          await _prepareWaveform(url);
        }
        await _player.playUrl(url);
        await _waveformPlayer?.startPlayer();
        setState(() => _isPlaying = true);
        _player.playerStateStream.listen((playerState) {
          if (playerState.processingState == ProcessingState.completed &&
              mounted) {
            _waveformPlayer?.stopPlayer();
            setState(() => _isPlaying = false);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('播放失敗：$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordAsync = ref.watch(recordDetailProvider(widget.recordId));
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('語料詳細'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: AsyncValueWidget(
        value: recordAsync,
        data: (record) {
          if (record.audioUrl != null &&
              _waveformPlayer == null &&
              _waveformError == null) {
            Future.microtask(() => _prepareWaveform(record.audioUrl!));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.title,
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        CategoryBadge(category: record.category),
                        const SizedBox(height: 16),
                        _MetaRow(
                          label: '建立時間',
                          value: dateFormat.format(record.createdAt.toLocal()),
                        ),
                        if (record.note != null && record.note!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _MetaRow(label: '備註', value: record.note!),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('錄音',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        if (record.audioUrl != null) ...[
                          if (_waveformReady && _waveformPlayer != null)
                            AudioFileWaveforms(
                              size: Size(
                                MediaQuery.of(context).size.width - 72,
                                80,
                              ),
                              playerController: _waveformPlayer!,
                              enableSeekGesture: true,
                              waveformType: WaveformType.long,
                            )
                          else if (_waveformError != null)
                            Text(
                              '波形載入失敗，仍可播放',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () => _togglePlay(record.audioUrl),
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                            ),
                            label: Text(_isPlaying ? '暫停' : '播放錄音'),
                          ),
                        ] else
                          Text(
                            '尚無錄音',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('照片',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        if (record.imageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              record.imageUrl!,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const _MediaPlaceholder(
                                message: '照片載入失敗',
                              ),
                            ),
                          )
                        else
                          const _MediaPlaceholder(message: '尚無照片'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        error: (err, _) {
          final message = err.toString().replaceFirst('AppException: ', '');
          final is404 = message.contains('不存在') || message.contains('404');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    is404 ? Icons.search_off : Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    is404 ? '語料不存在' : message,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.pop(),
                    child: const Text('返回列表'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _MediaPlaceholder extends StatelessWidget {
  const _MediaPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
