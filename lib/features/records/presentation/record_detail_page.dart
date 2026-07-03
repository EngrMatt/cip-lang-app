import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
  bool _isPlaying = false;
  bool _isAudioLoading = false;
  bool _isAudioReady = false;
  String? _audioLoadError;
  String? _preparedUrl;
  StreamSubscription<PlayerState>? _playerSub;

  @override
  void initState() {
    super.initState();
    _playerSub = _player.playerStateStream.listen(_onPlayerState);
  }

  void _onPlayerState(PlayerState playerState) {
    if (!mounted) return;
    final playing = playerState.playing &&
        playerState.processingState != ProcessingState.completed;
    if (_isPlaying != playing) {
      setState(() => _isPlaying = playing);
    }
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _prepareAudio(String url) async {
    if (_preparedUrl == url && (_isAudioReady || _isAudioLoading)) return;

    setState(() {
      _preparedUrl = url;
      _isAudioLoading = true;
      _isAudioReady = false;
      _audioLoadError = null;
      _isPlaying = false;
    });

    try {
      await _player.prepareUrl(url);
      if (!mounted || _preparedUrl != url) return;
      setState(() {
        _isAudioLoading = false;
        _isAudioReady = true;
      });
    } catch (e) {
      if (!mounted || _preparedUrl != url) return;
      setState(() {
        _isAudioLoading = false;
        _audioLoadError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _togglePlay() async {
    if (!_isAudioReady || _isAudioLoading) return;
    try {
      if (_isPlaying) {
        await _player.pause();
        return;
      }
      await _player.play();
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
          final audioUrl = record.audioUrl;
          if (audioUrl != null && _preparedUrl != audioUrl) {
            Future.microtask(() => _prepareAudio(audioUrl));
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
                        if (audioUrl != null) ...[
                          _RemoteAudioPlayer(
                            isPlaying: _isPlaying,
                            isLoading: _isAudioLoading,
                            isReady: _isAudioReady,
                            loadError: _audioLoadError,
                            player: _player,
                            formatDuration: _formatDuration,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed:
                                _isAudioReady && !_isAudioLoading ? _togglePlay : null,
                            icon: _isAudioLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                  ),
                            label: Text(
                              _isAudioLoading
                                  ? '載入錄音中…'
                                  : _audioLoadError != null
                                      ? '無法載入錄音'
                                      : _isPlaying
                                          ? '暫停'
                                          : '播放錄音',
                            ),
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
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const SizedBox(
                                  height: 220,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const _MediaPlaceholder(message: '照片載入失敗'),
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

class _RemoteAudioPlayer extends StatelessWidget {
  const _RemoteAudioPlayer({
    required this.isPlaying,
    required this.isLoading,
    required this.isReady,
    required this.loadError,
    required this.player,
    required this.formatDuration,
  });

  final bool isPlaying;
  final bool isLoading;
  final bool isReady;
  final String? loadError;
  final AudioPlayerService player;
  final String Function(Duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            isLoading
                ? Icons.hourglass_top
                : isPlaying
                    ? Icons.graphic_eq
                    : Icons.audiotrack,
            size: 40,
            color: isReady
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          if (loadError != null)
            Text(
              loadError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            )
          else if (isLoading)
            Text(
              '正在下載錄音…',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, positionSnapshot) {
                final position = positionSnapshot.data ?? Duration.zero;
                return StreamBuilder<Duration?>(
                  stream: player.durationStream,
                  builder: (context, durationSnapshot) {
                    final duration = durationSnapshot.data;
                    final maxMs = duration?.inMilliseconds ?? 1;
                    final value = duration == null
                        ? 0.0
                        : position.inMilliseconds / maxMs;

                    return Column(
                      children: [
                        Slider(
                          value: value.clamp(0.0, 1.0),
                          onChanged: !isReady || duration == null
                              ? null
                              : (v) => player.seek(
                                    Duration(
                                      milliseconds: (v * maxMs).round(),
                                    ),
                                  ),
                        ),
                        Text(
                          duration == null
                              ? '—'
                              : '${formatDuration(position)} / ${formatDuration(duration)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
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
