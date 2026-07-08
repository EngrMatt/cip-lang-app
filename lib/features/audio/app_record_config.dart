import 'package:record/record.dart';

/// 田野訪談錄音共用設定：單聲道、降噪、回音消除。
const appRecordConfig = RecordConfig(
  encoder: AudioEncoder.aacLc,
  sampleRate: 44100,
  bitRate: 128000,
  numChannels: 1,
  noiseSuppress: true,
  echoCancel: true,
  androidConfig: AndroidRecordConfig(
    audioSource: AndroidAudioSource.voiceRecognition,
    audioManagerMode: AudioManagerMode.modeInCommunication,
  ),
);
