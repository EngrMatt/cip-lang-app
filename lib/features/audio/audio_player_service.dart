import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  AudioPlayerService() : _player = AudioPlayer();

  final AudioPlayer _player;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Future<void> prepareUrl(String url) => _player.setUrl(url);

  Future<void> prepareFile(String path) => _player.setFilePath(path);

  Future<void> playFile(String path) async {
    await prepareFile(path);
    await playFromStart();
  }

  /// 若已播畢或停在結尾，先 seek 回開頭再播放。
  Future<void> playFromStart() async {
    final state = _player.playerState;
    final duration = _player.duration;
    final position = _player.position;
    if (state.processingState == ProcessingState.completed ||
        (duration != null &&
            duration > Duration.zero &&
            position >= duration - const Duration(milliseconds: 200))) {
      await _player.seek(Duration.zero);
    }
    await _player.play();
  }

  Future<void> playUrl(String url) async {
    await prepareUrl(url);
    await playFromStart();
  }

  Future<void> play() => playFromStart();

  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration position) => _player.seek(position);

  void dispose() => _player.dispose();
}
