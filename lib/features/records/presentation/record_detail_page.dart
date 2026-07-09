import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/widgets/async_value_widget.dart';
import '../../audio/audio_player_service.dart';
import '../../audio/widgets/audio_playback_bar.dart';
import '../../camera/widgets/record_photo_preview.dart';
import '../../explore/providers/map_records_provider.dart';
import '../data/record_repository.dart';
import '../providers/records_providers.dart';
import '../widgets/record_note_display.dart';

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
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _playerSub = _player.playerStateStream.listen(_onPlayerState);
  }

  void _onPlayerState(PlayerState playerState) {
    if (!mounted) return;
    if (playerState.processingState == ProcessingState.completed) {
      _player.seek(Duration.zero);
    }
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
      await _player.playFromStart();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('播放失敗：$e')),
        );
      }
    }
  }

  Future<void> _confirmAndDelete(String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除語料'),
        content: Text('確定要刪除「$title」嗎？此操作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await ref.read(recordRepositoryProvider).deleteRecord(widget.recordId);
      ref.invalidate(recordsListProvider);
      ref.invalidate(mapRecordsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已刪除語料')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '刪除失敗：${e.toString().replaceFirst('AppException: ', '')}',
          ),
        ),
      );
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
          onPressed: _isDeleting ? null : () => context.pop(),
        ),
        actions: recordAsync.when(
          data: (record) => [
            IconButton(
              tooltip: '刪除',
              onPressed: _isDeleting
                  ? null
                  : () => _confirmAndDelete(record.title),
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
            ),
          ],
          loading: () => const <Widget>[],
          error: (error, stackTrace) => const <Widget>[],
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
                          RecordNoteDisplay(note: record.note!),
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
                        if (audioUrl != null)
                          AudioPlaybackBar(
                            player: _player,
                            isPlaying: _isPlaying,
                            isLoading: _isAudioLoading,
                            isReady: _isAudioReady,
                            loadError: _audioLoadError,
                            formatDuration: _formatDuration,
                            onPlayPause: _togglePlay,
                          ) else
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
                          RecordPhotoPreview(imageUrl: record.imageUrl)
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
