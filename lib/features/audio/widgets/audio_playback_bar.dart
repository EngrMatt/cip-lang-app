import 'package:flutter/material.dart';

import '../audio_player_service.dart';

class AudioPlaybackBar extends StatelessWidget {
  const AudioPlaybackBar({
    super.key,
    required this.player,
    required this.isPlaying,
    required this.isLoading,
    required this.isReady,
    this.loadError,
    this.formatDuration = _defaultFormatDuration,
    this.onPlayPause,
    this.showPlayButton = true,
  });

  final AudioPlayerService player;
  final bool isPlaying;
  final bool isLoading;
  final bool isReady;
  final String? loadError;
  final String Function(Duration) formatDuration;
  final VoidCallback? onPlayPause;
  final bool showPlayButton;

  static String _defaultFormatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

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
          if (loadError != null)
            Text(
              loadError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            )
          else if (isLoading)
            Text(
              '正在載入錄音…',
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
          if (showPlayButton && onPlayPause != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: isReady && !isLoading ? onPlayPause : null,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(
                isLoading
                    ? '載入錄音中…'
                    : loadError != null
                        ? '無法載入錄音'
                        : isPlaying
                            ? '暫停'
                            : '播放錄音',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
